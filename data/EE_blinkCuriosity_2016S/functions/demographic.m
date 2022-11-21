function demo = demographic(window,subID)
    qString{1} = 'Gender';
    aString{1} = {
        'Female' 
        'Male' 
        'Decline to answer'};
    qString{2} = 'Race';
    aString{2} = {
        'American Indian or Alaska Native' 
        'Asian' 
        'Black or African-American' 
        'Native Hawaiian or Other Pacific Islander' 
        'White' 
        'More than one race'
        'Unknown'
        'Decline to answer'};
    qString{3} = 'Ethnicity';
    aString{3} = {
        'Hispanic or Latino'
        'Not Hispanic or Latino'
        'Unknown'
        'Decline to answer'};
    qString{4} = 'Are you a native English speaker?';
    aString{4} = {
        'Yes'
        'No'
        'Decline to answer'};
    
    qString{5} = 'How many hours approximately did you sleep last evening?';
    aString{5} = {
        '10 or more'
        '8 to 10'
        '6 to 8'
        '4 to 6'
        '2 to 4'
        '2 or less'
        'Decline to answer'
    };
    for i = 1:length(qString)
        bq(i) = buttonQuestion(window,0);
        bq(i).setup(qString{i}, aString{i});
    end
    bq(1).setCornerPosition([50 100]);
    bq(2).setCornerPosition([400 100]);
    bq(3).setCornerPosition([1050 100]);
    bq(4).setCornerPosition([400 500]);
    bq(5).setCornerPosition([1050 500]);

    nx = 3;ny = 1;
    bxq = boxQuestion(window);
    bxq.legalkey = [KbName('1'):KbName('0'),KbName('1!'):KbName('0)')];
    bxq.setup('Age', nx, ny)
    bxq.setCornerPosition([50 500]);
    if subID == 999
    bxq.bx.string = '0';
    end
    string = 'Submit';
    colorscale = 1;
    cb = clickBox(window);
    textColor = [0 0 0]*colorscale;
    edgeColor = [1 1 1]*colorscale;
    fillColor_on = [1 0 0]*colorscale;
    fillColor_off = [0 1 0]*colorscale;
    textSize = 30;
    rect = [0 0 300 100];
    cb.setup(string,textColor,textSize,edgeColor,fillColor_on,fillColor_off,rect);
    cb.setCornerPosition([900 800]);
    while true
        Screen('FillRect', window, [0 0 0]);
        for i = 1:length(bq)
            bq(i).draw;
        end
        bxq.draw;
        cb.draw;
        dontclear = 1;
        Screen('Flip', window, [], dontclear);
        [x,y,buttons] = GetMouse(window);
%         WaitSecs(0.05);
        if any(buttons)
            
            unfinished = 0;
            for i = 1:length(bq)
                bq(i).check(x,y);
                unfinished = unfinished + (bq(i).choice == -1);
           
            end
            bxq.check(x,y);
            unfinished = unfinished + isempty(bxq.bx.string);
            cb.check(x,y,unfinished);
            
        end
        if cb.isOn
            break;
        end
    end
    demo.age = str2num(bxq.bx.string);
    i = 1;
    demo.gender = aString{i}(bq(i).choice);i = i + 1;
    demo.race = aString{i}(bq(i).choice);i = i + 1;
    demo.ethnicity = aString{i}(bq(i).choice);i = i + 1;
    demo.nativeenglishspeaker = aString{i}(bq(i).choice);i = i + 1;
    demo.sleep = aString{i}(bq(i).choice);i = i + 1;
    Screen('FillRect',window,[0 0 0]);
    Screen('Flip',window);
end