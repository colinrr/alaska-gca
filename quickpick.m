function [C,T0,c,d,t] = quickpick(n)
%[C,T0,c,d,t] = quickpick(n)
%
%

c = zeros(n,1);
d = c;
t = c;

for k= 1:n
    [d(k),t(k)] = ginput(1);
    c = d./(t*86400);
end

D = [ones(size(d)) d];
B = D\t;
C = 1/B(2)/86400;
T0 = B(1);

xl = xlim;
xl = [min(d) max(d)]+ [-0.1 0.1]*diff([min(d) max(d)]);

plot(xl,xl*B(2)+B(1),'--k')