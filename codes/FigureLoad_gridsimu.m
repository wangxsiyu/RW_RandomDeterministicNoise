function rdsp = FigureLoad_gridsimu(griddir)
%%
randetsp = {{},{}};
for i = 0:10
    for j = 0:10
        W.print('%d,%d', i,j);
        tfilename = sprintf('HBI_DetRanNoise_simugrid_ran%d_det%d_samples.mat', i, j);
        tsp = load(fullfile(griddir, tfilename)).samples;
        randetsp{1}{i+1,j+1} = mean(tsp.NoiseRan, 3);
        randetsp{2}{i+1,j+1} = mean(tsp.NoiseDet, 3);
    end
end
%%
rdsp = {};
rdsp{1} = W.cellfun(@(x)reshape(x, [],1), randetsp{1}, false);
rdsp{2} = W.cellfun(@(x)reshape(x, [],1), randetsp{2}, false);
end