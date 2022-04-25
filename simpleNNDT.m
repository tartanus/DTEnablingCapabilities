%% basic neural network
clear; close all;clc;
%dataset reading and separation between validation and training
%read training dataset
filedir="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\faultTraining\";
listing=dir(fullfile(filedir,'*.mat'));
for i=1:length(listing)
    aux=load(filedir+listing(i).name);    
    if i==1
        input=aux.NNArray;
        targets=aux.labelsFT';
    else
        input=[input;aux.NNArray];
        targets=[targets;aux.labelsFT'];
    end
end

input=input';
targets=targets';

% faultPos1=sum(length(find(targets==1)))
% faultPos2=sum(length(find(targets==2)))
% faultPos3=sum(length(find(targets==3)))
% faultPos4=sum(length(find(targets==4)))

%% train pattern NN

%change labels for pattern recognition
targetsClass=zeros(3,length(targets));
for i=1:length(targets)
    if targets(i)==1
        targetsClass(:,i)=[1;0;0];    
    elseif targets(i)==2
        targetsClass(:,i)=[0;1;0];
    elseif targets(i)==3
        targetsClass(:,i)=[0;0;1];
%     elseif targets(i)==4
%         targetsClass(:,i)=[0;0;0;1];
    end
end
%train patternNetwork
hiddenLayerSize = 10;
netPattern = patternnet(hiddenLayerSize);
[netPat,trPat] = train(netPattern,input,targetsClass);
%NN validation
outputVal = round(netPat(input));
% sim(net,inputVal)
% confusionmat(round(targetsClass),outputVal)
plotconfusion(targetsClass,outputVal)
genFunction(netPat,strcat('faultNet3'));
genFunction(netPat,'faultNet3Mat','MatrixOnly','yes'); %generate function compatible with c code generator



%% train network (no patterns, just prediction)
net = feedforwardnet(10);
[net,tr] = train(net,input,targets);
output = round(net(input(:,5)));   %1
output = round(net(input(:,2496)));%4
output = round(net(input(:,2991)));%2
output = round(net(input(:,5337)));%3

%NN validation
outputVal = round(net(input));


% outputVal = abs(round(net(inputVal)))
for i=1:length(outputVal)
    if outputVal(i)>=4
        outputVal(i)=3;
        
    end
end
    
% sim(net,inputVal)
figure()
confusionmat(round(targets),outputVal)
plotconfusion(categorical(round(targets)),categorical(outputVal))
set(gca,'FontSize',18)

genFunction(net,'faultNet2');
genFunction(net,'faultNet2Mat','MatrixOnly','yes'); %generate function compatible with c code generator



%% validate network with simulation data
%dataset reading and separation between validation and training
%read training dataset
% load("faultNet11.mat")
% load("ne2.mat")
filedir="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\validationTraining\";
listing=dir(fullfile(filedir,'*.mat'));
for i=1:length(listing)
    aux=load(filedir+listing(i).name);    
    if i==1
        inputVal=aux.NNArray;
        targetsVal=aux.labelsFT';
    else
        inputVal=[inputVal;aux.NNArray];
        targetsVal=[targetsVal;aux.labelsFT'];
    end
end

inputVal=inputVal';
targetsVal=targetsVal';


%NN validation
outputVal = round(net(inputVal));
% outputVal = round(netPat(inputVal));
% sim(net,inputVal)
figure()
confusionmat(round(targetsVal),outputVal)
plotconfusion(categorical(round(targetsVal)),categorical(outputVal))
set(gca,'FontSize',18)

%% validation with real data
clear;close all;clc;
load("netFaultDT.mat")
filedir="C:\Users\jairo\Dropbox\doctorado UC\yangquan assignments\DT peltier\DT enabling capabilities\realFaultsData\";
listing=dir(fullfile(filedir,'*.mat'));
for i=1:length(listing)
    %load real data from experiment
    load(filedir+listing(i).name)
   
    %set results for NN classification
    tempReal=simout(:,2)+273.15;
    UReal=simout(:,1);
    spArray=simout(:,4)+273.15;
    error=spArray-tempReal;
    NNArray=[tempReal UReal spArray error];

    if i==1
        inputVal=NNArray;
         targetsVal=label';
    else
        inputVal=[inputVal;NNArray];
        targetsVal=[targetsVal;label'];
    end
    
end


inputVal=inputVal';

outputVal = abs(round(net(inputVal)))
for i=1:length(outputVal)
    if outputVal(i)>=4
        outputVal(i)=3;
        
    end
end
    
    
% outputVal = round(netPat(inputVal));
% sim(net,inputVal)
outSum=[targetsVal outputVal']

confusionmat(categorical(round(targetsVal)),categorical(outputVal'));
plotconfusion(categorical(round(targetsVal)),categorical(outputVal'))
set(gca,'FontSize',18)




