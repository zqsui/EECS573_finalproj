function [p, r, fpr, fscore, mcc] = discrete_label_eval(discrete_label, test_label)
%[p, r, fpr, fscore, mcc] = discrete_label_eval(discrete_label, test_label)

[tp, fp, tn, fn] = confusion_matrix(discrete_label, test_label);
p = tp / (tp + fp + eps);
r = tp / (tp + fn + eps);
fpr = fp / (fp + tn + eps);
fscore = (2*tp) / (2*tp + fp + fn + eps);
mcc = ((tp.*tn)-(fp.*fn)) ./ (sqrt( (tp+fp).*(tp+fn).*(tn+fp).*(tn+fn) ) +eps);

end