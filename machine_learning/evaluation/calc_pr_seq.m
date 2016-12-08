function [prec, recall, fpr, thresh] = calc_pr_seq(pred, gt, n)
% calculate Prec and Recall 
% sort the input first, so that PR is decreasing
% Parameter: pred, gt
% Return prec, recall, fpr, thresh

if nargin < 3
    min_val = min( pred(pred~=0) );
    n = 1/min_val;
%     n = 500;
end

pred = round(pred*n);


[~,si]=sort(-pred);
pred = pred(si);
[~, idx] = unique(pred);

tp=(gt(si)==1);
fp=(gt(si)==0);

fp=cumsum(fp);
tp=cumsum(tp);
recall=tp(idx)/sum(gt==1);
prec=tp(idx)./(fp(idx)+tp(idx));
fpr = fp(idx)/sum(gt==0);

thresh = pred(idx)./n;