function [] = test_hp_hog(test_data, ml_model, session_id, param)
%[] = test_bnt(test_data, ml_model, session_id, param)

% close all
% clear
% clc
% param = globalParam();
% test_data = dlmread('./generated_files/test_data.txt');
% load('./generated_files/ml_model.mat')

test_feat = test_data(:, 1:end-1);
gt_label = test_data(:, end);

pred_result = zeros(length(gt_label),1);
% iterate thru each feature vectors
for i = 1:size(test_feat,1)
    head_pose = test_feat(i,1:3);
    hog_feat = test_feat(i,4:end);
    
    % filter all zeros feature
    if all(hog_feat == 0, 2)
        pred_result(i) = 0;
        %         disp('All zeros')
        continue
    end
    
    if param.train_test_type == 1
        %% Single regressor
        if strcmp(param.regressor, 'svm')
            %         fprintf('Model %d\n', h_idx)
            [~, ~, hog_prob_estimates] = predict(0, sparse(hog_feat), ml_model.hog_regressor, '-b 1 -q');
            [~, ~, hp_prob_estimates] = predict(0, sparse(head_pose), ml_model.hp_regressor, '-b 1 -q');
            % multiply head pose and hog prob
            pred_result(i) = hog_prob_estimates(:, 2) * hp_prob_estimates(:, 2);
        elseif strcmp(param.regressor, 'rf')
            %         fprintf('Model %d\n', h_idx)
            pred_result(i) = regRF_predict(hog_feat, ml_model.regressor);
        else
            error('Classifier error')
        end
    elseif param.train_test_type == 2
        %% Multiple regressors
        % head pose assignment
        cluster_ctr = assign_center(head_pose, ml_model.kmean_ctrs);
        % prediction
        if strcmp(param.regressor, 'svm')
            %         fprintf('Model %d\n', h_idx)
            [~, ~, prob_estimates] = predict(0, sparse(hog_feat), ml_model.regressor{cluster_ctr}, '-b 1 -q');
            pred_result(i) = prob_estimates(:,2);
        elseif strcmp(param.regressor, 'rf')
            %         fprintf('Model %d\n', h_idx)
            pred_result(i) = regRF_predict(hog_feat, ml_model.regressor{cluster_ctr});
        else
            error('Classifier error')
        end
    else
        error('Training testing type error')
    end
end

save( sprintf('%spred_result/%s_%s.mat', param.output_path, session_id, param.regressor),...
    'pred_result', 'gt_label')

%%
[p, r, fpr] = calc_pr_seq(pred_result, gt_label);
% calculate f1 score of pr
fscore = 2.*p.*r./(p+r+eps);
[max_fscore, max_fscore_idx] = max(fscore);
% calculate MCC
mcc = calc_mcc_seq(pred_result, gt_label);
[max_mcc, max_mcc_idx] = max(mcc);
% calculate auc of roc
auc = trapz(fpr, r);

if param.use_hmm
    % determine the threshold for the prediction
    pred_label = getThLabel(pred_result, max_fscore_idx);
    
    sensorModel = [pred_label'; ones(1,numel(pred_label)) - pred_label'];
    [hmm_result, hmm_prob] = hmmVirtLog(ml_model.hmm_prior, ml_model.hmm_model, sensorModel);
    save( sprintf('%spred_result/%s_%s_hmm.mat', param.output_path, session_id, param.regressor),...
        'hmm_result', 'gt_label')
    
    % calculate performance
    [hmm_p, hmm_r, hmm_fscore, hmm_mcc] = discrete_label_eval(hmm_result, gt_label);
end

% plot
if param.display_session_result
    h1 = figure;
    hold on, grid on
    title(sprintf('Session: %s, Classifier: %s, F1 score: %.4f, MCC: %.4f',...
        session_id, param.regressor, max_fscore, max_mcc))
    axis([0 1 0 1])
    xlabel('Recall')
    ylabel('Precision')
    plot(r, p, 'b')
    plot(r(max_fscore_idx), p(max_fscore_idx), 'ro')
    plot(r(max_mcc_idx), p(max_mcc_idx), 'go', 'MarkerSize', 12)
    
    % plot hmm result
    if param.use_hmm
        plot(hmm_r, hmm_p, 'ko', 'MarkerSize', 15)
    end
    
    % save figure
    if param.train_test_type == 1
        print(h1, '-dpng', '-r100',...
            sprintf('%sfigures/single/%s/%s_%s_single', param.output_path, param.regressor,...
            session_id, param.regressor))
    elseif param.train_test_type == 2
        print(h1, '-dpng', '-r100',...
            sprintf('%sfigures/multi/%s/%s_%s_%d', param.output_path, param.regressor,...
            session_id, param.regressor, param.k_ctrs))
    else
        error('No train test type')
    end
end