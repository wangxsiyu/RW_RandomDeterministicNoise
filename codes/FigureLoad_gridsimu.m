function rdsp = FigureLoad_gridsimu(griddir, rans)
%%
randetsp = {{},{}};
for ii = 1:length(rans)
    i = rans(ii);
    for j = 0:10
        W.print('%d,%d', i,j);
        tfilename = sprintf('HBI_DetRanNoise_simugrid_ran%d_det%d_samples.mat', i, j);
        if ~exist(fullfile(griddir, tfilename), 'file')
            W.print('file not exists: ran %d, det %d', i, j);
            continue;
        end
        tsp = load(fullfile(griddir, tfilename)).samples;
        randetsp{1}{ii,j+1} = mean(tsp.NoiseRan, 3);
        randetsp{2}{ii,j+1} = mean(tsp.NoiseDet, 3);
    end
end
%%
rdsp = {};
rdsp{1} = W.cellfun(@(x)reshape(x, [],1), randetsp{1}, false);
rdsp{2} = W.cellfun(@(x)reshape(x, [],1), randetsp{2}, false);
end