function [prec, recall, fprate, pred_result, model] = ...
    rf_ml_eval(train_feat, train_label, test_feat, test_label, param)
%[prec, recall, fprate, pred_result, model] = rf_ml_eval(train_feat, train_label, test_feat, test_label, param)

% close all
% clc

prec = zeros(numel(test_label), 1);
recall = zeros(numel(test_label), 1);
fprate = zeros(numel(test_label), 1);
pred_result = zeros(numel(test_label), 1);

%% RF training/testing
disp('RF')
for i = 1:param.rf_iter
    % model = classRF_train(train_feat, train_label, 100, 4);
    % predLabel = classRF_predict(test_feat, model);
    model = regRF_train(train_feat, train_label, param.rf_ntrees, param.rf_split);
%     model = regRF_train(train_feat, train_label, param.rf_ntrees);
    pred_label = regRF_predict(test_feat, model);
    
    [p, r, fpr] = calc_pr_seq(pred_label, test_label);
    prec = prec + p;
    recall = recall + r;
    fprate = fprate + fpr;
    pred_result = pred_result + pred_label;
end

prec = prec / param.rf_iter;
recall = recall / param.rf_iter;
fprate = fprate / param.rf_iter;
pred_result = pred_result / param.rf_iter;
