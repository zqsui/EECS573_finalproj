function [tp, fp, tn, fn] = confusion_matrix(pred, gt)
% calculate Prec and Recall 
% Parameter: pred, gt
% Return prec, recall, fpr

% pred = [1; 0; 1; 0; 1];
% gt = [0; 0; 1; 0; 1];

temp = gt .* pred;
tp = numel(find(temp == 1));
temp = gt - pred;
fp = numel(find(temp == -1));
fn = numel(find(temp == 1));

temp= gt + pred;
tn = numel(find(temp == 0));