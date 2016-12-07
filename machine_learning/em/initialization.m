function R = initialization(data, init)

[~, nData] = size(data);
if isstruct(init)  % initialize with a model
    R  = expectation(data,init);
    
elseif length(init) == 1  % random initialization
    nClusters = init;
    kCenter = randsample(nData, nClusters);
    m = data(:, kCenter);
    % initialization x*mu - 0.5mu^2
    [~, labelIdx] = max( bsxfun( @minus, m'*data, dot(m,m,1)'/2 ), [], 1 );
    [u,~,labelIdx] = unique(labelIdx);
    
    while nClusters ~= length(u)
        kCenter = randsample(nData,nClusters);
        m = data(:,kCenter);
        [~,labelIdx] = max(bsxfun(@minus,m'*data,dot(m,m,1)'/2),[],1);
        [u,~,labelIdx] = unique(labelIdx);
    end
    
    R = full( sparse( 1:nData, labelIdx, 1, nData, nClusters, nData ) );
    
else
    error('ERROR: init is not valid.');
end