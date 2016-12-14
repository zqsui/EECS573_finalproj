function [pred_label, test_label, importance] = train_test_single(data, param)

tic
train_idx = randperm(size(data,1), round(param.train_test_split*size(data,1)) );
test_idx = 1:size(data,1);
test_idx(train_idx) = [];

train_data = data(train_idx, :);
train_feat = train_data(:, 1:end-1);
train_label = train_data(:, end);

test_data = data(test_idx, :);
test_feat = test_data(:, 1:end-1);
test_label = test_data(:, end);
fprintf('Reading data: %.3f sec\n', toc)


%% training and testing

regressor = ml_train(train_feat, train_label, param);

pred_label = ml_test(test_feat, regressor, param);

importance = regressor.importance;