%% simulation script for NN tuning and DA  in Fault detection
clear;close all;clc;
setPoints=[30 40 50 60 70 80 90];
faults=[1 2 3];%F1 F2 00 01 10 11
%peltier parameters
seebeck=75e-3;
resistance=2.9;
conductance=0.3808;
Cp=31.41;
pathSave="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\faultTraining\";
% pathSave="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\";



for i=1:length(setPoints)
    tSim=500;
    sp=setPoints(i);
    F1On=1;     %ideal conditions no failure
    F2On=1;     %ideal conditions no failure
    F1Time=200; %fault one starts
    F2Time=200; %fault two starts
    tStep=20;   %step input occurence time
    sim('DTFaultDetectionScript')
    time=DTResponse.time;
    tempDT=DTResponse.signals.values(:,1);
    tempReal=DTResponse.signals.values(:,2);
    UDT=DTResponse.signals.values(:,3);
    UReal=DTResponse.signals.values(:,4);
    dTq=DTResponse.signals.values(:,5);  %derivative of delta(tDT-TReal)
    dUq=DTResponse.signals.values(:,6);  %derivative of delta(uDT-UReal)
    
    %Probability function estimation of dTq and dUq for fault thresholding
    pdnT= fitdist(dTq,'normal');    %fit into a normal distribution
    y_val=min(dTq)-1:0.01:max(dTq);
    tempNorm  = pdf(pdnT,dTq);
    dTqHB=3*pdnT.std; dTqLB=-3*pdnT.std; %thresholding boundaries for fault detection
    
    pdnU= fitdist(dUq,'normal');    %fit into a normal distribution
    y_val=min(dUq)-1:0.01:max(dUq);
    tempNorm  = pdf(pdnU,dUq);
    dUqHB=3*pdnU.std; dUqLB=-3*pdnU.std; %thresholding boundaries for fault detection

    spArray=sp*ones(1,length(dTq));
    spArray(1:tStep)=23;
    errorSignal=spArray'-tempDT;
%     NNArray=[dTq dUq tempDT UDT spArray'];
    NNArray=[tempDT UDT spArray' errorSignal];
    labelsFT=ones(1,length(tempDT));
    fileName=strcat("fault"+string(sp)+string(F1On)+string(F2On)+".mat");
    save(pathSave+fileName,'time','tempDT','tempReal','UDT','UReal','dTq','dUq','dTqHB','dTqLB','dUqHB','dUqLB','pdnU','pdnT','labelsFT','NNArray','errorSignal');
    
    %fault evaluation and data generation
    for j=2:length(faults)
        if faults(j)==2 %inverse logic: zero on // one off
            F1On=0;
            F2On=1;
            label=2;
        elseif faults(j)==3
            F1On=1;
            F2On=0;
            label=3;
        elseif faults(j)==4
            F1On=0;
            F2On=0;
            label=4;
        end    
       
        sp=setPoints(i);
        sim('DTFaultDetectionScript')
        time=DTResponse.time;
        tempDT=DTResponse.signals.values(:,1);
        tempReal=DTResponse.signals.values(:,2);
        UDT=DTResponse.signals.values(:,3);
        UReal=DTResponse.signals.values(:,4);
        dTq=DTResponse.signals.values(:,5);  %derivative of delta(tDT-TReal)
        dUq=DTResponse.signals.values(:,6);  %derivative of delta(uDT-UReal)

        %Probability function estimation of dTq and dUq for fault thresholding
        pdnT= fitdist(dTq,'normal');    %fit into a normal distribution
        y_val=min(dTq)-1:0.01:max(dTq);
        tempNorm  = pdf(pdnT,dTq);
        dTqHB=3*pdnT.std; dTqLB=-3*pdnT.std; %thresholding boundaries for fault detection

        pdnU= fitdist(dUq,'normal');    %fit into a normal distribution
        y_val=min(dUq)-1:0.01:max(dUq);
        tempNorm  = pdf(pdnU,dUq);
        dUqHB=3*pdnU.std; dUqLB=-3*pdnU.std; %thresholding boundaries for fault detection
        
%         %labeling for machine learning detection
%         labelsFT=ones(1,length(tempDT));
%         for k=1:length(labelsFT)
%             if(dTq(k)>=dTqLB && dTq(k)<=dTqHB) || (dUq(k)>=dUqLB && dUq(k)<=dUqHB) 
%                 labelsFT(k)=1;     %health point
%             else
%                 labelsFT(k)=2;     %fault point
%             end
%         end
        %labels generation simple
        labelsFT=ones(1,length(tempDT));
        labelsFT(200:end)=label*labelsFT(200:end);
        %Training dataset generation
        spArray=(sp+273.15)*ones(1,length(dTq));
        spArray(1:tStep)=23+273.15;
        errorSignal=spArray'-tempDT;
%         NNArray=[dTq dUq tempDT UDT spArray'];
        NNArray=[tempDT UDT spArray' errorSignal];
%         NNArrayDelta=[dTq dUq tempDT UDT spArray'];
        
%         pathSave="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\faultTraining\";
%         pathSave="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\";
        fileName=strcat("fault"+string(sp)+string(F1On)+string(F2On)+".mat");
        save(pathSave+fileName,'time','tempDT','tempReal','UDT','UReal','dTq','dUq','dTqHB','dTqLB','dUqHB','dUqLB','pdnU','pdnT','labelsFT','NNArray','errorSignal');



    end
end