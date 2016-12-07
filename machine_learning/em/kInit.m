close all
% clear
clc

param = globalParam();
input_data = dlmread('./generated_files/train_data.txt');

gt_label = input_data(:,end);

% separate data
head_pose_data = input_data(:,1:3);

%%
% init = nClusters;
[nData,dim] = size(head_pose_data);
%% K-mean
%{
%}
%% k-mean
init = struct;

[centers, assignments] = ...
    vl_kmeans(head_pose_data',param.k_ctrs,'Initialization','plusplus','Algorithm','Elkan');
assignments = double(assignments);
% [assignments, centers] = kmeans(data, nClusters, 'start', 'uniform', 'emptyaction', 'singleton');

sig = zeros(dim,dim, param.k_ctrs);
for i=1:param.k_ctrs
    sig(:,:,i) = cov( head_pose_data((assignments==i), : ) );
end

init.mu = centers;
init.Sigma = sig;
% initialize weight
R = full( sparse( 1:nData, assignments, 1, nData, param.k_ctrs, nData ) );
N_k = sum(R, 1);
init.weight = N_k ./ nData;

%% em
[label, model, logLH] = em(head_pose_data', init);





