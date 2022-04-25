%% resize real data for thresholding method and parity method detection

clear
load('fault5001.mat')

tempFault=[simout(:,3),simout(:,2)];
controlFault=[simout(:,3),simout(:,1)];
referenceData=[ones(length(tempFault),1) 50*ones(length(tempFault),1)];


