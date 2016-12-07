function [prob_estimates] = ml_test(test_feat, regressor, param)
%[prob_estimates] = ml_test(test_data, ml_model, param)
%test_data must be a single row vector

if strcmp(param.regressor, 'svm')
    [~, ~, prob_estimates] = predict(0, sparse(double(test_feat)), regressor, '-b 1 -q');
elseif strcmp(param.regressor, 'rf')
    temp_prob = regRF_predict( test_feat, regressor);
    prob_estimates = [1-temp_prob temp_prob];
else
    error('Classifier error')
end