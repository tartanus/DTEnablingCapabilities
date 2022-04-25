function y = faultNet1(u)
load('netFaultDT.mat');
   
y = round(net(u));
