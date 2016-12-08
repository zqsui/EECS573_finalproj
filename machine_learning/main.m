close all
% clear
clc

addpath(genpath('.'))

%% reading data
tic
% data = dlmread('data/data_without_heading.csv');
% data(:,335) = [];
train_idx = randperm(size(data,1), round(0.6*size(data,1)) );
test_idx = 1:size(data,1);
test_idx(train_idx) = [];

train_data = data(train_idx, :);
train_feat = train_data(:, 1:end-1);
train_label = train_data(:, end);

test_data = data(test_idx, :);
test_feat = test_data(:, 1:end-1);
test_label = test_data(:, end);
fprintf('Reading data: %.3f sec\n', toc)


%% training and testing
param = globalParam;
regressor = ml_train(train_feat, train_label, param);

prob_estimates = ml_test(test_feat, regressor, param);
importance = regressor.importance;
bar(importance)
[~, max_feat_idx] = max(importance);

[max_fscore, max_mcc] = plot_result(prob_estimates(:,2), test_label, param);