function pred_label = mle_predict(test_feat, mle_model)
%pred_label = mle_test(test_feat, mle_model)

unique_label = zeros(numel(mle_model),1);
pred_g = zeros(size(test_feat,1), numel(mle_model));
for i = 1:numel(mle_model)
    pred_g(:,i) = discriminant_func(test_feat, mle_model{i}.prior, mle_model{i}.mu, mle_model{i}.SIGMA);
    unique_label(i) = mle_model{i}.label;
end

[~, I] = max(pred_g, [], 2);
pred_label = zeros(size(pred_g,1),1);
for i = 1:numel(I)
    pred_label(i) = unique_label(I(i));
end