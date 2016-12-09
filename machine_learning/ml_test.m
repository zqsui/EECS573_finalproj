function [pred_output] = ml_test(test_feat, regressor, param)
%[prob_estimates] = ml_test(test_data, ml_model, param)
%test_data must be a single row vector

if strcmp(param.regressor, 'svm')
    [~, ~, pred_output] = predict(zeros(size(test_feat,1),1), sparse(double(test_feat)), regressor, '-b 1 -q');
elseif strcmp(param.regressor, 'rf')
    if param.ml_type == 0
        pred_output = regRF_predict( test_feat, regressor);
    else
        pred_output = classRF_predict( test_feat, regressor);
    end
else
    error('Classifier error')
end