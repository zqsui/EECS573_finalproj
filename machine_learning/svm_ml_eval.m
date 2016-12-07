function [p, r, fpr, pred_result, model] =...
    svm_ml_eval(train_feat, train_label, test_feat, test_label, param)
% function [p, r, fpr, pred_result, model] = svm_ml_eval(train_feat, train_label, test_feat, test_label, param)

%{
close all
clear
clc

load ./data/hog_train.mat
load ./data/hog_test.mat
param = globalParam();
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SVM training/testing
if param.svm_kernel == 0
    disp('liblinear')
    model = train(train_label, sparse(train_feat),...
        sprintf('-s l2 -w0 %d -w1 %d -c %d -q', param.svm_w0, param.svm_w1, param.svm_c));
    [pred_label, accuracy, prob_estimates] = predict(test_label, sparse(test_feat), model, '-b 1');
else
    disp('libsvm')
    model = svmtrain(train_label, train_feat,...
        sprintf('-s %d -t %d -d %d -r %d -w0 %d -w1 %d -h 0 -b 1 -q',...
        param.svm_type, param.svm_kernel, param.svm_degree, param.svm_coef0, param.svm_w0, param.svm_w1));
    [pred_label, accuracy, prob_estimates] = ...
        svmpredict(test_label, test_feat, model, '-b 1');
end
%% calculate results
[p, r, fpr] = calc_pr_seq(prob_estimates(:,2), test_label);
pred_result = prob_estimates(:,2);

%% plot curve

% figure, grid on, hold on
% axis([0 1 0 1])
% title('PR Curve');
% plot(r, p, 'LineWidth', 1)
%
% figure, grid on, hold on
% axis([0 1 0 1])
% title('ROC Curve', 'LineWidth', 5)
% plot(fpr, r)
% % draw the by chance ROC
% x = 0:.1:1;
% y = x;
% plot(x,y,'--','color','r');
