classdef surveys < handle
    properties
        subjectID
        surveydir
        surveyname
        surveyansname
        qnum
        survey
        datadir
        savename
        window
        bgColour
        screenWidth
        screenHeight
        screenCenter
        text
        legalkey
    end
    methods
        function obj = surveys(window,subjectID)
            obj.subjectID = subjectID;
            obj.window = window;
%             obj.setup;
        end
        function obj = setupsurvey(obj,surveydir,datadir,surveyname,surveyansname)
            obj.datadir = datadir;
            obj.surveydir = surveydir;
            obj.surveyname = surveyname;
            if ~exist('surveyansname')
                obj.surveyansname = [];
            else
                obj.surveyansname = surveyansname;
            end
            obj.readSurvey;
        end
        function setup(obj,savename,text)
            obj.savename = savename;
            obj.setwindow;
            obj.text.textSize = text.textSize;
            obj.text.textWrapat = text.textWrapat;
            obj.text.textColor = text.textColor;
            obj.text.textFont = text.textFont;
            obj.setTextParameters;
        end
        function setwindow(obj)
            [screenWidth,screenHeight] = Screen('WindowSize',obj.window);
            screenCenter = [screenWidth,screenHeight]/2;
            colorscale = 1;
            obj.bgColour = [0 0 0]*colorscale;
            obj.screenWidth = screenWidth;
            obj.screenHeight = screenHeight;
            obj.screenCenter = screenCenter;
        end
        function setTextParameters(obj)
            Screen('TextFont', obj.window, obj.text.textFont);
            Screen('TextSize', obj.window, obj.text.textSize);
            Screen('TextColor', obj.window, obj.text.textColor);
%             Screen('TextStyle', obj.window, 1);
        end
        function [KeyNum, when, deltawhen] = waitForInput(obj, validKeys, timeOut)
            % wait for a keypress for TimeOut seconds
            Pressed = 0;
            while ~Pressed && (GetSecs < timeOut)
                [Pressed, when, KeyNum, deltawhen] = KbCheck;
                KeyNum = find(KeyNum,1);
                if ~ismember(KeyNum,validKeys) % && length(validKeys) > 0
                    Pressed = 0;
                end
            end
            if Pressed == 0
                KeyNum = [];
                when = [];
            end
        end
%         function talk(obj, str, tp, colorfont,winRect)
%             if exist('colorfont') == 0 || length(colorfont) == 0
%                 colorfont = obj.text.textColor;
%             end
%             if exist('winRect') == 0 || length(winRect) == 0
%                 winRect = [0 0 obj.screenWidth obj.screenHeight];
%             end
%             if exist('tp') == 0 || length(tp) == 0
%                 DrawFormattedText(obj.window, str,'center','center', colorfont, obj.text.textWrapat, 0,0,2,0, winRect);
%             else
%                 DrawFormattedText(obj.window, str, tp{1},tp{2}, colorfont, obj.text.textWrapat, 0,0,2,0, winRect);
%             end
%         end
         function talk2(obj, str, option, mwrapat)
             if exist('mwrapat') == 1
                 Wrapat = mwrapat;
             else 
                 Wrapat = obj.text.textWrapat;
             end
             if exist('option') == 1
              A = option{1};
              B = option{2};
                            [nx, ny] = DrawFormattedText(obj.window, ...
                            ['' str], ...
                            A,B, obj.text.textColor, Wrapat);
                        
             else
                        [nx, ny] = DrawFormattedText(obj.window, ...
                            ['' str], ...
                            'center','center', obj.text.textColor, Wrapat);
                    end
                    
        end
        function readSurvey(obj)
            fid = fopen([obj.surveydir obj.surveyname '.txt']);
            rd = textscan(fid,'%s','delimiter','\n');
            fclose(fid);
            rd = rd{1};
            obj.survey.nQues = length(rd);
            if length(obj.surveyansname)
                fid = fopen([obj.surveydir obj.surveyansname '.txt']);
                rdans = textscan(fid,'%s','delimiter','\n');
                fclose(fid);
                rdans = rdans{1};
                for i = 1:obj.survey.nQues
                    obj.survey.survey(i).Q = rd{i};
                    obj.survey.survey(i).nA = length(rdans);
                    obj.qnum = obj.survey.survey(i).nA;
                    for j = 1:obj.survey.survey(i).nA
                        obj.survey.survey(i).A{j} = rdans{j};
                    end
                end
            end
        end
        function displayQuestion(obj,i)
            Q_ypos = obj.screenHeight*1/8;
            A_ypos = obj.screenHeight*3.2/8;
            Qstring = obj.survey.survey(i).Q;
            str = [];
            margin = 100;
            [w,h] = Screen('windowSize',obj.window);
%             obj.qnum
            step = (w - 2 * margin)/obj.qnum;
            for j = 1:obj.survey.survey(i).nA
                str{j} = [obj.survey.survey(i).A{j}];
                Astring = [str{j}];
                x = step * (j - 1) + margin;
                obj.talk2(Astring,{x,A_ypos},step/17);
            end
            obj.talk2(Qstring,{'center',Q_ypos});
            
        end
        function displayAnswer(obj,i)
            Q_ypos = obj.screenHeight*1/8;
            A_ypos = obj.screenHeight*3.2/8;
            margin = 100;
            [w,h] = Screen('windowSize',obj.window);
            step = (w - margin*2)/obj.qnum
            x = step * ( obj.survey.answers(i).keyNum - 1) + margin;
            Qstring = obj.survey.survey(i).Q;
            Astring = obj.survey.answers(i).Ans;
            obj.talk2(Qstring,{'center',Q_ypos});
            obj.talk2(Astring,{x,A_ypos},step/17);
        end
        function run(obj)
            obj.welcomescreen;
            for count = 1:obj.survey.nQues
                obj.displayQuestion(count);
                timeQues = Screen('Flip',obj.window);
                validKeys = obj.legalkey;
                [KeyNum, when] = obj.waitForInput(validKeys, GetSecs+Inf);
                KeyNum = find(validKeys == KeyNum);
                KeyNum = KeyNum - (KeyNum > obj.qnum)*obj.qnum;
                obj.survey.answers(count).keyNum = KeyNum;
                obj.survey.answers(count).RT = when - timeQues;
                obj.survey.answers(count).Ans = obj.survey.survey(count).A{KeyNum};
                obj.displayAnswer(count);
                Screen('Flip',obj.window);
                WaitSecs(0.5);
            end
            obj.save;
            obj.goodbyescreen;
        end
        function welcomescreen(obj)
            tstring = 'Press anything to start the survey';
            obj.talk2(tstring);
            Screen('Flip',obj.window);
            WaitSecs(0.1);
            KbStrokeWait;
        end
        function goodbyescreen(obj)
            tstring = 'Congratulations, You have finished this survey.\n\nPress any key to continue';
            obj.talk2(tstring);
            Screen('Flip',obj.window);
            WaitSecs(0.1);
            KbStrokeWait;
        end
        function save(obj)
            survey = obj.survey;
            subjectID = obj.subjectID;
            save(obj.savename,'subjectID', 'survey');
        end
    end
end