%% validation with real data
clear;close all;clc;
% load("faultNet11.mat")
filedir="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\realFaultsData\";
listing=dir(fullfile(filedir,'*.mat'));
for i=1:1%length(listing)
    %load real data from experiment
    load(filedir+listing(i).name)
    if simout(100,4)==50
        %load reference behavior from DT
        nominalDataDT=load("C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\fault5000.mat");
%         faultDataDT=load("C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\fault5010.mat");
        faultDataDT=load("C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\fault5001.mat");
        faultDataDTFan=load("C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\fault5001.mat");

    elseif simout(100,4)==70
        %load reference behavior from DT
        nominalDataDT=load("C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\fault7000.mat");
        faultDataDT=load("C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\fault7001.mat");
    end
    
    %Ideal behavior from DT (nominal, no faults)
    refTempDT=[nominalDataDT.tempReal];
    refUDT=[nominalDataDT.UReal];
    
    %fault behavior from DT
    refTempDTFault=[faultDataDT.tempDT];
    refUDTFault=[faultDataDT.UDT];
    
    %fault behavior DT with fan
    
    

    %set results for NN classification
    tempReal=simout(:,2)+273.15;
    UReal=simout(:,1);
%     dTq=diff(tempReal)-diff(refTempDT);
%     dUq=diff(UReal)-diff(refUDT);
%     dTq=[dTq;dTq(end)];
%     dUq=[dUq;dUq(end)];
%     spArray=simout(:,4);
%     NNArray=[dTq dUq tempReal UReal spArray];
    
%     %derivative from control signals using only DT
%     dTqDT=diff(refTempDTFault)-diff(refTempDT);
%     dUqDT=diff(refUDTFault)-diff(refUDT);
%     dTqDT=[dTqDT;dTqDT(end)];
%     dUqDT=[dUqDT;dUqDT(end)];
    
    %Plot results
    %real behavior vs fault behaviors
    figure(1)
    subplot(2,1,1)
    plot(tempReal)
    hold on
    plot(refTempDT)
    hold on
    plot(refTempDTFault)
    legend('Real fault','DT nominal','DT Fault')
    
    faultMatchTemp=goodnessOfFit(tempReal,refTempDTFault,'NRMSE')
    
    subplot(2,1,2)
    plot(UReal)
    hold on
    plot(refUDT)
    hold on
    plot(refUDTFault)
    legend('Real fault','DT nominal','DT Fault')
    faultMatchU=goodnessOfFit(UReal,refUDTFault,'NRMSE')
    %Temp and U derivatives
    figure(2)
    subplot(2,1,1)
    plot(diff(refTempDT))
    hold on
    plot(diff(tempReal))
    hold on
    plot(diff(refTempDTFault))
    legend('DT nominal','Real','DT Fault')
    
    subplot(2,1,2)
    plot(diff(refUDT))
    hold on
    plot(diff(UReal))
    hold on
    plot(diff(refUDTFault))
    legend('DT nominal','Real','DT Fault')
    
%     %difference of derivatives
%     figure(3)
%     subplot(2,1,1)
%     plot(dTq)
%     hold on
%     plot(dTqDT)
%     legend('delta T real','delta T DT')
%     subplot(2,1,2)
%     plot(dUq)
%     hold on
%     plot(dUqDT)
%     legend('delta U real','delta U DT')
%    
    
    
    
    
%     if i==1
%         inputVal=NNArray;
% %         targetsVal=aux.labelsFT';
%     else
%         inputVal=[inputVal;NNArray];
% %         targetsVal=[targetsVal;aux.labelsFT'];
%     end
%     
end

% 
% inputVal=inputVal';
% 
% outputVal = round(net(inputVal))
% % sim(net,inputVal)