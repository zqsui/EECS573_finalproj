function [R, logLH] = expectation(data, model)
mu = model.mu;
Sigma = model.Sigma;
pi = model.weight;

n = size(data, 2);
k = size(mu, 2);
logRho = zeros(n, k);

for i = 1:k
    logRho(:,i) = loggausspdf(data, mu(:,i), Sigma(:,:,i));
%     logRho(:,i) = log(normpdf(data, mu(:,i), sqrt(Sigma(:,:,i))));
end

logRho = bsxfun(@plus, logRho, log(pi));

T = logsumexp(logRho, 2);

logLH = sum(T); % log-likelihood

logR = bsxfun(@minus, logRho, T);

R = exp(logR);
