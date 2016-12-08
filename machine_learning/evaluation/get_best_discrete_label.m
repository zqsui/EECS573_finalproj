function [discrete_label, threshold] = get_best_discrete_label(pred_result, test_label, pred_label_type)
%[discrete_label, threshold] = get_best_discrete_label(pred_result, test_label, pred_label_type)


% param = globalParam();
%%
[prec, recall, fpr, thresh] = calc_pr_seq(pred_result, test_label);
% calculate f1 score of pr
fscore = 2.*prec.*recall./(prec+recall+eps);
[max_fscore, max_fscore_idx] = max(fscore);
% calculate MCC
mcc = calc_mcc_seq(pred_result, test_label);
[max_mcc, max_mcc_idx] = max(mcc);
% calculate auc of roc
auc = trapz(fpr, recall);

%% confusion matrix
% max f1
[temp_pred_result, temp_pred_result_idx] = sort(pred_result, 'descend');
max_f1_result = pred_result;
max_f1_result(max_f1_result > thresh(max_fscore_idx)) = 1;
max_f1_result(max_f1_result <= thresh(max_fscore_idx)) = 0;
%  max_f1_result(max_f1_result >= 0.5) = 1;
%  max_f1_result(max_f1_result < 0.5) = 0;
% [max_f1_tp, max_f1_fp, max_f1_tn, max_f1_fn] =...
%     confusion_matrix(max_f1_result, test_label);
% fprintf('Max F1 Confusion Matrix -- GT Pos: %d Neg: %d\nTP: %d, FP: %d, TN: %d, FN: %d\n',...
%     numel(test_label(test_label == 1)), numel(test_label(test_label == 0)),...
%     max_f1_tp, max_f1_fp, max_f1_tn, max_f1_fn);

% max mcc
%{
max_mcc_result = pred_result;
max_mcc_result(temp_pred_result >= thresh(max_mcc_idx)) = 1;
max_mcc_result(temp_pred_result < thresh(max_mcc_idx)) = 0;
%}
% [max_mcc_tp, max_mcc_fp, max_mcc_tn, max_mcc_fn] =...
%     confusion_matrix(max_mcc_result, test_label(temp_pred_result_idx));
% fprintf('Max MCC Confusion Matrix: -- GT Pos: %d Neg: %d\nTP: %d, FP: %d, TN: %d, FN: %d\n',...
%     numel(test_label(test_label == 1)), numel(test_label(test_label == 0)),...
%     max_mcc_tp, max_mcc_fp, max_mcc_tn, max_mcc_fn);

if strcmp(pred_label_type, 'f1')
    discrete_label = max_f1_result;
    threshold = thresh(max_fscore_idx);
elseif strcmp(pred_label_type, 'mcc')
    discrete_label = max_mcc_result;
    threshold = thresh(max_mcc_idx);
else
    error('No such prediction label type.')
end
