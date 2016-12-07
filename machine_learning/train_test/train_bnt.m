function [ml_model] = train_bnt(train_data, param)
%[ml_model] = train_bnt(train_data, param)

%{
close all
clear
clc
param = globalParam();
temp_load = load('./generated_files/train_data.mat');
train_data = temp_load.train_data;
% train_data = dlmread('./generated_files/train_data.txt');
%}

%% ungroup data
gt_label = zeros(numel(train_data)*(param.num_rand+1),1);
head_pose_data = zeros(numel(train_data),3);
feature_data = zeros(numel(train_data)*(param.num_rand+1), param.feat_size-4);
head_pose_duplicate = zeros(numel(train_data)*(param.num_rand+1), 3); % for train test type 3
for i = 1:numel(train_data)
    gt_label((1+(param.num_rand+1)*(i-1)) : i*(param.num_rand+1)) = train_data{i}.gt_label;
    head_pose_data(i,:) = train_data{i}.head_pose;
    feature_data((1+(param.num_rand+1)*(i-1)) : i*(param.num_rand+1), :) = train_data{i}.feature;
    head_pose_duplicate((1+(param.num_rand+1)*(i-1)) : i*(param.num_rand+1), :) = ...
        bsxfun(@plus, train_data{i}.head_pose, zeros(param.num_rand+1,3));
end
%{
% ungroup data
input_data = train_data(:,1:end-1);
gt_label = train_data(:,end);

% separate data
head_pose_data = input_data(:,1:3);
hog_data = input_data(:, 4:end);
%}
%%
tic
if param.train_test_type == 1
    %% single regressor training
    if param.feat_size-4 ~= size(feature_data, 2) % sanity check
        error('Feature size does not match with training data.')
    end
    % training
    ml_model.regressor = ml_train(feature_data, gt_label, param);
    
elseif param.train_test_type == 2
    %% EM clustering head pose
    [gmm_assignments, gmm, kmean] = k_init_em(head_pose_data(:,2:3), param.k_ctrs, param); % remove roll dimension
    %     [centers, assignments] = ...
    %         vl_kmeans(head_pose_data',param.k_ctrs,'Initialization','plusplus','Algorithm','Elkan');
    ml_model.em_model = gmm;
    ml_model.kmean_model = kmean;
    % n_train_cluster = zeros(1, param.k_ctrs);
    %% multiple regressor training
    regressor = cell(param.k_ctrs,1);
    parfor i = 1:param.k_ctrs
        fprintf('Cluster %d training\n', i)
        % assign training according to cluster centers
        if param.cluster_type == 1
            fprintf('K-mean hard cluster.\n')
            train_idx = find(kmean.assignments==i);
        elseif param.cluster_type == 2
            fprintf('GMM soft cluster.\n')
            train_idx = find(gmm_assignments==i)';
        else
            error('No such cluster type')
        end
        % store num of training sample in each cluster
        % n_train_cluster(i) = numel(train_idx);
        % collect train data and label
        temp_train_label = zeros(numel(train_idx)*(param.num_rand+1), 1);
        temp_train_data = zeros(numel(train_idx)*(param.num_rand+1), param.feat_size-4);
        temp_count = 0;
        for j = train_idx
            temp_count = temp_count + 1;
            temp_train_data((1+(param.num_rand+1)*(temp_count-1)):temp_count*(param.num_rand+1),:)...
                =train_data{j}.feature;
            temp_train_label((1+(param.num_rand+1)*(temp_count-1)):temp_count*(param.num_rand+1))...
                =train_data{j}.gt_label;
        end
        if param.feat_size-4 ~= size(temp_train_data, 2) % sanity check
            error('Feature size does not match with training data.')
        end
        % training
        regressor{i} = ml_train(temp_train_data, temp_train_label, param);
    end
    ml_model.regressor = regressor;
elseif param.train_test_type == 3 && strcmp(param.regressor, 'rf')
    fprintf('Using Random Forests for head pose and feature\n')
    input_data = [head_pose_duplicate feature_data];
    ml_model.regressor = regRF_train(input_data, gt_label, param.rf_ntrees, param.rf_split);
elseif param.train_test_type == 4 % classification instead of regression
    %% single classifier training
    % training
    if strcmp(param.regressor, 'svm')
        fprintf('Using SVM Classifier\n')
        classifier_model = train(gt_label, sparse(feature_data),...
            sprintf('-s l2 -w0 %d -w1 %d -c %d -q', param.svm_w0, param.svm_w1, param.svm_c));
    elseif strcmp(param.regressor, 'rf')
        fprintf('Using Random Forests Classifier\n')
        classifier_model = classRF_train([head_pose_duplicate feature_data], gt_label, param.rf_ntrees, param.rf_split);
    else
        error('Regressor error')
    end
    ml_model.classifier = classifier_model;
else
    error('Training type error.')
end

ml_time = toc;
fprintf('Regressor Training Time: %.4f sec\n', ml_time)

% hmm transition model
if param.use_hmm
    trans_model = getTransModel(gt_label);
    ml_model.hmm_model = trans_model;
    % find prior distribution
    ecPrior = numel(find(gt_label == 1)) / numel(gt_label);
    necPrior = numel(find(gt_label == 0)) / numel(gt_label);
    ml_model.hmm_prior = [ecPrior; necPrior];
end
