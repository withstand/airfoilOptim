% leading edge radius (Rle),
% position of upper crest (Xup), [0,1]
% upper crest point (Yup), (0,1)
% upper crest curvature (Y XXup), (~, 0)
% position of lower crest (Xlo), [0,1]
% lower crest point (Ylo),        (-1,0)
% lower crest curvature (Y XXlo), (0,~)
% trailing edge offset (Toff ), (-0.5, 0.5)
% edge thickness (TTE)  (0,0.5)
% trailing edge direction angle (¦ÁTE ),  (-pi/2, pi/2)
% trailing edge wedge angle (¦ÂTE), trailing (0, pi/2)
close all
lp = [0  0.1 0 -1  0.1 -1 0  0 0   0 0];
up = [0.005  0.5 1  0  0.5  0 1  0 0  0 pi/2];
span = up-lp;
h = figure;
for i=1:10000000
    pr = rand(1,11);
    param = pr .* span + lp;
%     param(2)= 0.6;
    param(3) = 0.05;
%     param(5) = 0.2;
    param(6) = -0.05;
    % param = [0.01 0.2 0.06 -0.01 0.2 -0.06 0.01 0.001, 0.0001, -0.0001, 0.0001];
    [h,res] = visualparsec(param,h);
    drawnow
    if res < 1e-1
        h = figure;
    end
   
end



