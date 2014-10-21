function [h,res] = visualparsec(param,h)
cellParam = num2cell(param);
[rle, xu, yu, ku, xl, yl, kl, yt, tt, at, bt] = deal(cellParam{:});
  
% h = figure;
clf(h);
% first round
[cu, cl, res] = parseccoef(param);
 
 x = 0:0.001:1;
 subplot(2,1,1);
 plot(x, parsec(cu,x), x, parsec(cl,x),[0 1], [0 0], 'LineWidth',2)
 
text(0,0,sprintf('\\leftarrow R_{le}=%g',rle))

hold on
plot([xu,xu],[0,yu])
plot([xl,xl],[0,yl]);
text(xu, yu*0.6, sprintf('@(%g,%g)-\\kappa_u=%g', xu, yu, ku));
text(xl, yl*0.6, sprintf('@(%g,%g)-\\kappa_l=%g', xl, yl, kl));
title(['parsec:(' sprintf('%.2g ', param) ')']);
hold off


% second round
[cu, cl, res] = parseccoef(param,1);
 
 x = 0:0.001:1; 
 subplot(2,1,2);
 plot(x, parsec(cu,x), x, parsec(cl,x),[0 1], [0 0], 'LineWidth',2)
 
text(0,0,sprintf('\\leftarrow R_{le}=%g',rle))

hold on
plot([xu,xu],[0,yu])
plot([xl,xl],[0,yl]);
text(xu, yu*0.6, sprintf('@(%g,%g)-\\kappa_u=%g', xu, yu, ku));
text(xl, yl*0.6, sprintf('@(%g,%g)-\\kappa_l=%g', xl, yl, kl));
title(['parsec:(' sprintf('%.2g ', param) ')']);
hold off
