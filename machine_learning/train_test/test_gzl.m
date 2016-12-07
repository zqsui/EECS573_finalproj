function [pred_result, gt_label] = test_gzl(test_data, ml_model, param)
%[pred_result, gt_label] = test_gzl(test_data, ml_model, param)

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
    
    % PCA
    pca_feat = (ml_model.pca_eigen_vector' * appearance_feat')';
    if size(pca_feat,2) ~= param.pca_dim
        error('PCA Dimension Error.')
    end
    
    % LDA
    mda_feat = [1 pca_feat] * ml_model.lda_W';
    
    %% Single regressor
    prob_estimates = ml_test(mda_feat, ml_model.regressor, param);
    pred_result(i) = prob_estimates(:,2);
    
end


