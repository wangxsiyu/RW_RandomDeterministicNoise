datadir = '../../data/EE_blinkCuriosity_2016S/data';
outputdir = '../../data';
%% import EE_16S_blinkCuriosity
W.library_wang('Wang_EEHorizon');
filetemplate = 'P075*horizontask*';
version = 'timestamp_v1';
importfunc = @(x)EEimport_game(x.game, version);
str_subID = {'_sub','_'};
num_subID = [1,3];
str_datetime = {'_','.mat'}; 
num_datetime = [3,1];
subIDrange = [1 200];
outputname = 'EE_blinkCuriosity_2016S';
data = W.IMPORT_datafiles_subID_yyyymmddTHHMMSS(datadir, filetemplate, importfunc, ...
    str_subID, num_subID, str_datetime, num_datetime, subIDrange);
%%
filetemplate = 'P075*demographicinfo*';
importfunc = @(x)assist_import_demo(x, 'demo_siyu_v1');
sub = W_import.IMPORT_datafiles_subID_yyyymmddTHHMMSS(datadir, filetemplate, importfunc, ...
    str_subID, num_subID, str_datetime, num_datetime, subIDrange);
%%
data = W.tab_join(data, sub, {'subjectID', 'date', 'time'});
%%
filetemplate = 'P075*horizontask*';
importfunc = @(x)assist_import_demo(x, 'demo_siyu_v1b');
sub2 = W.IMPORT_datafiles_subID_yyyymmddTHHMMSS(datadir, filetemplate, importfunc, ...
    str_subID, num_subID, str_datetime, num_datetime, subIDrange);
sub2 = sub2(sub2.tasktime > 1,:);
%%
[data] = W.tab_join(data, sub2);
%%
writetable(data, fullfile(outputdir, ['Imported_', outputname, '.csv']));