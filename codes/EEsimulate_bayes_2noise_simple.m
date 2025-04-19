function out = EEsimulate_bayes_2noise_simple(data, As, bs, nrans, ndets)
    disp(['Generating simulation']);
    
    if size(ndets, 2) == 1
        ndets = repmat(ndets, 2, 1);
    end
    if size(nrans, 2) == 1
        nrans = repmat(nrans, 2, 1);
    end
    for si = 1:data.nSubject
        choice = [];
        nT = data.nTrial(si);
        dR = data.dR(si,1:nT)';
        dI = data.dI(si,1:nT)';
        repeatID = data.repeatID(si,1:nT)';
        horizon = data.horizon(si,1:nT)';
        infocond = data.infocond(si, 1:nT)';
        n_det = NaN(1, data.nrepeatID(si));
        for gi = 1:nT
            if nrans(horizon(gi), si) > 0
                pdni = makedist('Logistic',0, nrans(horizon(gi), si));
                dni = random(pdni);
            else
                dni = 0;
            end
            if isnan(n_det(repeatID(gi)))
                if ndets(horizon(gi), si) > 0
                    pdne = makedist('Logistic',0, ndets(horizon(gi), si));
                    n_det(repeatID(gi)) = random(pdne);
                else
                    n_det(repeatID(gi)) = 0;
                end
            end
            dne = n_det(repeatID(gi));
            dQ = dR(gi) + As(horizon(gi), si) * dI(gi) + bs(horizon(gi), si) + dne + dni;
            if dQ > 0
                choice(gi) = 1;
            else
                choice(gi) = 0;
            end
        end
        data.choice(si, :) = W.extend(choice, size(data.choice, 2));
    end
    out = data;
end