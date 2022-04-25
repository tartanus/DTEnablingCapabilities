%% Simulation script for remaining useful life calculation
%with resistan thresholding variation before complete damage
clear;close all;clc;
setPoints=[50];% 40]% 50 60 70 80 90];
faults=[1 2 3];%F1 F2 00 01 10 11
%peltier parameters
seebeck=75e-3;
resistance=2.9;
conductance=0.3808;
Cp=31.41;
pathSave="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\newPrognosisDataUp\";
% pathSave="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\faultTraining\";
% pathSave="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\";

% %resistance degradation down(simulated)
% slope=0.01:0.01:0.1;
% for i=1:10
%     t=0:10:500;
%     resistanceDegradation(i,:)=3.3*exp(slope(i)*t)+0.1;
%     plot(resistanceDegradation(i,:))
%     hold on
% end


%resistance degradation up
slope=0.01:0.01:0.1;
for i=1:10
    t=0:1:50;
    resistanceDegradation(i,:)=(3.3*exp(slope(i)*t)+0.1)/100;
    plot(resistanceDegradation(i,:))
    hold on
end
xlabel("Time (h)")
ylabel("Resistance degradation")
set(gca,'Fontsize',14);


for i=1:length(setPoints)
    tSim=500;
    sp=setPoints(i);
    F1On=1;     %ideal conditions no failure
    F2On=1;     %ideal conditions no failure
    F1Time=200; %fault one starts
    F2Time=200; %fault two starts
    tStep=20;   %step input occurence time
    resistance=3.3; %nominal resistance
        
    sim('DTFaultDetectionScriptPrognosis')
    time=DTResponse.time;
    tempDT=DTResponse.signals.values(:,1);
    tempReal=DTResponse.signals.values(:,2);
    UDT=DTResponse.signals.values(:,3);
    UReal=DTResponse.signals.values(:,4);
    dTq=DTResponse.signals.values(:,5);  %derivative of delta(tDT-TReal)
    dUq=DTResponse.signals.values(:,6);  %derivative of delta(uDT-UReal)
    
    
    spArray=(sp+273.15)*ones(1,length(dTq));
    spArray(1:tStep)=23+273.15;
    errorSignal=spArray'-tempDT;
    %health indicators
    time1=1;
    tempDTMean=mean(tempDT(200:end));
    tempDTStd=std(tempDT(200:end));
    controlDTMean=mean(UDT(200:end));
    controlDTStd=std(UDT(200:end));
    tempRMS=rms(tempDT(200:end));
    controlRMS=rms(UDT(200:end));
    errorRMS=rms(errorSignal(200:end));
    resDeg=resistance;
    healthIndicators={time1,tempDTMean,tempDTStd,controlDTMean,controlDTStd,tempRMS,controlRMS,errorRMS,resDeg};
    fileName=strcat("resDegNominal"+string(sp)+".mat");
    save(pathSave+fileName,'healthIndicators');

    %fault evaluation and data generation
    [row,col]=size(resistanceDegradation);
    clear healthIndicators;
    for j=1:row
        for k=1:col
            %simulation of DT with some specific resistance value
            resistance=3.3*resistanceDegradation(j,k)+3.3;    
            sp=setPoints(i);
            sim('DTFaultDetectionScriptPrognosis')
            time=DTResponse.time;
            tempDT=DTResponse.signals.values(:,1);
            tempReal=DTResponse.signals.values(:,2);
            UDT=DTResponse.signals.values(:,3);
            UReal=DTResponse.signals.values(:,4);
            dTq=DTResponse.signals.values(:,5);  %derivative of delta(tDT-TReal)
            dUq=DTResponse.signals.values(:,6);  %derivative of delta(uDT-UReal)
            voltage=DTResponse.signals.values(:,7);
            current=DTResponse.signals.values(:,8);
            
            spArray=(sp+273.15)*ones(1,length(dTq));
            spArray(1:tStep)=23+273.15;
            errorSignal=spArray'-tempDT;
   
            %health indicators
            time1(k)=k;
            tempDTMean(k)=mean(tempDT);
            tempDTStd(k)=std(tempDT);
            controlDTMean(k)=mean(UDT);
            controlDTStd(k)=std(UDT);
            tempRMS(k)=rms(tempDT);
            controlRMS(k)=rms(UDT);
            errorRMS(k)=rms(errorSignal);
            VRMS(k)=rms(voltage);
            VMean(k)=mean(voltage);
            VStd(k)=std(voltage);
            IRMS(k)=rms(current);
            IMean(k)=mean(current);
            IStd(k)=std(current);
            resDeg(k)=resistance;
            
        end
        healthIndicators(j,:)={time1,tempDTMean,tempDTStd,controlDTMean,controlDTStd,tempRMS,controlRMS,errorRMS,resDeg,VRMS,VMean,VStd,IRMS,IMean,IStd};
        fileName=strcat("resDegLocal"+string(sp)+string(j)+".mat");
        save(pathSave+fileName,'healthIndicators');
    end
        fileName=strcat("resDeg"+string(sp)+string(i)+".mat");
        save(pathSave+fileName,'healthIndicators');
end