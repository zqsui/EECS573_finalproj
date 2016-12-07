function [ml_model] = train_gzl(train_data, param)
%[ml_model] = train_gzl(train_data, param)

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
%% single regressor training
if param.feat_size-4 ~= size(feature_data, 2) % sanity check
    error('Feature size does not match with training data.')
end

%% Clustering
n_ctrs = 6;
tic
fprintf('Start k-mean %d centers...', n_ctrs)
[~, assignments] = ...
    vl_kmeans(feature_data', n_ctrs, 'Initialization','plusplus');
kmean_time = toc;
fprintf('%.4f sec\n', kmean_time)
assignments = double(assignments);

%% PCA
fprintf('Start PCA %d dimension...', param.pca_dim)
tic
[eigen_vector, score, ~] = pca(feature_data);
if param.pca_dim > size(feature_data, 2)
    warning('PCA dimension exceeds the data dimension')
end
% eliminate dimensions
eigen_vector = eigen_vector(:, 1:param.pca_dim);
% centering
% feature_data = bsxfun(@minus, feature_data, mean(feature_data));
% pca_data = (eigen_vector' * feature_data')';
pca_data = score(:, 1:param.pca_dim);

pca_time = toc;
fprintf('%.4f sec\n', pca_time)

%% MDA
% W = MDA(pca_data, assignments);
W = LDA(pca_data, assignments);
mda_data = [ones(size(pca_data,1),1) pca_data] * W';
%% training
ml_model.regressor = ml_train(mda_data, gt_label, param);
ml_model.pca_eigen_vector = eigen_vector;
ml_model.lda_W = W;

ml_time = toc;
fprintf('Regressor Training Time: %.4f sec\n', ml_time)

