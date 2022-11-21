classdef clickBox < handle
    properties
        window
        rect
        edgeColor
        fillColor_on
        fillColor_off
        textColor
        textSize
        string
        edgeWidth
        
        isOn    
    end
    methods
        function obj = clickBox(window)
            obj.window = window;
        end       
        function setup(obj,string,textColor,textSize,edgeColor,fillColor_on,fillColor_off, rect)
            obj.string = string;
            obj.textColor = textColor;
            obj.edgeColor = edgeColor;
            obj.fillColor_on = fillColor_on;
            obj.fillColor_off = fillColor_off;
            obj.textSize = textSize;
            obj.rect = rect;           
            obj.edgeWidth = 2;
            obj.isOn = false;
        end
        function setCornerPosition(obj, pos)
            rect = obj.rect;
            obj.rect = rect-[rect(1:2) rect(1:2)]+[pos pos];
        end
        function draw(obj)
            string = obj.string;
            if obj.isOn
                Screen('FillRect', obj.window, obj.fillColor_on, obj.rect);
            else
                Screen('FillRect', obj.window, obj.fillColor_off, obj.rect);
            end
            Screen('FrameRect',obj.window, obj.edgeColor, obj.rect, obj.edgeWidth);
            Wrapat = inf;
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            DrawFormattedText(obj.window,string,'center','center',obj.textColor,Wrapat, 0, 0, 1, 0, obj.rect);
            Screen('TextSize', obj.window, oldTextSize);            
        end
        function check(obj,x,y,unfinished)
            if (x > obj.rect(1)) & (x < obj.rect(3)) ...
                    & (y > obj.rect(2)) & (y < obj.rect(4))
                if unfinished > 0
                    Screen('FillRect',obj.window,[0 0 0]);
                    oldTextSize = Screen('TextSize', obj.window, 40);
                    tstring = 'Please make sure you have entered all the information before you continue! \n\n Press anykey to go back';
                    DrawFormattedText(obj.window,tstring,'center','center',[1 1 1]);
                    Screen('Flip',obj.window);
                    Screen('TextSize', obj.window, oldTextSize);   
                    KbStrokeWait;
                else
                    obj.isOn = ~obj.isOn;
                end
                WaitSecs(0.1);
            end
        end
    end
end