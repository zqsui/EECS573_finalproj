close all
% clear
clc

addpath(genpath('.'))

param = globalParam;
param.regressor = 'rf';
param.ml_type = 0;
param.train_test_split = 0.6;
%% reading data
tic
data = dlmread('data/data_same_input/data_same_input_all.csv');
% if param.ml_type == 0
%     data = [data(:, 1:end-2) data(:, end)]; % binary
% else
%     data = data(:, 1:end-1); % multi-class
% end
% data(:,end) = randi(5, [size(data,1),1])-1;
% data(:,335) = [];

[pred_label, test_label, importance] = train_test_single(data, param);
figure, bar(importance)
[~, max_feat_idx] = max(importance);

if param.ml_type == 0
    [max_fscore, max_mcc] = plot_result(pred_label, test_label, param);
else
    [~, order] = confusionmat(test_label, pred_label);
    C = confusionMatrix2(pred_label+1, test_label+1, ...
        {'Correct','GeneralFetchInjected','LoadStoreInjected','ExecutionInjected','OpCodeInjected'});
end
