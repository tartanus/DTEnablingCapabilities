clear;close all;clc;
load("fault5001.mat")  %fault 1
% load("fault5010.mat")    %fault 2
load("DTBHInitData50Ref.mat")
% load("OpenLoopIDPBRS.mat")
load("CLDTSteppedDTBM.mat")
tSim=501;
sp=50;
F1On=0;     %Actuator ideal conditions no failure  1 off/ 0 on
F2On=1;     %Sensor ideal conditions no failure  1 off/ 0 on
F1Time=200; %fault one starts
F2Time=200; %fault two starts
tStep=50;   %step input occurence time
% seebeck=75e-3;
% resistance=3.3;
% conductance=0.3808;
% Cp=31.41;
% seebeck=0.074314;
% resistance=3.3;
% conductance=0.32892;
Cp=38.15;
seebeck=0.097989;
resistance=3.3;
conductance=0.2207;

tempNominalReal=[tempRecord(:,1),tempRecord(:,2)+273.15];
controlNominalReal=[uRecord(:,1),uRecord(:,2)];
referenceReal=[refSetPoint(:,1) refSetPoint(:,2)];
tempFaultReal=[simout(:,3),simout(:,2)+273.15];
controlFaultReal=[simout(:,3),simout(:,1)];

IDInput=[peltierData(1,:)' peltierData(2,:)'];
IDOutput=[peltierData(1,:)' peltierData(3,:)'+273.15];
reference=[peltierData(1,:)' peltierData(5,:)'];
% degRes=[3.3*ones(1,100) 0.5*ones(1,tSim-100)]
% resistance=[simout(:,3),degRes']
% set_param('DTFaultDetectionScript/Peltier','R',string(3.3));
% sim("DTFaultDetectionScriptBMFault")

%% plot DT vs real data

time=DTResponse.time;
tempDT=DTResponse.signals.values(:,1);
tempReal=DTResponse.signals.values(:,2);
UDT=DTResponse.signals.values(:,3);
UReal=DTResponse.signals.values(:,4);
dTq=DTResponse.signals.values(:,5);  %derivative of delta(tDT-TReal)
dUq=DTResponse.signals.values(:,6);  %derivative of delta(uDT-UReal)

figure(1)
subplot(2,1,1)
plot(time,tempDT)
hold on
plot(time,tempReal)
plot(tempFaultReal(:,1),tempFaultReal(:,2))
legend('DT fault','Nominal','Real fault')
xlabel("Time (s)")
ylabel("Temperature (°C)")
xlim([0 500])
set(gca,'Fontsize',14);

subplot(2,1,2)
plot(time,UDT)
hold on
plot(time,UReal)
plot(controlFaultReal(:,1),controlFaultReal(:,2))
legend('DT fault','Nominal','Real fault')
xlabel("Time (s)")
ylabel("Control action (pwm)")
xlim([0 500])
set(gca,'Fontsize',14);

%% parity error
errorTemp=tempDT-tempReal;
plot(errorTemp)
muErrTemp=mean(errorTemp(1:200))
sigmaErrTemp=std(errorTemp(1:200))

hold on
errorU=UDT-UReal;
muErrU=mean(errorU(1:200))
sigmaErrU=std(errorU(1:200))
plot(errorU)





