function pred_label = getThLabel(pred_result, max_idx)
%pred_label = getThLabel(pred_result, max_idx)

a = sort(pred_result, 'descend');
pred_th = a(max_idx);
% generate pred_label
pred_label = pred_result;
pred_label(pred_result >= pred_th) = 1;
pred_label(pred_result < pred_th) = 0;

end