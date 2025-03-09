function out = EEsimulate_bayes_ONLYnoise(data, nrans, ndets)
    disp(['Generating simulation']);
    if size(ndets, 2) == 1
        ndets = repmat(ndets, 1, 2);
    end
    if size(nrans, 2) == 1
        nrans = repmat(nrans, 1, 2);
    end
    for si = 1:data.nSubject
        choice = [];
        nT = data.nTrial(si);
        repeatID = data.repeatID(si,1:nT)';
        horizon = data.horizon(si,1:nT)';
        n_det = NaN(1, data.nrepeatID(si));
        for gi = 1:nT
            if nrans(si, horizon(gi)) > 0
                pdni = makedist('Logistic',0, nrans(si, horizon(gi)));
                dni = random(pdni);
            else
                dni = 0;
            end
            if isnan(n_det(repeatID(gi)))
                if ndets(si, horizon(gi)) > 0
                    pdne = makedist('Logistic',0, ndets(si, horizon(gi)));
                    n_det(repeatID(gi)) = random(pdne);
                else
                    n_det(repeatID(gi)) = 0;
                end
            end
            dne = n_det(repeatID(gi));
            dQ = dne + dni;
            choice(gi) = dQ;
        end
        data.choice(si, :) = W.extend_nan(choice, size(data.choice, 2));
    end
    out = data;
end