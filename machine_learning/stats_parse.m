close all
clear
clc

file_param = 'cpt1';
[all_feat, period_feat, sim_flag_count] = read_stats(file_param);
[C,ia,ic] = unique(all_feat(:,1));

[count,~]=hist(ic, unique(ic));
common_feat_idx = ic(count == sim_flag_count);

common_feat_name = all_feat(common_feat_idx, 1);
common_feat_val = all_feat(common_feat_idx, 2);


% file_param = 'injected';
% feat_2 = read_stats(file_param);
% 
% [C, i1, i2] = intersect(feat_1(:,1), feat_2(:,1));
% i1 = sort(i1, 'ascend');
% i2 = sort(i2, 'ascend');