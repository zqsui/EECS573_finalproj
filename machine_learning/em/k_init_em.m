function [label, gmm, kmean_init] = k_init_em(data, n_centers, param, gmm_param)
%[label, gmm, kmean_init] = k_init_em(data, n_centers, param, gmm_param)

%{
close all
clear
clc
param = globalParam();
% train_data = dlmread('./generated_files/train_data.txt');
input_data = train_data(:,1:end-1);
gt_label = train_data(:,end);
% process head pose data -- tilt angle
input_data = fix_tilt( input_data );
data_idx = randperm(size(input_data,1), 10000);
data = input_data(data_idx, 1:3);
%}
%

if nargin < 4
    gmm_param.cov_type = 'full';
    gmm_param.options = statset('MaxIter', 500, 'TolFun', 1e-5);
    gmm_param.regularize = 0;
    gmm_param.replicates = 1;
    gmm_param.shared_cov = false;
end

[nData,dim] = size(data);
%% k-means initialize
tic
fprintf('Start k-mean %d centers...', n_centers)
[centers, assignments] = ...
    vl_kmeans(data',n_centers,'Initialization','plusplus');
kmean_time = toc;
fprintf('%.4f sec\n', kmean_time)
assignments = double(assignments);
% [assignments, centers] = kmeans(data, nClusters, 'start', 'uniform', 'emptyaction', 'singleton');

% assign covariance matrix
if isequal(gmm_param.cov_type, 'full')
    sig = zeros(dim, dim, n_centers);
elseif isequal(gmm_param.cov_type, 'diagonal')
    sig = zeros(1, dim, n_centers);
else
    error('No such cov type.')
end
% iterate through each center
for i=1:n_centers
    if isequal(gmm_param.cov_type, 'full')
        sig(:,:,i) = cov( data((assignments==i), : ) );
    elseif isequal(gmm_param.cov_type, 'diagonal')
        sig(:,:,i) = var( data((assignments==i), : ), 0, 1 ); % matlab var normalization done
    else
        error('No such cov type.')
    end
end

kmean_init.assignments = assignments;
kmean_init.mu = centers';
kmean_init.Sigma = sig;
% initialize weight
R = full( sparse( 1:nData, assignments, 1, nData, n_centers, nData ) );
N_k = sum(R, 1);
kmean_init.PComponents = N_k ./ nData;

%{
%% em
[label, gmm, logLH] = em(data', init);
%}
%% matlab EM-GMM
fprintf('Start EM %d centers...', n_centers)
tic
gmm = gmdistribution.fit(data, n_centers, 'Start', kmean_init,...
    'CovType', gmm_param.cov_type, 'Regularize', gmm_param.regularize,...
    'Replicates', gmm_param.replicates, 'SharedCov', gmm_param.shared_cov,...
    'Options', gmm_param.options);
label = cluster(gmm, data);
gmm_time = toc;
fprintf('%.4f sec\n', gmm_time);

%% visualize clusters
if param.display_cluster_result
    figure, hold on
    for i = 1:numel(unique(label))
        temp_idx = (label == i);
        scatter3(data(temp_idx, 1), data(temp_idx, 2), data(temp_idx, 3),...
            10, 'MarkerEdgeColor', param.color(i), 'MarkerFaceColor', param.color(i));
    end
    hold off
end


