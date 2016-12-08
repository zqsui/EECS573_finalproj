function discrete_label = get_discrete_label(pred_result, threshold)
%discrete_label = get_discrete_label(pred_result, threshold)


discrete_label = pred_result;
discrete_label(pred_result >= threshold) = 1;
discrete_label(pred_result < threshold) = 0;    

end