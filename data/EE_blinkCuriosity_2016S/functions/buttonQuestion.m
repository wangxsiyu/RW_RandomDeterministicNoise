classdef buttonQuestion < handle
    properties
        window
        qString
        qTextSize
        qTextColor
        qPos
        multichoice
        choice
        bt
    end
    methods
        function obj = buttonQuestion(window,multichoice)
            obj.window = window;
            obj.multichoice = multichoice;
            obj.choice = -1;
        end
        function default(obj,value)
            obj.choice = value;
        end
        function setup(obj,qString, aString)
            obj.qString     = qString;
            obj.qTextSize   = 30;
            colorscale = 1;
            obj.qTextColor  = [1 1 1]*colorscale;

            textSize    = 20;
            textColor   = [1 1 1]*colorscale;
            edgeWidth   = 2;
            edgeColor   = [1 1 1]*colorscale;
            onColor     = [1 1 1]*colorscale;
            offColor    = [0 0 0]*colorscale;
            margin      = 10;
            radius      = 20;
            fillFrac    = 0.6;
            for i = 1:length(aString)
                string = aString{i};
                if i == 1
                    obj.bt = pushButtonText(obj.window);
                else
                    obj.bt(i) = pushButtonText(obj.window);
                end
                obj.bt(i).setup(textSize,textColor,string,edgeColor,onColor,offColor,edgeWidth,radius,fillFrac,margin);
            end
        end
        function setCornerPosition(obj, pos)
            obj.qPos = pos;
            for i = 1:length(obj.bt)
                obj.bt(i).setCornerPosition([pos(1) pos(2)+obj.qTextSize*1.1+i*obj.bt(i).textSize*1.1]);
            end
        end
        function draw(obj)
            sx = obj.qPos(1);
            sy = obj.qPos(2);
            oldTextSize = Screen('TextSize', obj.window, obj.qTextSize);
            DrawFormattedText(obj.window, obj.qString, sx, sy, obj.qTextColor);
            Screen('TextSize', obj.window, oldTextSize);
            for i = 1:length(obj.bt)
                obj.bt(i).draw;
            end
        end
        function check(obj, x, y)
            for i = 1:length(obj.bt)
                obj.bt(i).check(x,y);
                if obj.bt(i).bt.isOn
                   if  ~obj.multichoice && obj.choice ~= -1 && obj.choice ~= i
                        temp = obj.choice;
                        obj.bt(temp).bt.isOn = false;
                   end
                   obj.choice = i; 
                end
            end
            if obj.choice ~= -1 && obj.bt(obj.choice).bt.isOn == false
                obj.choice = -1;
            end
        end
    end
end