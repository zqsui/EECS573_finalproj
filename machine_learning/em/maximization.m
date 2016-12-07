function model = maximization(data, R)

[d,n] = size(data);
k = size(R, 2);

N_k = sum(R, 1);
pi_k = N_k / n;
mu_k = bsxfun(@times, data*R, 1./N_k);

Sigma = zeros(d,d,k);
sqrtR = sqrt(R);
for i = 1:k
    Xo = bsxfun(@minus, data, mu_k(:,i));
    Xo = bsxfun(@times, Xo, sqrtR(:,i)');
    Sigma(:,:,i) = Xo * Xo' / N_k(i);
    Sigma(:,:,i) = Sigma(:,:,i)+eye(d)*(1e-6); % add a prior for numerical stability
end

model.mu = mu_k;
model.Sigma = Sigma;
model.weight = pi_k;
