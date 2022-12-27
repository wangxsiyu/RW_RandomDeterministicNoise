function sub = assist_import_demo(data, version)
    % by Siyu (sywangr@email.arizona.edu)
    % version 1.0
    versions = {'demo_siyu_v1','demo_siyu_v1b','activepassive_interleaved'};
    if (~exist('version', 'var') || ~any(strcmp(version, versions)))
        str = sprintf(['Please indicate which version of the Horizon Task the data', ...
            ' to be analyzed is. Here are all the supported versions:\n', ...
            '...demo_siyu_v1: this is an older version of demo in Siyu''s earlier version of EE task\n', ...
            '...demo_siyu_v1b: ?\n', ...
            '...activepassive_interleaved\n']);
        error(str);
    end
    switch version
        case 'demo_siyu_v1'
            sub.ratime = data.ratime;
            data.sub.sessionMISTAKEeyemakeups = data.sub.session;
            data.sub = rmfield(data.sub, 'session');
            % session is weird, it's supposed to save "None" or "Mascara" etc, but save 1, 3 etc instead, not sure what is recorded here.
            data.sub.subjectID_demo = data.sub.subjectID;
            data.sub = rmfield(data.sub, 'subjectID');
            sub = W.struct_merge(sub, data.subdemo);
            sub = W.struct_merge(sub, data.sub);      
        case 'demo_siyu_v1b'
            sub.starttime = data.starttime;
            sub.endtime = data.endtime;
            sub.instime = data.instime;
            sub.tasktime = data.tasktime;
            sub.maxtime = data.maxtime;
        case 'activepassive_interleaved'
            sub = data.demo;
            sub.gender = string(sub.gender);
            sub.math = string(sub.math);
            sub.age = string(sub.age);
    end
end