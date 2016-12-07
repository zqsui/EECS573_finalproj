function [ml_model] = train_temp(train_data, param)
%[ml_model] = train_temp(train_data, param)

% close all
% clear
% clc
% param = globalParam();
% temp_load = load('./generated_files/train_data.mat');
% train_data = temp_load.train_data;
% % train_data = dlmread('./generated_files/train_data.txt');

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

ml_model = struct;
%%
if param.train_test_type == 1
    %% single regressor training
    % fisher vector encoding
    [eigen_vector, fv_gmm] = init_fisher_vector(feature_data, param.pca_dim, param);
    train_set = zeros( numel(train_data), (2*param.pca_dim+1)*param.fv_n_center );
    train_label = zeros(numel(train_data), 1);
    tic
    for i = 1:numel(train_data)
        temp_data = eigen_vector * train_data{i}.feature';
        train_set(i,:) = fisherCoding(fv_gmm, temp_data)';
        train_label(i) = train_data{i}.gt_label;
    end
    fv_time = toc;
    fprintf('Fisher vector time: %.4f sec\n', fv_time)
    
    % training
    ml_model.regressor = ml_train(train_set, train_label, param);
    ml_model.fv_eigen_vector = eigen_vector;
    ml_model.fv_gmm = fv_gmm;
elseif param.train_test_type == 2
    %% EM clustering head pose
    [assignments, gmm] = k_init_em(head_pose_data, param.k_ctrs, param);
    %     [centers, assignments] = ...
    %         vl_kmeans(head_pose_data',param.k_ctrs,'Initialization','plusplus','Algorithm','Elkan');
    ml_model.em_model = gmm;
    % n_train_cluster = zeros(1, param.k_ctrs);
    %% multiple regressor training
    regressor = cell(5,1);
    parfor i = 1:param.k_ctrs
        fprintf('Cluster %d training\n', i)
        % assign training according to cluster centers
        train_idx = find(assignments==i);
        % store num of training sample in each cluster
        % n_train_cluster(i) = numel(train_idx);
        % collect train data and label
        temp_train_label = zeros(numel(train_idx)*(param.num_rand+1), 1);
        temp_train_data = zeros(numel(train_idx)*(param.num_rand+1), param.feat_size-4);
        temp_count = 0;
        for j = train_idx'
            temp_count = temp_count + 1;
            temp_train_data((1+(param.num_rand+1)*(temp_count-1)):temp_count*(param.num_rand+1),:)...
                =train_data{j}.feature;
            temp_train_label((1+(param.num_rand+1)*(temp_count-1)):temp_count*(param.num_rand+1))...
                =train_data{j}.gt_label;
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


% hmm transition model
if param.use_hmm
    trans_model = getTransModel(gt_label);
    ml_model.hmm_model = trans_model;
    % find prior distribution
    ecPrior = numel(find(gt_label == 1)) / numel(gt_label);
    necPrior = numel(find(gt_label == 0)) / numel(gt_label);
    ml_model.hmm_prior = [ecPrior; necPrior];
end
