function [yp, xvi] = sum1d(y, x, sigma, varargin)

minx = min(x);
maxx = max(x);

if size(varargin) == 0
    dx = 0.001;
else
    dx = varargin{1};
    
    if length(varargin) > 1
        
        minx = varargin{2};
        maxx = varargin{3};
        
    end
end

xvi = minx : dx : maxx;

yp = NaN*ones(length(xvi), 1);

xctr = 1;
for xv = minx : dx : maxx
    
    yv = 0;
    % ysum = 0;
            
    d = exp((-abs((x - xv)).^2)/sigma);
    yv = yv + y'*d;
    % ysum = ysum + sum(d);
        
    yp(xctr) = yv;    
    
    xctr = xctr + 1;
    
end

