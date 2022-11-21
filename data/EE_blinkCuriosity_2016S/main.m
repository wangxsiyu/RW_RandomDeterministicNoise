function main(option_time, option_test, option_eye)
if ~exist('option_time') || option_time < 0
    option_time = 0;
end
if ~exist('option_test') 
    option_test = 0;
end
if ~exist('option_eye')
    option_eye = 1;
end
if option_test ~= 0
    disp('Warning: Test mode is on!');
    input('Type Enter to continue!');
    tbaseline = 1;
else
    tbaseline = 300;
end
if option_eye ~= 1
    disp('Warning: Eye tracker is off!');
    input('Type Enter to continue!');
end

% directories
mainpath = [pwd '/'];
addpath('./functions');
temppath = [mainpath 'temp/subjectID.mat'];
savepath = [mainpath 'data/'];

if option_test == 0
    sublist = importdata(temppath);
    subjectID = sublist(end);
    subjectID = subjectID + 1;
    save(temppath,'subjectID');
    sub.subjectID = input('SubjectID:');
else
    sub.subjectID = 999;
end
% initial parameters
projectname = 'P075_';  
time = datestr(now,30);      
starttaskclock = clock;
% parameters
text.textSize = 40;
text.textColor = [1 1 1]*1;
text.textWrapat = 70;
text.textFont = 'Arial';
colour{1} = [ 97    67    67 ]/255;                           
colour{2} = [ 55    85    55 ]/255;
colour{3} = [ 71    71   101 ]/255;
colour{4} = [ 91    71    41 ]/255;
textColour = [255 255 255]/255;  
bgColour = [1 1 1]/255;

% eyetracker setup
eyetribedir  = ['~/Desktop/python_source'];
eyetribeSourcedir = ['~/Desktop/EyeTribe_for_Matlab/'];
eye = eyetracker(eyetribedir,eyetribeSourcedir);

if option_eye ~= 1
    eye.flag = false;
else
    eye.flag = true;
end

filename = [projectname, 'eye_raw_sub', num2str(sub.subjectID), '_',time];
eye.setup(savepath,filename);
eye.open;
eye.calibrate;
eye.startmatlabserver;
eye.connect;

cd(mainpath);

% start screen
Screen('Preference', 'SkipSyncTests', 1); 
PsychDefaultSetup(2);
KbName('UnifyKeyNames');
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);

ratime = etime(clock,starttaskclock)/60;
eye.startaquiring;


% subjectID & demographic information
eye.marker('getsubjectID');
sub = getsubjectID(window,sub.subjectID);
save([savepath projectname 'subjectinfo_sub' num2str(sub.subjectID),'_',time(1:8)],'sub');
eye.marker('getdemographic');
subdemo = demographic(window,sub.subjectID);
save([savepath  projectname 'demographicinfo_sub' num2str(sub.subjectID),'_',time],'subdemo','sub','ratime');

HideCursor;

% introduction
i = 0;
i=i+1; iStr{i} = 'Welcome! Thank you for volunteering for this experiment.';
i=i+1; iStr{i} = 'In this experiment you will do three things.  \n1. Baseline eye measurement. This will take about 5 minutes. \n2. Fill in a short questionnaire. This will take about 5 minutes.\n3. Play a gambling task in which you will make choices between two options. This will take about 20 to 40 minutes, depending on how well you do in the gambling task. \nWhen you''re done please return to the experimenter for debriefing.';
ins = instructions(window);
ins.setup(text);
ins.update(iStr);
eye.marker('instructions');
ins.run(0);

% baseline eye measurement
i = 0;
i=i+1; iStr{i} = 'Now we are going to get a baseline measurement of your eyes using the eye tracker. \n\nPress space to continue';
i=i+1; iStr{i} = 'To do this we need you to stare at the screen for 5 minutes.  Feel free to relax and daydream, but please stay in the chin rest.\n\nPress space to continue';
i=i+1; iStr{i} = 'Press space to start the eye-measurement.';
insbase = instructions(window);
insbase.setup(text);
insbase.update(iStr);
eye.marker('instructionsbaseline');
insbase.run(1);
Screen('FillRect',window,[0 0 0]);
Screen('Flip',window);
eye.marker('startbaseline');
WaitSecs(tbaseline);
eye.marker('endbaseline');


% survey
sur = surveys(window,sub.subjectID);

for subsession = 1:2
i = 0; iStr = [];
i=i+1; iStr{i} = 'Now we would like you to complete the following survey with a total of 10 questions. \n\nPress space to continue';
switch subsession
    case 1
        sur.legalkey = [KbName('1'):KbName('4'),KbName('1!'):KbName('4$')];
        sur.setupsurvey('./survey/','./survey/','ID_Scale','ID_Scale_ans');
        num = 4;
        savename = [savepath, projectname,'survey_ID_Scale_sub' num2str(sub.subjectID),'_',time]; 
    case 2
        sur.legalkey = [KbName('1'):KbName('5'),KbName('1!'):KbName('5%')];
        sur.setupsurvey('./survey/','./survey/','CEIII','CEIII_ans');
        num = 5;        
        savename = [savepath, projectname,'survey_CEIII_sub' num2str(sub.subjectID),'_',time]; 
end        
i=i+1; iStr{i} = ['Please respond to the questions by pressing number keys 1 to ' ,num2str(num), '.\n\nPress space to continue'];
inssur = instructions(window);
inssur.setup(text);
inssur.update(iStr);
inssur.run(1);
sur.setup(savename,text);
eye.marker('surveystart');
sur.run;
eye.marker('surveyend');
end

% horizon task
savename = [savepath, projectname,'horizontask_sub' num2str(sub.subjectID),'_',time];
pasttime = etime(clock,starttaskclock)/60;
if option_time == 0
    timeleft = inf;
else
    timeleft = option_time - pasttime;
end
tsk = task_horizon(window,savename,bgColour);
tsk.setup(sub.subjectID,eye,textColour);
eye.marker('taskstart');
tsk.run(timeleft);
eye.marker('taskend');

ShowCursor;

% exit screen
Screen('FillRect',window,[0 0 0]);
tstring= 'Thank you for participating in this task! \n\n Now we have a short post-experiment questionnaire for you.\n\nPress anything to exit and continue';
Screen('TextSize',window,40);
DrawFormattedText(window,tstring,'center','center',[1 1 1]);
Screen('Flip',window);
KbStrokeWait;
sca;

eye.endaquiring;
eye.disconnect;
eye.close;
cd(mainpath);

cd('./IntrospectionQues');
savename = [projectname 'PostQues_sub' num2str(sub.subjectID),'_',time(1:8)];
eval(['!cp PostExperimentQs.txt ' savename '.txt']);
% cd(savepath);
eval(['!open -a TextEdit ' savename '.txt']);
end
