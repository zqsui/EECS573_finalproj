function ap = calc_ap(p, r)
%ap = calc_ap(p, r)

r_idx = 0:0.1:1;
p_sum = 0;

[r, p_idx] = sort(r, 'ascend');
p = p(p_idx);

for i = 1:length(r_idx)
    r_diff = bsxfun(@minus, r, r_idx(i));
    I = find(r_diff >= 0);
    if isempty(I)
        p_temp = 0;
    else % p_interp = max p(~r)
        p_temp = max(p(I));
    end
    % find corresponding p and sum it up.
    p_sum = p_sum + p_temp;
    
end
% take the average
ap = p_sum / length(r_idx)