function st = getMAPsimple(sp)
    varnames = {'Infobonus_sub', 'bias_sub', 'NoiseRan_sub', 'NoiseDet_sub'};
    for vi = 1:length(varnames)
        vn = varnames{vi};
        tval = sp.(vn);
        [~,~,sz1,sz2] = size(tval);
        tout = nan(sz1,sz2);
        for i = 1:sz1
            for j = 1:sz2
                tout(i,j) = findMAP(tval(:,:,i,j));
            end
        end
        st.(vn) = tout;
    end
end
function x = findMAP(v)
    v = reshape(v, 1, []);
    vx = linspace(min(v), max(v), 1000);
    dx = mean(diff(vx), 'all');
    stv = std(v);
    one = ones(length(v),1);
    val = sum1d(one, v', stv, dx, min(v), max(v));
    [~, tid] = max(val);
    x = vx(tid);
end