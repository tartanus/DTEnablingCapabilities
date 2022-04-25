Range = [-255,255];
Band = [0 1/20];
u1 = idinput([200,1,4],'prbs',Band,Range);
time=1:1:length(u1);
plot(u1)

IDSignal=[time' u1]

