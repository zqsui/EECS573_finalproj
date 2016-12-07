function [eigen_vector, score, eigen_value] = my_pca(data)
%[eigen_vector, score, eigen_value] = my_pca(data)

%% whitening
data = bsxfun(@minus, data, mean(data));

%% covariance matrix
C = cov(data);

%% eigenvector && eigenvalues
[eigen_vector, eigen_value] = eig(C);
eigen_value = diag(eigen_value);
[eigen_value, eigen_idx] = sort(eigen_value, 'descend');
eigen_vector = eigen_vector(:, eigen_idx);

%% deriving the new dataset
score = eigen_vector' * data';
score = score';