function resp = simulate_responses(x,model,dMat,logflag)
%function RESP = simulate_responses(X,MODEL,DMAT,LOGFLAG) simulates responses of
%bayesian observer
%
% ============ INPUT VARIABLES ============
% X: parameter values. vector of length six
%       'bayes': [Jbar_high, Jbar_low, tau, sigma_d, p_change, lambda]
%       'freq': [Jbar_high, Jbar_low, tau, sigma_d, bias, lambda]
%       'freq2': [Jbar_high, Jbar_low, tau, sigma_d, bias, lambda]
% MODEL: model name. string
%       'bayes' (bayes optimal),'pt' (pt estimate), 'optpt'
%       (pt estimate w/ optimal condition-specific decision criteria)
% DMAT: data. nTrials x 8 matrix
%       first four columns correspond to amount of orientation change for
%       each item. second four columns correspond to the reliability of
%       each item.
% LOGFLAG: log flag. binary vector of length six
%       indicates which parameters are in log scaling
%
% ============ OUTPUT VARIABLES ============
% RESP: 1xnTrials vector of simulated responses

persistent k_range
persistent J_lin
persistent highest_J

if nargin < 4; logflag = []; end

x(logflag) = exp(x(logflag));

% start off with lapse
lapserate = x(end);
nTrials = size(dMat,1);
islapse = rand(1,nTrials) < lapserate;
lapserespVec = rand(1,sum(islapse)) > 0.5;      % for lapse trials, flip a coin
resp = nan(length(islapse),1);
resp(islapse) = lapserespVec;

if sum(~islapse) % if there are any trials that did not lapse
    
    % reduce dMat to only include nonlapse trials
    dMat = dMat(~islapse,:);
    
    % define data stuff
    nTrials = size(dMat,1);
    nItems = 4;
    Delta = dMat(:,1:nItems);           % amount change for each of four items
    Rels = dMat(:,(nItems+1):end);      % reliabilities for each item (1: low, 2: high)
    nRelsVec = sum(Rels==2,2);
    
    % ===== GET PARAMETER VALUES ======
    Jbar_high = x(1);
    Jbar_low = x(2);
    tau = x(3);
    sigma_d = x(4);
    k = x(5);
    
    % ====== CALCULATE P(\HAT{C}==1|\Theta) FOR nSamples SAMPLES =====
    
    % make CDF for interpolating J to Kappa
    if isempty(k_range)
        tempp = load('cdf_table.mat');
        % K_interp = tempp.K_interp;
        % cdf = tempp.cdf;
        k_range = tempp.k_range;
        J_lin = tempp.J_lin;
        highest_J = tempp.highest_J;
    end
    
    % calculate actual kappa and noisy representations
    Jbar_mat = Rels;
    Jbar_mat(Rels==1) = Jbar_low;
    Jbar_mat(Rels==2) = Jbar_high;
    
    J_x_mat = gamrnd(Jbar_mat./tau,tau);
    J_y_mat = gamrnd(Jbar_mat./tau,tau);
    
    % set kappas too high to highest J (alternatively can resample, as
    % keshvari did)
    J_x_mat(J_x_mat > highest_J) = highest_J;
    J_y_mat(J_y_mat > highest_J) = highest_J;
    
    % convert J to kappa
    xi = 1/diff(J_lin(1:2))*J_x_mat+1;
    kappa_x_i = k_range(round(xi));
    xi = 1/diff(J_lin(1:2))*J_y_mat+1;
    kappa_y_i = k_range(round(xi));
    
    if size(kappa_x_i,2) ~= nItems
        kappa_x_i = kappa_x_i';
        kappa_y_i = kappa_y_i';
    end
    
    % generate measurement noise
    noise_x = circ_vmrnd(0,kappa_x_i);
    noise_y = circ_vmrnd(0,kappa_y_i);
    
    % get difference between noise
    delta_noise = noise_x-noise_y;
    
    % the term inside denominator bessel function for d_i
    Kc = bsxfun(@times,2.*kappa_x_i.*kappa_y_i,cos(bsxfun(@plus,Delta,delta_noise))); % note: it is okay to simply add the noise bc it goes through a cos!!
    Kc = sqrt(bsxfun(@plus,kappa_x_i.^2+kappa_y_i.^2,Kc)); % dims: mat_dims
    
    % d_i
    switch model
        case 'bayes'
            d_i_Mat = bsxfun(@minus,log(besseli(0,kappa_x_i,1).*besseli(0,kappa_y_i,1))+...
                (kappa_x_i+kappa_y_i),log(besseli(0,Kc,1))+Kc); % actually log d_i_Mat
            p_C_hat = log(sum(exp(d_i_Mat),2))-log(nItems)+log(k)-log(1-k);  % these values are actually log(d), not p_C_hat
%             p_C_hat = log(sum(exp(d_i_Mat),2))-log(nItems);  % these values are actually log(d), not p_C_hat
            p_C_hat = p_C_hat + randn(size(p_C_hat)).*sigma_d;    % global dec noise
            p_C_hat = p_C_hat > 0; %k     % respond 1 if log(d) > log(1)
        case 'freq' % point estimate model
            d_Mat = squeeze(max(kappa_x_i + kappa_y_i - Kc,[],2));
            p_C_hat = d_Mat > k; % respond 1 if bias term
        case 'freq2' % optimal point estimate model
            dec_rule = calculate_optimaldecisioncriteria(x(1:3));
            d_Mat = squeeze(max(kappa_x_i + kappa_y_i - Kc,[],2));
            p_C_hat = nan(size(d_Mat));
            for irel = 1:5;
                nrel = irel-1;
                idx = nRelsVec == nrel;
                p_C_hat(idx) = dMat(idx)>(dec_rule(irel)+k);
            end
            

    end
    resp(~islapse) = p_C_hat;
end

end
