function [] = test_temp(test_data, ml_model, session_id, param)
% [] = test_bnt(test_data, ml_model, session_id, param)

% close all
% clear
% clc
% param = globalParam();
% temp_load = load('./generated_files/temp_load.mat');
% test_data = temp_load.test_data;
% load('./generated_files/ml_model_fv.mat')
% session_id = 'RA148';

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
        temp_data = ml_model.fv_eigen_vector * hog_feat';
        test_set = fisherCoding(ml_model.fv_gmm, temp_data)';
        prob_estimates = ml_test(test_set, ml_model.regressor, param);
        pred_result(i) = prob_estimates(:,2);
    elseif param.train_test_type == 2
        %% Multiple regressors
        if ml_model.em_model.NComponents ~= param.k_ctrs % sanity check
            error('EM Model Error')
        end
        % head pose prediction using gmm
        gm_llh = posterior(ml_model.em_model, head_pose);
        % cluster_ctr = assign_center(head_pose, ml_model.kmean_ctrs);
        regressor_result = zeros(param.k_ctrs, 2);
        % iterate through each regressor
        for k = 1:param.k_ctrs
            prob_estimates = ml_test(hog_feat, ml_model.regressor{k}, param);
            regressor_result(k,:) = prob_estimates;
        end
        % gmm cluster * each regressor
        prob_em_regressor = gm_llh * regressor_result;
        pred_result(i) = prob_em_regressor(:,2);
    elseif param.train_test_type == 3 && strcmp(param.regressor, 'rf')
        pred_result(i) = regRF_predict(test_feat(i,:), ml_model.regressor);
    elseif param.train_test_type == 4 % classification instead of regression
        if strcmp(param.regressor, 'svm')
            [~, ~, prob_estimates] = predict(0, sparse(hog_feat), ml_model.classifier, '-b 1 -q');
            pred_result(i) = prob_estimates(:,2);
        elseif strcmp(param.regressor, 'rf')
            pred_result(i) = classRF_predict(hog_feat, ml_model.classifier);
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
if param.train_test_type == 1 || param.train_test_type == 2 || param.train_test_type == 3
    [p, r, fpr] = calc_pr_seq(pred_result, gt_label);
    % calculate f1 score of pr
    fscore = 2.*p.*r./(p+r+eps);
    [max_fscore, max_fscore_idx] = max(fscore);
    % calculate MCC
    mcc = calc_mcc_seq(pred_result, gt_label);
    [max_mcc, max_mcc_idx] = max(mcc);
    % calculate auc of roc
    auc = trapz(fpr, r);
elseif param.train_test_type == 4
    [p, r, fpr, max_fscore, max_mcc] = discrete_label_eval(pred_result, gt_label);
else
    error('Train test type error.')
end

if param.use_hmm
    % determine the threshold for the prediction
    pred_label = getThLabel(pred_result, max_fscore_idx);
    
    sensorModel = [pred_label'; ones(1,numel(pred_label)) - pred_label'];
    [hmm_result, hmm_prob] = hmmVirtLog(ml_model.hmm_prior, ml_model.hmm_model, sensorModel);
    save( sprintf('%spred_result/%s_%s_hmm.mat', param.output_path, session_id, param.regressor),...
        'hmm_result', 'gt_label')
    
    % calculate performance
    [hmm_p, hmm_r, ~, hmm_fscore, hmm_mcc] = discrete_label_eval(hmm_result, gt_label);
end

% plot
if param.display_session_result
    h1 = figure;
    hold on, grid on
    title(sprintf('Session: %s, ML: %s, Rand: %d, F1: %.4f, MCC: %.4f',...
        session_id, param.regressor, param.num_rand, max_fscore, max_mcc))
    if param.train_test_type == 1 || param.train_test_type == 2 || param.train_test_type == 3
        axis([0 1 0 1])
        xlabel('Recall')
        ylabel('Precision')
        plot(r, p, 'b')
        plot(r(max_fscore_idx), p(max_fscore_idx), 'ro')
        plot(r(max_mcc_idx), p(max_mcc_idx), 'go', 'MarkerSize', 12)
    elseif param.train_test_type == 4
        axis([0.5 2.5 0 1])
        xlabel('F1, MCC')
        ylabel('Unitless')
        bar([max_fscore, max_mcc])
    else
        error('Train test type error.')
    end
    
    % plot hmm result
    if param.use_hmm
        plot(hmm_r, hmm_p, 'ko', 'MarkerSize', 15)
    end
    
    % save figure
    if param.train_test_type == 1 || param.train_test_type == 3 || param.train_test_type == 4
        print(h1, '-dpng', '-r100',...
            sprintf('%sfigures/single/%s/%s_%s_single_%d', param.output_path, param.regressor,...
            session_id, param.regressor, param.num_rand))
    elseif param.train_test_type == 2
        print(h1, '-dpng', '-r100',...
            sprintf('%sfigures/multi/%s/%s_%s_%d_%d', param.output_path, param.regressor,...
            session_id, param.regressor, param.k_ctrs, param.num_rand))
    else
        error('No train test type')
    end
end