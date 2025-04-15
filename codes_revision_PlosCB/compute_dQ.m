function loss = compute_dQ(samples, c)
    dQ = samples.dQ;
    cnum = sum(~isnan(c), 'all');
    loss = [];
    for ci = 1:size(dQ,1)
        for si = 1:size(dQ, 2)
            te = squeeze(dQ(ci, si, :,:));
            te = sign(te);
            te(te == 0) = NaN;
            loss(ci, si) = (sum(te(c == 1)) - sum(te(c == 0)))/cnum;
        end
    end
end