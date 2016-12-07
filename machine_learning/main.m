close all
clear
clc

addpath(genpath('.'))

train_feat = rand(100,100);
train_label = round(0.75*rand(1,100))';

param = globalParam;
regressor = ml_train(train_feat, train_label, param);

test_feat = rand(1,100);
prob_estimates = ml_test(test_feat, regressor, param);
