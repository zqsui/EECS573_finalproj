function [prec, recall, fpr] = calc_pr_seq_old(pred, gt)
% calculate Prec and Recall 
% sort the input first, so that PR is decreasing
% Parameter: pred, gt
% Return prec, recall, fpr

[~,si]=sort(-pred);
tp=(gt(si)==1);
fp=(gt(si)==0);

fp=cumsum(fp);
tp=cumsum(tp);
recall=tp/sum(gt==1);
prec=tp./(fp+tp);
fpr = fp/sum(gt==0);