close all
% clear
clc

addpath(genpath('.'))

param = globalParam;
param.regressor = 'rf';
param.ml_type = 0;
train_test_split = 0.6;
%% reading data
tic
data = dlmread('data/data_feat_all.csv');
if param.ml_type == 0
    data = [data(:, 1:end-2) data(:, end)]; % binary
else
    data = data(:, 1:end-1); % multi-class
end
% data(:,end) = randi(5, [size(data,1),1])-1;
% data(:,335) = [];

train_idx = randperm(size(data,1), round(train_test_split*size(data,1)) );
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

regressor = ml_train(train_feat, train_label, param);

pred_label = ml_test(test_feat, regressor, param);

importance = regressor.importance;
bar(importance)
[~, max_feat_idx] = max(importance);

if param.ml_type == 0
    [max_fscore, max_mcc] = plot_result(pred_label, test_label, param);
else
    [~, order] = confusionmat(test_label, pred_label);
    C = confusionMatrix2(pred_label+1, test_label+1, ...
        {'Correct','GeneralFetchInjected','LoadStoreInjected','ExecutionInjected','OpCodeInjected'});
end
