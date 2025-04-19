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