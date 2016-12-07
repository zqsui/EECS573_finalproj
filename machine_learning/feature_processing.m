function [train_feat, test_feat] = feature_processing(train_feat, test_feat, param)

%% PCA
if param.PCA
    fprintf('PCA %d: ', param.pca_dimension)
    tic
    % [eigen_vector, score, eigen_value] = my_pca([train_feat; test_feat]);

    % train_feat = score(1:size(train_feat,1), 1:param.pca_dimension);
    % test_feat = score(size(train_feat,1)+1:end, 1:param.pca_dimension);
    
    [eigen_vector, train_score, eigen_value] = my_pca(train_feat);
    train_feat = train_score(:, 1:param.pca_dimension);
    test_score = my_pca_compress(eigen_vector, test_feat);
    test_feat = test_score(:, 1:param.pca_dimension);
    
    pca_time = toc;
    fprintf('%.2f\n', pca_time)
    %% Debug PCA visualization
%     visualize_pca(train_feat, train_label);
    
end

%% K-mean clustering
if param.kmeans
    disp('K-means')
    % [kIdx, kctrs] = kmeans([train_feat; test_feat], param.k);
    [kctrs, kIdx] = vl_kmeans([train_feat; test_feat]', param.k,...
        'Initialization','plusplus','Algorithm','Elkan');
    kctrs = kctrs';
    %% assign centers
    for i = 1:numel(kIdx)
        if i <= size(train_feat, 1)
            train_feat(i,:) = kctrs( kIdx(i),: );
        else
            test_feat(i-size(train_feat, 1),:) = kctrs( kIdx(i),: );
        end
    end
end


