function [param] = globalParam()
%set up all global params

%% training and testing
param.vote_threshold = 3;   % major votes
% 1: single, 2: multiple regressor based on head poses, 
% 3: random forest only, 4: classification
param.train_test_type = 1; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
param.cluster_type = 2; % 1: hard cluster -- kmean, 2: soft cluster -- gmm
%% K-means
param.k_ctrs = 3; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

param.display_session_result = 0;
param.display_cluster_result = 0;
param.is_save_figure = 0;
param.color = 'rgbmkcy';
% number of test samples
param.num_test = 10;
% debug: -1 0 1
param.debug_tf = -1;
% mode 1, original data; mode 2, pertubed data
param.test_mode = 1;
% head pose 0, +-15, +-30
param.head_pose = 0;

%% Regressor
param.regressor = 'svm'; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Post Processing
param.use_hmm = 0;
%% PCA
param.PCA = 0;
param.pca_dim = 200; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% Fisher GMM Parameters
param.fv_n_center = 8; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% fisher GMM
gmm_param.cov_type = 'diagonal';
gmm_param.options = statset('MaxIter', 300, 'TolFun', 1e-3);
gmm_param.regularize = 0.01;
gmm_param.replicates = 1;
gmm_param.shared_cov = false;
param.gmm_param = gmm_param;

%% SVM parameters
% kernel method parameters
param.svm_type = 0;
param.svm_kernel = 0; % 0 linear; 1 polynomial; 2 rbf
param.svm_degree = 3;
param.svm_coef0 = 0;
param.svm_gamma = 1; % not assigned
% linear kernel parameters
param.svm_w0 = 1;
param.svm_w1 = 1;
param.svm_c = 1;
%% Random Forests parameters
param.rf_iter = 1;
param.rf_ntrees = 100;
param.rf_split = 5;

%% Result and debug
param.pred_label_type = 'f1';





