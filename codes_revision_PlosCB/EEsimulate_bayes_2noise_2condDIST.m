function out = EEsimulate_bayes_2noise_2condDIST(data, As, bs, nrans, ndets)
    disp(['Generating simulation']);
    % if length(size(ndets)) == 2
    %     ndets = repmat(reshape(ndets, 1, 2, []),2,1,1);
    % end
    % if length(size(nrans)) == 2
    %     nrans = repmat(reshape(nrans, 1, 2, []),2,1,1);
    % end
    
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
            tA = reshape(As(:,:, horizon(gi), si),1,[]);
            tb = reshape(bs(:,:, horizon(gi), si),1,[]);
            if length(size(nrans)) == 5
                tdne = reshape(nrans(:,:, horizon(gi), infocond(gi), si),1,[]);
            else
                tdne = reshape(nrans(:,:, infocond(gi), si),1,[]);
            end
            if length(size(ndets)) == 5
                tdni = reshape(ndets(:,:, horizon(gi), infocond(gi), si),1,[]);
            else
                tdni = reshape(ndets(:,:, infocond(gi), si),1,[]);
            end
            tid = randperm(length(tA),1);
            tid2 = randperm(length(tA),1);
            tdni = tdni(tid);

            
            if tdne(tid2) > 0
                pdni = makedist('Logistic',0, tdne(tid2));
                dni = random(pdni);
            else
                dni = 0;
            end
            if isnan(n_det(repeatID(gi)))
                if tdni > 0
                    pdne = makedist('Logistic',0, tdni);
                    n_det(repeatID(gi)) = random(pdne);
                else
                    n_det(repeatID(gi)) = 0;
                end
            end
            tid3= randperm(length(tA),1);
            tid4 = randperm(length(tA),1);
        


            dQ = dR(gi) + tA(tid3) * dI(gi) +  tb(tid4) + dni + n_det(repeatID(gi));
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