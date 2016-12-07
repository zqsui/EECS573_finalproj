function g = discriminant_func(test_data_feat, prior, mu, SIGMA)
%g = discriminant_func(test_data_feat, prior, mu, sigma)

g = zeros(size(test_data_feat, 1) ,1);
for i = 1:size(test_data_feat, 1)
    x = test_data_feat(i,:);
    x = x';
    %% calculate gaussian pdf
    C = -(length(x)/2) * log(2*pi) - (1/2) * log(det(SIGMA));
    g_x = (-1/2) * (x-mu)' / SIGMA * (x-mu) + log(prior) + C;
    g(i) = g_x;
end