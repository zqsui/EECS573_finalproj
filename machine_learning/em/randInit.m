close all
% clear all
clc

%%
img = imread('party_spock.png');
img = imresize(img, 0.75);
data = im2double(img);
data = reshape(data, 1, numel(data));

nClusters = 3;
% init = nClusters;
maxiter = 20;
[d, nData] = size(data);
%% K-mean
%{
tic
[kIdx, kctrs] = kmeans(data, nClusters);
toc
sig = zeros(d,d,nClusters);
for i=1:nClusters
    sig(:,:,i) = cov(data((kIdx==i)));
end

init.mu = kctrs';
init.Sigma = sig;
% initialize weight
R = full( sparse( 1:nData, kIdx, 1, nData, nClusters, nData ) );
N_k = sum(R, 1);
init.weight = N_k ./ nData;
%}

%%
kStart = [3 5 8];
score = zeros(3, maxiter);
labelArr = zeros(3, maxiter, nData);
modelArr = cell(3, maxiter);

matlabpool open local 4
parfor k = 1:3
    for iter = 1:maxiter
        disp(iter)
        [label, model, logLH] = em(data, kStart(k));
        score(k, iter) = logLH(end);
        
        labelArr(k, iter, :) = label;
        modelArr{k, iter} = model;
    end
end
matlabpool close

% [Y, I]=min(BIC, [], 1);
% [BIC_max, J]=min(Y);
% I(J), J

%%

avgscore = mean(score, 2);
figure, hold on
axis([0.5 3.5 0 9*10^4])
title('Random Initialization')
bar(avgscore)

% [kV, kIdx] = min(score, [], 2);
% hist(kV, 8)

% figure, hold on
% title('Histogram of Random Initialization')
% hist(score(:))

% for histK = 1:3
%
%     figure, hold on
%     title(kStart(histK))
%     hist(score(histK,:))
%
% end

% hist(score(1,:));
% mean(score(1,:));

%%
% bestLabel = labelArr(I,J,:);
% bestModel = modelArr{I,J};
% segments = zeros(size(img));
% for i = 1:numel(bestLabel)
%     segments(i) = bestModel.mu(bestLabel(i));
% end
%
% figure, imshow(segments)


