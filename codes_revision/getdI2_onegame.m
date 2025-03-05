function out = getdI2_onegame(cs, rs)
    v2 = var(rs(cs == 2));
    v1 = var(rs(cs == 1));
    out = -(v2 - v1);
end
