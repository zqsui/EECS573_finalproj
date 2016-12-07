function score = my_pca_compress(eigen_vector, data)
%function [eigen_vector, score, eigen_value] = my_pca(data)

%% whitening
data = bsxfun(@minus, data, mean(data));

%% deriving the new dataset
score = eigen_vector' * data';
score = score';