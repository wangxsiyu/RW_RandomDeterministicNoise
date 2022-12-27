function mainpath = W_setdir(version)
    if ~exist('version', 'var') || isempty(version)
        version = '1.0.0';
    end
    [~,sysname] = system('hostname');
    sysname = strip(sysname);
    if ispc
        switch sysname
            case 'DESKTOP-WANG'
                mainpath = 'W:\Wang_Codes\2022_Codes_MATLAB';
            otherwise
                fprintf('error: need to set up Wang22_MATLAB dir for %s\n', sysname);
        end
    elseif ismac
        fprintf('error: need to set up Wang22_MATLAB dir for mac %s\n', sysname);
        mainpath = '';
    end
    mainpath = sprintf("%s/Wang_v%s", mainpath, version);
    fprintf('setting up Wang22_MATLAB dir for PC %s:\n %s\n', sysname, mainpath);
    addpath(genpath(mainpath));
    clear sysname;
end