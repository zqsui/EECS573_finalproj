function [mu, SIGMA] = mle_gaussian(input_data, isBiased)
%[mu, sigma] = mle_gaussian(input_data, isBiased)

%% calculate mu
mu = sum(input_data, 1) ./ size(input_data,1);

%% calculate covariance
temp = bsxfun(@minus, input_data, mu);
% vectorize temp
temp = temp';

unbiased_sigma = (temp * temp') ./ (size(input_data,1) - 1);
biased_sigma = (temp * temp') ./ size(input_data,1);

% vectorize mu
mu = mu';
if isBiased
    SIGMA = biased_sigma;
else
    SIGMA = unbiased_sigma;
end