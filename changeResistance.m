function y=changeResistance(u)
changingTime=200;
if u(2)>changingTime
 set_param('DTFaultDetectionScript/Peltier','R',string(u(1)));
%  assignin('base',resistance,u(1))
% elseif u(2)<=changingTime
%  set_param('DTFaultDetectionScript/Peltier','R',string(3.3));
% %  assignin('base',resistance,3.3)

end
y=1;
end
% y = u;
