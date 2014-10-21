function [coefUp, coefLo, ret] = parseccoef(param, doSearch)
% #  leading edge radius (Rle),
% #  position of upper crest (Xup), upper crest point (Yup), upper crest curvature (Y XXup),
% #  position of lower crest (Xlo),lower crest point (Ylo),  lower crest curvature (Y XXlo),
% #  trailing edge offset (Toff ), edge thickness (TTE)
% #  trailing edge direction angle (¦ÁTE ), trailing edge wedge angle (¦ÂTE), trailing
if nargin < 2
    doSearch = 0;
end
cellParam = num2cell(param);
[rle, xu, yu, ku, xl, yl, kl, yt, tt, at, bt] = deal(cellParam{:});

coefUp = zeros(6,1);
coefLo = zeros(6,1);
% leading edge condition
coefUp(1) = sqrt(2*rle);
coefLo(1) = -sqrt(2*rle);

Au = zeros(5,5);
Au(1,:) = xu .^ (3/2:1:11/2);
Au(2,:) = (3/2:1:11/2) .* (xu .^ (1/2:1:9/2));
Au(3,:) = (3/2:1:11/2) .* (1/2:1:9/2) .* (xu .^ (-1/2:1:7/2));
Au(4,:) = ones(1,5);
Au(5,:) = 3/2:1:11/2;
bu = [yu-coefUp(1)*xu^0.5
    -0.5*coefUp(1)*xu^(-0.5)
    ku+0.25*coefUp(1)*xu^(-1.5)
    yt+0.5*tt-coefUp(1)
    tan(at-bt/2)-0.5*coefUp(1)];
coefUp(2:6) = Au \ bu;

Al = zeros(5,5);
Al(1,:) = xl .^ (3/2:1:11/2);
Al(2,:) = (3/2:1:11/2) .* (xl .^ (1/2:1:9/2));
Al(3,:) = (3/2:1:11/2) .* (1/2:1:9/2) .* (xl .^ (-1/2:1:7/2));
Al(4,:) = ones(1,5);
Al(5,:) = 3/2:1:11/2;
bl = [yl-coefLo(1)*xl^0.5
    -0.5*coefLo(1)*xl^(-0.5)
    kl+0.25*coefLo(1)*xl^(-1.5)
    yt-0.5*tt-coefLo(1)
    tan(at-bt/2)-0.5*coefLo(1)];
coefLo(2:6) = Al \ bl;
x0 = [coefUp(2:end) coefLo(2:end)];

ret = resul(x0);
if doSearch ~= 0   
    
    % cul = patternsearch(@resul, x0,[],[],[],[],[],[],[],psoptimset('display','iter'));
%     [cul, ret] = simulannealbnd(@resul,x0,-100*ones(1,10), 100*ones(1,10), saoptimset('display','iter'));
    [cul, ret] = fmincon(@resul,x0,[],[],[],[],-100*ones(1,10), 100*ones(1,10),[], optimset('display','iter'));
        
    coefUp(2:end) = cul(1:5);
    coefLo(2:end) = cul(6:10);
end

    function res = resul(coefUL)
        coefu = [coefUp(1) coefUL(1:5)];
        coefl = [coefLo(1) coefUL(6:10)];
        xpu = fminbnd(@(x)(-parsec(coefu,x)), 0,1);
        [ypu, dypu, ddypu] = parsec(coefu,xpu);
        xpl = fminbnd(@(x)(parsec(coefl,x)), 0,1);
        [ypl, dypl, ddypl] = parsec(coefu,xpl);
        
        [y1u, dy1u] = parsec(coefu,1);
        [y1l, dy1l] = parsec(coefl,1);
        
        res = [xpu-xu, ypu-yu, dypu, ddypu-ku, xpl-xl, ypl-yl, dypl, ...
            ddypl-kl, y1u-(yt+tt/2), dy1u-tan(at-bt/2), y1l-(yt-tt/2), dy1l-tan(at+bt/2)];
        res = norm(res);
        
    end
end












