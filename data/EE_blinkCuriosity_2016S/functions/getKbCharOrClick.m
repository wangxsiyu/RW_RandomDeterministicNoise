function out = getKbCharOrClick(window, untilTime)
    yieldInterval = 0.01;
    if nargin < 2
        untilTime = inf;
    end
    if isempty(untilTime)
        untilTime = inf;
    end
    secs = -inf;
    while secs < untilTime
        [isDown, secs, keyCode, deltaSecs] = KbCheck();
        if isDown || (secs >= untilTime)
            out.what        = 'keyPress';
            out.secs        = secs;
            out.keyCode     = keyCode;
            out.deltaSecs   = deltaSecs;
            out.ch          = find(keyCode,1);
%             disp(out.ch);
            break;
        end    
        [x,y,buttons,focus,valuators,valinfo] = GetMouse(window);
        if any(buttons)
            out.what        = 'click';
            out.secs        = secs;
            out.x           = x;
            out.y           = y;
            out.buttons     = buttons;
            break;
        end
%         secs = WaitSecs('YieldSecs', yieldInterval);
    end
    secs = WaitSecs(yieldInterval);    
end