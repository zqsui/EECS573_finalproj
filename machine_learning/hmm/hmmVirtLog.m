function [X, xProb] = hmmVirtLog(Pr0, trans_model, sensor_model)
% Parameters: Pr0, trans_model, sensor_model
% Return: Hidden States X and corresponding probabilities
% This function is implemented based on Rabiner et al.'s HMM tutorial.

% close all
% clear all
% clc
% 
% sensor_model = [.9 .9 .1 .9 .9; .2 .2 .8 .2 .2];
% trans_model = [.7 .3; .3 .7];
% Pr0 = [.5; .5];

% sensor_model = [.5 .4 .1; .1 .3 .6];
% trans_model = [.7 .4; .3 .6];
% Pr0 = [.6; .4];

trans_model_orig = trans_model;
X = zeros(size(sensor_model,2),1);
xProb = zeros(2,size(sensor_model,2));
for i=1:size(sensor_model,2)+1
    if i == 1 % initialization
        PrX = log(sensor_model(:,i)) + log(Pr0);
    elseif i == size(sensor_model,2)+1 % last state
        if PrX(1) == max(PrX)
            X(i-1) = 1;
        else
            X(i-1) = 0;
        end
    else
        if PrX(1) == max(PrX)
            % trans_model = trans_model * [1 0;0 0];
            trans_model = trans_model(:,1);
            curProb = PrX(1);
            X(i-1) = 1;
        else
            % trans_model = trans_model * [0 0;0 1];
            trans_model = trans_model(:,2);
            curProb = PrX(2);
            X(i-1) = 0;
        end
        PrX = [curProb; curProb];
        PrX = (PrX + log(trans_model)) + log(sensor_model(:,i));
        
    end
    trans_model = trans_model_orig;
    xProb(:,i) = PrX;
end




