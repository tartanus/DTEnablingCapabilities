%% validation with real data
clear;close all;clc;
% load("faultNet11.mat")
filedir="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\prognosisData\";
listing=dir(fullfile(filedir,'*.mat'));
for i=1:length(listing)
    %load real data from experiment
    load(filedir+listing(i).name)

    %Plot results
    %real behavior vs fault behaviors
    figure(1)
    subplot(2,2,1)
    plot(tempDT)
    hold on

    subplot(2,2,2)
    plot(UDT)
    hold on
    
    subplot(2,2,3)
    plot(errorSignal)
    hold on
    
    subplot(2,2,4)
    plot(dTq)
    hold on
    
    %health indicators
    time1(i)=i;
    tempDTMean(i)=mean(tempDT(200:end));
    tempDTStd(i)=std(tempDT(200:end));
    controlDTMean(i)=mean(UDT(200:end));
    controlDTStd(i)=std(UDT(200:end));
    tempRMS(i)=rms(tempDT(200:end));
    controlRMS(i)=rms(UDT(200:end));
    errorRMS(i)=rms(errorSignal(200:end));
    resDeg(i)=resistance;

end
T=table(time1',resDeg',tempDTMean',tempDTStd',controlDTMean',controlDTStd',tempRMS',controlRMS',errorRMS')

TSortedTemp=sortrows(T,2,'descend') %table sorted by temperature mean assuming setpoint of 50 in steady state

resPlot=sort(table2array(TSortedTemp(:,2)));
tempDTMean=table2array(TSortedTemp(:,3));
tempDTVar=table2array(TSortedTemp(:,4));
figure(2)
subplot(2,1,1)
plot(tempDTMean)
subplot(2,1,2)
plot(tempDTVar)

%% linear degradation model of a component RUL estimation
% load('healthIndicatorsTemp.mat')
load('healthIndicatorsControl.mat')
%quick data transformation
for i=1:length(healthIndicators)
    time=(healthIndicators{1,1}');
    tempHealth=(healthIndicators{1,2}');
    info{i}=table(time,tempHealth);
    
end
% %quick data transformation
% for i=1:length(healthIndicatorsTemp)
%     time=(healthIndicatorsTemp{1,1}');
%     tempHealth=(healthIndicatorsTemp{1,2}');
%     info{i}=table(time,tempHealth);
%     
% end
info=info';
auxTest=info{1}
test=auxTest(50,:)

mdl = linearDegradationModel('LifeTimeUnit',"hours");
fit(mdl,info,"time","tempHealth")
% load('linTestData.mat','linTestData1')
threshold = 11.5;
estRUL = predictRUL(mdl,test,threshold)

aux=table2array(auxTest(:,2))';
for i=1:length(aux)-1
    
    estRULHist(i) = predictRUL(mdl,aux(i:end),threshold)

end
plot(estRULHist)







