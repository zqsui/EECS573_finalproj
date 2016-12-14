close all
% clear
clc

addpath(genpath('.'))

param = globalParam;
param.regressor = 'rf';
param.ml_type = 0;
param.train_test_split = 0.6;

%% reading data

input_dir = dir('data/data_different_input/*.csv');
label_name = cell(1,length(input_dir));
all_pred = cell(length(input_dir));
all_test = cell(length(input_dir));
for i = 1:length(input_dir)
    fprintf('Processing file# %d \n', i)
    [~, fname, ~] = fileparts(input_dir(i).name);
    C = strsplit(fname, '_');
    label_name{i} = C{4};
    tic
    data = dlmread(['data/data_different_input/' input_dir(i).name]);
    
%     if param.ml_type == 0
%         data = [data(:, 1:end-2) data(:, end)]; % binary
%     else
%         data = data(:, 1:end-1); % multi-class
%     end

    [pred_label, test_label] = train_test_single(data, param);
    [max_fscore, max_mcc] = plot_result(pred_label, test_label, param);

    all_pred{i} = pred_label;
    all_test{i} = test_label;
end

save('result/different_input.mat', 'all_pred', 'all_test')

% if param.ml_type == 0
%     [max_fscore, max_mcc] = plot_result(pred_label, test_label, param);
% else
%     [~, order] = confusionmat(test_label, pred_label);
%     C = confusionMatrix2(pred_label+1, test_label+1, ...
%         {'Correct','GeneralFetchInjected','LoadStoreInjected','ExecutionInjected','OpCodeInjected'});
% end
