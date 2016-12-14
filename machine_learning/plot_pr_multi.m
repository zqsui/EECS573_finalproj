% function [max_fscore, max_mcc] = plot_pr_multi(pred_result, gt_label, param)
%[max_fscore, max_mcc] = plot_pr_multi(pred_result, gt_label, session_id, param)

%%
addpath(genpath('.'))

param = globalParam;
temp_load = load('result/different_input.mat');
pred_result = temp_load.all_pred;
gt_label = temp_load.all_test;

% % calculate f1 score of pr
% fscore = 2.*p.*r./(p+r+eps);
% [max_fscore, max_fscore_idx] = max(fscore);
% % calculate MCC
% mcc = calc_mcc_seq(pred_result, gt_label);
% [max_mcc, max_mcc_idx] = max(mcc);
% % calculate auc of roc
% auc = trapz(fpr, r);

input_dir = dir('data/data_different_input/*.csv');
label_name = cell(1,length(input_dir));
all_pred = cell(length(input_dir));
all_test = cell(length(input_dir));
for i = 1:length(input_dir)
    fprintf('Processing file# %d \n', i)
    [~, fname, ~] = fileparts(input_dir(i).name);
    C = strsplit(fname, '_');
    label_name{i} = C{4};
end
% draw figure
h1 = figure;
hold on, grid on
title(sprintf('ML: %s, different Input',...
    param.regressor))
if param.train_test_type == 1 || param.train_test_type == 2 || param.train_test_type == 3
    axis([0 1 0 1])
    xlabel('Recall')
    ylabel('Precision')
    for i = 1:length(temp_load.all_pred)
        [p, r, fpr] = calc_pr_seq_old(pred_result{i}, gt_label{i});
        if i==1
            plot(r, p, '--', 'LineWidth', 3)
        else
            plot(r, p, 'LineWidth', 3)
        end
    end
    %     plot(r(max_fscore_idx), p(max_fscore_idx), 'ro')
    %     plot(r(max_mcc_idx), p(max_mcc_idx), 'go', 'MarkerSize', 12)
else
    error('Train test type error.')
end
legend(label_name, 'Location', 'Best')

print(h1, '-dpng', '-r100',...
    sprintf('figures/%s_feat_comp', param.regressor))


