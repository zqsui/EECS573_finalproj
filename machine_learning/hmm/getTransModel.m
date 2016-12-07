%% Parameter: original label
function ret = getTransModel(labels)
% Parameter: labels
% Return: transition model [00 10; 10 11]

transit_1 = 0;
transit_2 = 0;
transit_3 = 0;
transit_4 = 0;

for i = 1:length(labels)-1
    cur_pair = [labels(i) labels(i+1)];
    if isequal(cur_pair, [0 0])
        transit_1 = transit_1 + 1;
    elseif isequal(cur_pair, [0 1])
        transit_2 = transit_2 + 1;
    elseif isequal(cur_pair, [1 0])
        transit_3 = transit_3 + 1;
    elseif isequal(cur_pair, [1 1])
        transit_4 = transit_4 + 1;
    end
end

pair_size = length(labels)-1;
transit_1 = transit_1 / pair_size;
transit_2 = transit_2 / pair_size;
transit_3 = transit_3 / pair_size;
transit_4 = transit_4 / pair_size;

%% normalization
row1 = transit_1 + transit_2;
row2 = transit_3 + transit_4;
transit_1 = transit_1 / row1;
transit_2 = transit_2 / row1;
transit_3 = transit_3 / row2;
transit_4 = transit_4 / row2;

ret = [transit_1, transit_3;...
    transit_2, transit_4];
