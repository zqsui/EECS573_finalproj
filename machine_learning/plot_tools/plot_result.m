function [max_fscore, max_mcc] = plot_result(pred_result, gt_label, param)
%[max_fscore, max_mcc] = plot_single_session_result(pred_result, gt_label, session_id, param)

%%
[p, r, fpr] = calc_pr_seq_old(pred_result, gt_label);
% calculate f1 score of pr
fscore = 2.*p.*r./(p+r+eps);
[max_fscore, max_fscore_idx] = max(fscore);
% calculate MCC
mcc = calc_mcc_seq(pred_result, gt_label);
[max_mcc, max_mcc_idx] = max(mcc);
% calculate auc of roc
auc = trapz(fpr, r);

% draw figure
h1 = figure;
hold on, grid on
title(sprintf('ML: %s, F1: %.4f, MCC: %.4f',...
    param.regressor, max_fscore, max_mcc))
if param.train_test_type == 1 || param.train_test_type == 2 || param.train_test_type == 3
    axis([0 1 0 1])
    xlabel('Recall')
    ylabel('Precision')
    plot(r, p, 'b')
    plot(r(max_fscore_idx), p(max_fscore_idx), 'ro')
    plot(r(max_mcc_idx), p(max_mcc_idx), 'go', 'MarkerSize', 12)
else
    error('Train test type error.')
end

   
print(h1, '-dpng', '-r100',...
    sprintf('figures/%s_', param.regressor))
    
end


