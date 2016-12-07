function [max_fscore, max_mcc, auc] = test_alg(hog_feat, gt_label, head_pose_data, param, method, regressor)
%[max_fscore, max_mcc, auc] = test_alg(hog_feat, gt_label, head_pose_data, param, method, regressor)

% load pre-trained models
load('./models/head_model.mat')
if strcmp(regressor, 'svm')
    fprintf('Using SVM\n')
    load('./models/svm_eye_head_model.mat')
elseif strcmp(regressor, 'rf')
    fprintf('Using Random Forests\n')
    load('./models/rf_eye_head_model.mat')
else
    error('Classifier error')
end

pred_result = zeros(size(hog_feat, 1),1);
%% Testing Data Collecting
for i =1:size(hog_feat, 1)
    % check for lost face
    if all(hog_feat(i,:) == 0, 2)
        pred_result(i) = 0;
        continue
    end
    
    % extract test feature
    feat = hog_feat(i,:);
    
    % model check
    if numel(eye_head_model)~=numel(head_model)
        error('Model size does not match')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(method, 'discrete')
        % Discrete Model
        %     test_head_pred_label = mle_predict(-double(head_pose_data(i,2)), head_model);
        test_head_pred_label = mle_predict(-double(head_pose_data(i,2)), head_model);
        
        % choose the eye feature regressor based on the predicted head pose
        h_model = eye_head_model{ param.head_pose_list == test_head_pred_label };
        %     fprintf('Using Head Pose Model: %d \n',...
        %         param.head_pose_list(param.head_pose_list==test_head_pred_label));
        
        if strcmp(regressor, 'svm')
            [~, ~, prob_estimates] = predict(0, sparse(feat), h_model, '-b 1 -q');
            pred_result(i) = prob_estimates(:,2);
        elseif strcmp(regressor, 'rf')
            pred_result(i) = regRF_predict(feat, h_model);
        else
            error('Classifier error')
        end
    elseif strcmp(method, 'bnt')
        % Bayesian Network
        eye_prob = zeros(numel(eye_head_model),1);
        head_prob = zeros(numel(head_model),1);
        prob_sum = 0;
        for k = 1:numel(eye_head_model)
            h_model = eye_head_model{k};
            if strcmp(regressor, 'svm')
                [~, ~, prob_estimates] = predict(0, sparse(feat), h_model, '-b 1 -q');
                eye_prob(k) = prob_estimates(:,2);
            elseif strcmp(regressor, 'rf')
                eye_prob(k) = regRF_predict(feat, h_model);
            else
                error('Classifier error')
            end
            
            head_prob(k) = normpdf(-double(head_pose_data(i,2)), head_model{k}.mu, sqrt(head_model{k}.SIGMA));
            prob_sum = prob_sum + eye_prob(k)*head_prob(k);
        end
        % store prediction
        pred_result(i) = prob_sum;
    else
        error('Method error')
    end
    
end
test_time = toc;
fprintf('Testing Time: %.2f\n', test_time)
save( sprintf('%spred_result/%s_%s_%s.mat', param.output_path, param.session_name, method, regressor),...
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

% plot
figure, hold on
title(sprintf('Method: %s, Classifier: %s, F1 score: %.4f, MCC: %.4f', method, regressor, max_fscore, max_mcc))
axis([0 1 0 1])
xlabel('Recall')
ylabel('Precision')
plot(r, p, 'b')
plot(r(max_fscore_idx), p(max_fscore_idx), 'ro')
plot(r(max_mcc_idx), p(max_mcc_idx), 'go', 'MarkerSize', 12)
