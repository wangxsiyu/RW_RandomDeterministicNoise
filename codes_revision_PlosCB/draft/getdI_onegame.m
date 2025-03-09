function out = getdI_onegame(cs, rs, p_mu_obs)
    posteriors = ones(2, 99)/99;
    for i = 1:4
        c = cs(i);
        posteriors(c,:) = update_bayes(posteriors(c,:), rs(i), p_mu_obs);
    end

    out = getdI(posteriors);
end
function posterior = update_bayes(prior, obs, p_mu_obs)
    likelihood = p_mu_obs(:, obs)';
    posterior = prior .* likelihood;
    posterior = posterior ./ sum(posterior);
end
function dI = getdI(posteriors)
    mus = 1:99;
    Is = nan(1,2);
    for i = 1:2
        pmfs = posteriors(i, :);
        tvar = sum((mus.^2) .* pmfs) - (sum(mus .* pmfs))^2;
        Is(i) = sqrt(tvar);
    end
    dI = diff(Is);
end

