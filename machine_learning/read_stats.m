function [all_feat, period_feat, sim_flag_count] = read_stats(file_param)

file_prefix = 'data/stats_';
fid = fopen([file_prefix file_param '.txt']);
disp(['Reading file ' file_prefix file_param '.txt'])

sim_flag_count = 0;
tline = fgets(fid);
all_feat = {};
feat_count = 0;

period_feat = {};
temp_feat = {};
while ischar(tline)
    C = strsplit(tline, ' ');
    if length(C) > 3 && strcmp(C{2}, 'Begin') && strcmp(C{3}, 'Simulation')
        sim_flag_count = sim_flag_count + 1;
        disp(['Sim Flag Count: ' num2str(sim_flag_count) ', Feat Count: ' num2str(feat_count)])
        feat_count = 0;
    end
    
    if sim_flag_count >= 2 && length(C) > 2 && ~strcmp(C{2}, 'Begin') && ~strcmp(C{2}, 'End') 
        C = strsplit(tline, ' ');
        all_feat{end+1,1} = C{1};
        all_feat{end,2} = C{2};
        feat_count = feat_count + 1;
        temp_feat{feat_count,1} = C{1};
        temp_feat{feat_count,2} = C{2};
    end
    
    if feat_count == 0 && sim_flag_count > 2
        period_feat{end+1} = temp_feat;
        temp_feat = {};
    end
    
    tline = fgets(fid);
end
% for last temp feat
period_feat{end+1} = temp_feat;

fclose(fid);
sim_flag_count = sim_flag_count - 1;