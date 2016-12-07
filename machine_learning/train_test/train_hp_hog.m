function [ml_model] = train_hp_hog(train_data, param)
%[ml_model] = train_bnt(train_data, param)

% close all
% clear
% clc
% param = globalParam();
% train_data = dlmread('./generated_files/train_data.txt');

% group data
input_data = train_data(:,1:end-1);
gt_label = train_data(:,end);

% separate data
head_pose_data = input_data(:,1:3);
hog_data = input_data(:, 4:end);

tic
if param.train_test_type == 1
    %% single regressor training
    % training
    if strcmp(param.regressor, 'svm')
        fprintf('Using SVM\n')
        % train hog regressor
        hog_regressor_model = train(gt_label, sparse(hog_data),...
            sprintf('-s l2 -w0 %d -w1 %d -c %d -q', param.svm_w0, param.svm_w1, param.svm_c));
        % train head pose regressor
        hp_regressor_model = train(gt_label, sparse(head_pose_data),...
            sprintf('-s l2 -w0 %d -w1 %d -c %d -q', param.svm_w0, param.svm_w1, param.svm_c));
    elseif strcmp(param.regressor, 'rf')
        fprintf('Using Random Forests\n')
        hog_regressor_model = regRF_train(hog_data, gt_label, param.rf_ntrees, param.rf_split);
    else
        error('Regressor error')
    end
    ml_model.hog_regressor = hog_regressor_model;
    ml_model.hp_regressor = hp_regressor_model;
elseif param.train_test_type == 2
    %% K-means clustering head pose
    fprintf('Start k-mean %d centers...\n', param.k_ctrs)
    [centers, assignments] = ...
        vl_kmeans(head_pose_data',param.k_ctrs,'Initialization','plusplus','Algorithm','Elkan');
    ml_model.kmean_ctrs = centers';
    
    n_train_cluster = zeros(1, param.k_ctrs);
    %% multiple regressor training
    ml_model.regressor = cell(5,1);
    for i = 1:param.k_ctrs
        fprintf('Cluster %d training\n', i)
        % assign training according to cluster centers
        train_idx = find(assignments==i);
        % store num of training sample in each cluster
        n_train_cluster(i) = numel(train_idx);
        temp_train_data = hog_data(train_idx, :);
        temp_train_label = gt_label(train_idx, :);
        
        % training
        if strcmp(param.regressor, 'svm')
            fprintf('Using SVM\n')
            ml_model.regressor{i} = train(temp_train_label, sparse(temp_train_data),...
                sprintf('-s l2 -w0 %d -w1 %d -c %d -q', param.svm_w0, param.svm_w1, param.svm_c));
        elseif strcmp(param.regressor, 'rf')
            fprintf('Using Random Forests\n')
            ml_model.regressor{i} = regRF_train(temp_train_data, temp_train_label, param.rf_ntrees, param.rf_split);
        else
            error('Regressor error')
        end
    end
    
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
