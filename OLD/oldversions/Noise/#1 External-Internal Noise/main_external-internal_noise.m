load('data_arizona');
gp = group_horizon(data, 'S:\LAB\ANALYSIS\HORIZONTASK\#1 External-Internal Noise\gp_external-internal');
disp(summary);
%%
load('gp_external-internal.mat');
sp = plot_horizon(gp);
%% direct and random exploration
sp.line_direct([],[]);
%%
sp.line_random([],1);
%% disagree
sp.line_disagree([],1);
%% panel
sp.line_modelfree;
%%
sp.line_disagree_theory;
%% choice curve
sp.choice_curve(1);
%% low mean curve
sp.lowmean_curve;
%% disagreement vs dM
sp.agreement_curve;
%% disagreement_lm vs dM
sp.agreement_curve_lm;
%% get bayesian
gp.getbayesian('data_bayesian');

