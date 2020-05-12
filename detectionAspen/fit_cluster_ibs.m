function fit_cluster_ibs(idx,nReps)

% load subject, model, fitting options and bounds
load('fittingsettings.mat')

% ========= DATA/MODEL INFO ========

% fitting settings (determined by index)
[isubj,imodel,irep] = ind2sub([nSubjs nModels nReps],idx)
subjid = subjidVec{isubj};
model = modelVec{imodel};

% load data

load(sprintf('/Volumes/GoogleDrive/My Drive/Research/VSTM/Aspen Luigi - Reliability in VWM/Exp 5 - Keshvari replication and extension/data/fitting_data/%s_Ellipse_simple.mat',...
    subjid))
% load(sprintf('../data/fitting_data/%s_Ellipse_simple.mat',subjid))

% data in ibs format
dMat = data.Delta;
rels = unique(data.rel);
blah = data.rel;
for irel = 1:length(rels)
    blah(blah == rels(irel)) = irel;
end
dMat = [dMat blah];

% ========= FITTING INFORMATION ========

% getting model fitting settings
% logflag = logflag.(model);
% LB = LB.(model);
% UB = UB.(model);
% PLB = PLB.(model);
% PUB = PUB.(model);
LB(logflag) = log(LB(logflag));
UB(logflag) = log(UB(logflag));
PLB(logflag) = log(PLB(logflag));
PUB(logflag) = log(PUB(logflag));

% generate x0s for all reps
rng(0); 
nvars = numel(PLB);
x0_list = lhs(nReps,nvars,PLB,PUB,[],1e3);

% ============ FIT THE DATA =========
rng(irep);
x0 = x0_list(irep,:);

fun = @(x,dMat) simulate_responses(x,model,dMat,logflag);
[xbest,LL] = bads(@(x) ibslike(fun,x,data.resp,dMat,options_ibs),x0,LB,UB,PLB,PUB,[],options)

xbest(logflag) = exp(xbest(logflag)); % getting parameters back into natural units

save(sprintf('fits/model%s_subj%s_rep%d.mat',model,subjid,irep),...
    'options','xbest','LL')