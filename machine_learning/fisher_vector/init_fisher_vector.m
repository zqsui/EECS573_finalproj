function [eigen_vector, gmm] = init_fisher_vector(data, pca_dim, param)
%[eigen_vector, gmm] = init_fisher_vector(data, pca_dim, param)
%data must be a row vector

%{
close all
clear
clc
param = globalParam();
temp_load = load('./generated_files/train_data.mat');
train_data = temp_load.train_data;

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
data = feature_data;
%}

%% PCA
% compress data by half of its dimensionalities
fprintf('Start PCA %d dimension...', pca_dim)
tic
[eigen_vector, ~, ~] = pca(data);
if pca_dim > size(data, 2)
    warning('PCA dimension exceeds the data dimension')
end
eigen_vector = eigen_vector(:, 1:pca_dim)';
data = (eigen_vector*data')';
pca_time = toc;
fprintf('%.4f sec\n', pca_time)

%% EM clustering head pose
% initialize EM parameters
[~, gmm] = k_init_em(data, param.fv_n_center, param, param.gmm_param);


%{
tic
priors = gmm.PComponents;
K = length(priors);
mu = gmm.mu';
covariance = reshape(gmm.Sigma, [dim, K]);
fisher_vector_1 = vl_fisher(test_data, mu, covariance, priors, 'Improved');
toc
%}



