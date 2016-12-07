function [pred_result, gt_label] = test_bnt(test_data, ml_model, param)
%[pred_result, gt_label] = test_bnt(test_data, ml_model, param)

%{
close all
clear
clc
param = globalParam();
test_data = dlmread('./generated_files/test_data.txt');
load('./generated_files/ml_model.mat')
session_id = 'RA148';
%}

test_feat = test_data(:, 1:end-1);
if param.feat_size-1 ~= size(test_feat, 2)
    error('Training and testing feature mismatch.')
end
gt_label = test_data(:, end);

pred_result = zeros(length(gt_label),1);
% iterate thru each feature vectors
for i = 1:size(test_feat,1)
%     head_pose = test_feat(i,1:3);
    head_pose = test_feat(i,2:3); % remove roll dimension
    appearance_feat = test_feat(i,4:end);
    
    % filter all zeros feature
    if all(appearance_feat == 0, 2)
        pred_result(i) = 0;
        %         disp('All zeros')
        continue
    end
    
    if param.train_test_type == 1
        %% Single regressor
        prob_estimates = ml_test(appearance_feat, ml_model.regressor, param);
        pred_result(i) = prob_estimates(:,2);
        
    elseif param.train_test_type == 2
        %% Multiple regressors
        if ml_model.em_model.NComponents ~= param.k_ctrs % sanity check
            error('EM Model Error')
        end
        if param.cluster_type == 1
            % head pose prediction using kmean
            assigned_label = assign_center(head_pose, ml_model.kmean_model.mu);
            prob_estimates = ml_test(appearance_feat, ml_model.regressor{assigned_label}, param);
            pred_result(i) = prob_estimates(:,2);
        elseif param.cluster_type == 2        
            % head pose prediction using gmm
            gm_llh = posterior(ml_model.em_model, head_pose);
            regressor_result = zeros(param.k_ctrs, 2);
            % iterate through each regressor
            for k = 1:param.k_ctrs
                prob_estimates = ml_test(appearance_feat, ml_model.regressor{k}, param);
                regressor_result(k,:) = prob_estimates;
            end
            % gmm cluster * each regressor
            prob_em_regressor = gm_llh * regressor_result;
            pred_result(i) = prob_em_regressor(:,2);
        else
            error('No such cluster type')
        end
    elseif param.train_test_type == 3 && strcmp(param.regressor, 'rf')
        pred_result(i) = regRF_predict(test_feat(i,:), ml_model.regressor);
    elseif param.train_test_type == 4 % classification instead of regression
        if strcmp(param.regressor, 'svm')
            [~, ~, prob_estimates] = predict(0, sparse(appearance_feat), ml_model.classifier, '-b 1 -q');
            pred_result(i) = prob_estimates(:,2);
        elseif strcmp(param.regressor, 'rf')
            pred_result(i) = classRF_predict(appearance_feat, ml_model.classifier);
        else
            error('Classifier error')
        end
    else
        error('Training testing type error')
    end
end


