function [regressor_model] = ml_train(train_feat, train_label, param)
%[regressor_model] = ml_train(train_data, train_label, param)

tic
if strcmp(param.regressor, 'svm')
    fprintf('Using SVM\n')
    regressor_model = train(train_label, sparse(train_feat),...
        sprintf('-s l2 -w0 %d -w1 %d -c %d -q', param.svm_w0, param.svm_w1, param.svm_c));
elseif strcmp(param.regressor, 'rf')
    fprintf('Using Random Forests\n')
    regressor_model = regRF_train(train_feat, train_label, param.rf_ntrees, param.rf_split);
else
    error('Regressor error')
end
ml_time = toc;
fprintf('ML Training Time: %.4f sec\n', ml_time)