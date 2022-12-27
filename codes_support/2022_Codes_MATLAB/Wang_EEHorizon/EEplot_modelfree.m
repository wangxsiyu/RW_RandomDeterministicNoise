function plt = EEplot_modelfree(plt, gp, isreverse, varargin)
    if ~exist('isreverse', 'var')
        isreverse = 0;
    end
    if isreverse 
        ps = [2 1];
    else
        ps = [1 2];
    end
    for pi = 1:2
        switch ps(pi)
            case 1
                plt = EEplot_phi(plt, gp);
            case 2
                plt = EEplot_plm(plt, gp, varargin{:});
        end
        plt.new;
    end
    plt.update('modelfree');
end