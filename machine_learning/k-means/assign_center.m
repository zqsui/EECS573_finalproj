function assigned_ctrs = assign_center(features, centers)
%assigned_ctrs = assign_center(features, centers)

% rand_idx = randperm(size(feature,2), param.rand_sample);
% feature = feature(:,rand_idx);

assigned_ctrs = zeros(1, size(features,1));
for i = 1:size(features,1) 
    % vectorize!!!
    C = bsxfun(@minus, double(features(i,:)), centers);
    feat_dist = sqrt(sum(C'.^2, 1));
    [~, assigned_ctrs(i)] = min(feat_dist);
end
