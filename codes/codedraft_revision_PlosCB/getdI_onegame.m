function out = getdI_onegame(cs, rs)
    rs = rs(1:4);
    cs = cs(1:4);
    v2 = var(rs(cs == 2));
    v1 = var(rs(cs == 1));
    out = -(v2 - v1);
end
