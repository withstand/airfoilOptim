function [y, dy, ddy] = parsec(coef,x)
y = coef(1) * x .^ 0.5 + coef(2) * x.^1.5 + coef(3) * x.^2.5 ...
    + coef(4) * x .^ 3.5 + coef(5) * x .^ 4.5 + coef(6) * x .^ 5.5;

if nargout >= 2
    dy = 0.5 * coef(1) * x .^ -0.5 + 1.5 * coef(2) * x.^0.5 + 2.5 * coef(3) * x.^1.5 ...
        + 3.5*coef(4) * x .^ 2.5 + 4.5*coef(5) * x .^ 3.5 + 5.5*coef(6) * x .^ 4.5;
end

if nargout >=3
    ddy = -0.5*0.5 * coef(1) * x .^ -1.5 + 0.5*1.5 * coef(2) * x.^-0.5 + 1.5*2.5 * coef(3) * x.^0.5 ...
        + 2.5*3.5*coef(4) * x .^ 1.5 + 3.5*4.5*coef(5) * x .^ 2.5 + 4.5* 5.5*coef(6) * x .^ 3.5;
end