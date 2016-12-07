function [W] = MDA(data, labels)
%[W] = MDA(data, labels)


data = data';
n_ctrs = length(unique(labels));

M_all = zeros(size(data,1), 1);
for i = 1:n_ctrs
    Xi = data(:,labels==i);
    M_all = M_all + mean(Xi, 2);
end
M_all = M_all ./ n_ctrs;

Sw = zeros(size(data,1), size(data,1));
Sb = zeros(size(data,1), size(data,1));
for i = 1:n_ctrs
    Xi = data(:,labels==i);
    
    Mi = mean(Xi, 2);
    
    Swi = cov(Xi');
    Sw = Sw + Swi;
    
    Sbi = size(Xi,2) .* (Mi-M_all) * (Mi-M_all)';
    Sb = Sb + Sbi;
end

invSw_by_Sb = Sw \ Sb;
[V, D] = eig(invSw_by_Sb);
W = V;