function [label, model, logLH] = em(data, init)

R = initialization(data, init);
[~, label(1,:)] = max(R, [], 2);
R = R(:,unique(label));
%%

tol = 1e-5;
maxiter = 500;
logLH = -inf(1, maxiter);
converged = false;
iter = 1;
while ~converged && iter < maxiter
    iter = iter+1;
    model = maximization(data, R);
    [R, logLH(iter)] = expectation(data, model);
    
    [~, label(:)] = max(R, [], 2); % update label
    u = unique(label);   % non-empty components
    
    if size(R,2) ~= size(u,2)
        R = R(:,u);   % remove empty components
    else % evaluation
        converged = logLH(iter)-logLH(iter-1) < tol*abs(logLH(iter));
    end
end

logLH = logLH(2:iter);

if converged
    fprintf('Converged in %d steps.\n',iter-1);
else
    fprintf('Not converged in %d steps.\n',maxiter);
end