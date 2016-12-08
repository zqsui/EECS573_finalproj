

feat = [];
for i = 1:numel(period_feat)
    % filtering features
    temp_period = period_feat{i};
    [C, common_idx, temp_idx] = intersect(common_feat_name, temp_period(:,1));
    temp_feat = zeros(1, length(temp_idx));
    for j = 1:length(temp_feat)
        temp_feat(j) = str2double(temp_period(temp_idx(j), 2));
    end
    temp_feat;
    feat = [feat; temp_feat];
end

