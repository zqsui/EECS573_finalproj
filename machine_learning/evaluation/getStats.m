function [p, r, fpr, fscore] = getStats(predLabels, gtLabels)
% Parameter: predLabels, gtLabels
% Return: p, r, fpr, fscore

p = sum((gtLabels==1) & (predLabels==1))./sum(predLabels==1);
r = sum((gtLabels==1) & (predLabels==1))./sum(gtLabels==1);
fpr = sum((gtLabels==0) & (predLabels==1))./sum(gtLabels==0);
fscore = 2*p*r / (p + r);