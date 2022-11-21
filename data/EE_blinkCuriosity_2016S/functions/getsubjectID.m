function sub = getsubjectID(window,subjectID)
    qString{1} = 'Eye make-ups';
    aString{1} = {
    'None' 
    'Eyeliner' 
    'Mascara'
    'Mascara & Eyeliner'
    'Other'
    };
    
    qString{2} = 'Eyetracker calibration quality';
    aString{2} = {
        '5'
        '4'
        '3'
        '2'
        '1'
        'not calibrated'
    };
    qString{3} = 'Sight';
    aString{3} = {
        'Normal sight'
        'Corrected sight(wear glasses)'
        'Short-sighted'
        'Far-sighted'
        'Astigmatic'
        'Other'
    };
    nx = 5;
    ny = 1;
    bxq = boxQuestion(window);
    bxq.legalkey = [KbName('1'):KbName('0'),KbName('1!'):KbName('0)')];
    bxq.setup('Subject ID', nx, ny);
    bxq.bx.string = num2str(subjectID);
%     nx = 30;
%     ny = 1;
%     bxq2 = boxQuestion(window);
%     bxq2.legalkey = [KbName('a'):KbName('z')];
%     bxq2.setup('Last Name', nx, ny);
%     nx = 30;
%     ny = 1;
%     bxq3 = boxQuestion(window);
%     bxq3.legalkey = [KbName('a'):KbName('z')];
%     bxq3.setup('First Name', nx, ny);
    for i = 1:length(qString)
        if i == 1
            bq = buttonQuestion(window,0);
        else
            bq(i) = buttonQuestion(window,0);
        end
        bq(i).setup(qString{i}, aString{i});
    end
    bq(1).setCornerPosition([400 100]);
    bq(2).setCornerPosition([700 100]);
    bq(3).setCornerPosition([50 400]);
    bxq.setCornerPosition([50 100]);
%     bxq2.setCornerPosition([400 100]);
%     bxq3.setCornerPosition([400 400]);
    string = 'Continue';
    colorscale = 1;
    cb = clickBox(window);
    textColor = [0 0 0]*colorscale;
    edgeColor = [1 1 1]*colorscale;
    fillColor_on = [1 0 0]*colorscale;
    fillColor_off = [0 1 0]*colorscale;
    textSize = 30;
    rect = [0 0 300 100];
    cb.setup(string,textColor,textSize,edgeColor,fillColor_on,fillColor_off,rect);
    cb.setCornerPosition([1400 400]);

    while true
        for i = 1:length(bq)
            bq(i).draw;
        end
        bxq.draw;
%         bxq2.draw;
%         bxq3.draw;
        cb.draw;
        [x,y,buttons] = GetMouse(window);
        Screen('Flip', window, [], 1);
        if any(buttons)
            unfinished = 0;
            for i = 1:length(bq)
                bq(i).check(x,y);
                unfinished = unfinished + (bq(i).choice == -1);
            end
            bxq.check(x,y);
%             bxq2.check(x,y);
%             bxq3.check(x,y);
            unfinished = unfinished + isempty(bxq.bx.string);
            cb.check(x,y,unfinished);
        end
        if cb.isOn
            break;
        end
        Screen('FillRect', window, [0 0 0])
    end
    Screen('FillRect', window, [0 0 0]);
    Screen('Flip',window);
    sub.subjectID = str2num(bxq.bx.string)
%     sub.subjectFirstName = bxq2.bx.string;
%     sub.subjectLastName = bxq3.bx.string;
    sub.session = aString{1}(bq(1).choice);
    sub.calibrationquality = 6 - bq(2).choice;
    sub.sight =  aString{3}(bq(3).choice);
    Screen('FillRect',window,[0 0 0]);
    Screen('Flip',window);
end