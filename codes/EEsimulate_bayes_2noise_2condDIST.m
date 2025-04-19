function out = EEsimulate_bayes_2noise_2condDIST(data, As, bs, nrans, ndets)
    disp(['Generating simulation']);
    for si = 1:data.nSubject
        choice = [];
        nT = data.nTrial(si);
        dR = data.dR(si,1:nT)';
        dI = data.dI(si,1:nT)';
        repeatID = data.repeatID(si,1:nT)';
        horizon = data.horizon(si,1:nT)';
        infocond = data.infocond(si, 1:nT)';
        n_det = NaN(1, data.nrepeatID(si));
        tA = nan(1,2);
        tb = nan(1,2);
        for h = 1:2
            te = reshape(As(:,:, h, si),1,[]); 
            tA(h) = mean(te);
            te = reshape(bs(:,:, h, si),1,[]); 
            tb(h) = mean(te);
        end
        nsample = size(As,1) * size(As,2);
        if length(size(nrans)) == 5
            tran = nan(2,2);
            for h = 1:2
                for c = 1:2
                    te = reshape(nrans(:,:, h, c, si),1,[]);
                    tid = randperm(nsample);
                    tran(h, c) = te(tid(1));
                end
            end
        else
            tran = nan(2,2);
            for c = 1:2
                te = reshape(nrans(:,:, c, si),1,[]);
                tid = randperm(nsample);
                tran(1, c) = te(tid(1));
                tran(2, c) = tran(1, c);
            end
        end
        if length(size(ndets)) == 5
            tdet = nan(2,2);
            for h = 1:2
                for c = 1:2
                    te = reshape(ndets(:,:, h, c, si),1,[]);
                    tid = randperm(nsample);
                    tdet(h, c) = te(tid(1));
                end
            end
        else
            tdet = nan(2,2);
            for c = 1:2
                te = reshape(ndets(:,:, c, si),1,[]);
                tid = randperm(nsample);
                tdet(1, c) = te(tid(1));
                tdet(2, c) = tdet(1, c);
            end
        end
        for gi = 1:nT
            ttA = tA(horizon(gi));
            ttb = tb(horizon(gi));
            ttran = tran(horizon(gi), infocond(gi));
            ttdet = tdet(horizon(gi), infocond(gi));
            if  ttran > 0
                pdni = makedist('Logistic',0, ttran);
                dni = random(pdni);
            else
                dni = 0;
            end
            if isnan(n_det(repeatID(gi)))
                if ttdet > 0
                    pdne = makedist('Logistic',0, ttdet);
                    n_det(repeatID(gi)) = random(pdne);
                else
                    n_det(repeatID(gi)) = 0;
                end
            end
            dQ = dR(gi) + ttA * dI(gi) + ttb + dni + n_det(repeatID(gi));
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