function mcc = calc_mcc_seq(pred, gt)

% close all
% clear all
% clc
% 
% pred = [0.1 0.3 0.5 0.7 0.9];
% gt = [0 0 1 1 1];

[~,si]=sort(-pred);
tp=(gt(si)==1);
fp=(gt(si)==0);

fp=cumsum(fp);
tp=cumsum(tp);

fn = sum(gt==1) - tp;
tn = sum(gt==0) - fp;

mcc = ((tp.*tn)-(fp.*fn)) ./ (sqrt( (tp+fp).*(tp+fn).*(tn+fp).*(tn+fn) ) +eps);

% recall=tp/sum(gt==1);
% prec=tp./(fp+tp);
% fpr = fp/sum(gt==0);
