function mle_model = mle_train(train_feat, train_label)
%class_info = mle_train(train_feat, train_label)

unique_label = unique(train_label);
class_data = cell( 1, numel(unique_label) );

mle_model = cell(numel(unique_label),1);

% mle for each class
for i = 1:numel(unique_label)
    class_label_idx = train_label==unique_label(i);
    class_data{i} = train_feat(class_label_idx,:);
    
    mle_model{i}.label = unique_label(i);

    [mle_model{i}.mu, mle_model{i}.SIGMA] = mle_gaussian(class_data{i}, 0); 
    
    mle_model{i}.prior = size(class_data{i}, 1) / size(train_feat, 1);
    
end