function st = getMAP(sp)
    varnames = {'Infobonus_sub', 'bias_sub', 'NoiseRan_sub', 'NoiseDet_sub'};
    for vi = 1:length(varnames)
        vn = varnames{vi};
        if ~isfield(sp, vn)
            continue;
        end
        tval = sp.(vn);
        if vi <=2
            [~,~,sz1,sz2] = size(tval);
            tout = nan(sz1,sz2);
            for i = 1:sz1
                for j = 1:sz2
                    tout(i,j) = findMAP(tval(:,:,i,j));
                end
            end
        else
            [~,~,sz1,sz2,sz3] = size(tval);
            tout = nan(sz1,sz2,sz3);
            for i = 1:sz1
                for j = 1:sz2
                    for k = 1:sz3
                        tout(i,j,k) = findMAP(tval(:,:,i,j,k));
                    end
                end
            end
        end
        st.(vn) = tout;
    end
end