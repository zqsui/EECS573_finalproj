function [f1_ret, mcc_ret, auc] = calc_var_eval(pred_result, test_label)
%[f1, mcc, auc] = calc_var_eval(pred_result, test_label)

[prec, recall, fpr] = calc_pr_seq(pred_result, test_label);
% calculate f1 score of pr
fscore = 2.*prec.*recall./(prec+recall+eps);
[max_fscore, max_fscore_idx] = max(fscore);
% calculate MCC
mcc = calc_mcc_seq(pred_result, test_label);
[max_mcc, max_mcc_idx] = max(mcc);
% calculate auc of roc
auc = trapz(fpr, recall);

f1_ret.score = max_fscore;
f1_ret.idx = max_fscore_idx;

mcc_ret.score = max_mcc;
mcc_ret.idx = max_mcc_idx;