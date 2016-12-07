function [vec] = fisherCoding(gmm, X, theta)
%[vec] = fisherCoding(gmm, X, theta)
% X should be a set of column vector

% param
if nargin<3
    theta = 1e-4;
end

% get all params from gmm
dim = size(X, 1);
w = gmm.PComponents;
K = length(w);
mu = gmm.mu';
sigma2 = reshape(gmm.Sigma, [dim, K]);
sigma = sqrt(sigma2);

% precomputation
d0 = sqrt(w);
d1 = bsxfun(@times, d0, sigma);
d2 = bsxfun(@times, sqrt(2).*d0, sigma2);


% get the posterior
R = posterior(gmm, X');

% renormalizie the posterior
R(R<theta) = 0;
R = bsxfun(@rdivide, R, (sum(R, 2)+eps));
T = size(X, 2);

% counters
S0 = sum(R, 1)./T;
S1 = X*R./T;
S2 = (X.^2)*R./T;

% descriptor
G0 = (S0 - w)./d0;

G1 = S1 - bsxfun(@times, mu, S0);
G1 = G1./(d1+eps);

G2 = S2 - 2.*mu.*S1; 
G2 = (G2 + bsxfun(@times, (mu.^2 - sigma2), S0))./d2;


% l2 normalization and lp norm
vec = [G0(:); G1(:); G2(:)];
vec = sign(vec).*sqrt(abs(vec));
vec = vec./(norm(vec)+eps);

