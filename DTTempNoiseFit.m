%% DT fault detection script configuration
clear all;close all;clc;
filename = 'DTBHInitData90Ref.mat';
load(filename);
%input and output in string format
u=uRecord(:,2);
y=tempRecord(:,2);
section=200;
tempNoiseData=y(section:end);
uNoiseData=u(section:end);
figure(1)
% subplot(2,1,1)
timeAxis=section:1:length(y);
plot(timeAxis,tempNoiseData)
xlabel('Time (s)')
ylabel('Temperature (°C)')
set(gca,'Fontsize',14);

figure(2)
% subplot(2,1,1)
timeAxis=section:1:length(y);
plot(timeAxis,uNoiseData)
xlabel('Time (s)')
ylabel('Control (pwm)')
set(gca,'Fontsize',14);
% subplot(2,1,2)
% hist(tempNoiseData)

%fit noise with probability distribution for temperature
pd = fitdist(tempNoiseData,'stable')    %fit stable alpha distribution for the delay data
pdn= fitdist(tempNoiseData,'normal')    %fit into a normal distribution
y_val=min(tempNoiseData)-1:0.01:max(tempNoiseData);
tempAlpha = pdf(pd,y_val);
tempNorm  = pdf(pdn,y_val);

%fit noise with probability distribution for control action
pdU = fitdist(uNoiseData,'stable')    %fit stable alpha distribution for the delay data
pdnU= fitdist(uNoiseData,'normal')    %fit into a normal distribution
u_val=min(uNoiseData)-1:0.01:max(uNoiseData)+10;
uAlpha = pdf(pdU,u_val);
uNorm  = pdf(pdnU,u_val);


%% Histogram represenation for output and control action
figure(1)
%Temperature
h = histogram(tempNoiseData,'Normalization','pdf','FaceColor',[.9 .9 .9]);
xlabel('Temperature');
ylabel('Probability Density');
ylim([0 5]);
line(y_val,tempAlpha)
hold on
line(y_val,tempNorm,'Color','red')
legend('Noise','Alpha','Normal')
xlim([min(tempNoiseData)-1 max(tempNoiseData)])
hold off

%control
figure(2)
h = histogram(uNoiseData,'Normalization','pdf','FaceColor',[.9 .9 .9]);
xlabel('Control action');
ylabel('Probability Density');
ylim([0 0.1]);
line(u_val,uAlpha)
hold on
line(u_val,uNorm,'Color','red')
legend('Noise','Alpha','Normal')
xlim([min(uNoiseData)-1 max(uNoiseData)+10])
hold off


%% %kolmogorov test for ft the alpha and normal distribution

%in this case the kolmogorov test rejects the null hypotesis
%and the delay does not have a normal distribution
x = (tempNoiseData-mean(tempNoiseData))/std(tempNoiseData);
[h p ksstat cv]= kstest(x)       %test for normal distribution with 5% of significance level

%1 no normal distriution
%0 is a normal distribution

%kolmogorov test for the alpha distribution
test_cdf = makedist('stable',pd.ParameterValues(1),pd.ParameterValues(2),pd.ParameterValues(3),pd.ParameterValues(4));
[h p ksstat cv]= kstest(tempNoiseData,'CDF',test_cdf,'Alpha',0.05)



%kolmogorov test control action
%for ft the alpha and normal distribution
%in this case the kolmogorov test rejects the null hypotesis
%and the delay does not have a normal distribution
x = (uNoiseData-mean(uNoiseData))/std(uNoiseData);
[h pu ksstat cv]= kstest(x)       %test for normal distribution with 5% of significance level

%1 no normal distriution
%0 is a normal distribution

%kolmogorov test for the alpha distribution
test_cdf = makedist('stable',pdU.ParameterValues(1),pdU.ParameterValues(2),pdU.ParameterValues(3),pdU.ParameterValues(4));
[h pu ksstat cv]= kstest(uNoiseData,'CDF',test_cdf,'Alpha',0.05)



%%
%cumulative probability distribution functions
%empirical, alpha stable and normal
figure()
subplot(1,2,1)
cdfplot(tempNoiseData)
hold on
x_values = linspace(min(tempNoiseData),max(tempNoiseData)); %empirical CDF
plot(x_values,cdf(pd,x_values),'r-')        %alpha stable
plot(x_values,normcdf(x_values,mean(tempNoiseData),std(tempNoiseData)),'g-') %normal distribution
%plot(x_values,cdf(test_cdf1,x_values,'y-')) %normal distribution
legend('Empirical CDF','Alpha-Stable','Normal','Location','best')

subplot(1,2,2)
cdfplot(uNoiseData)
hold on
x_values = linspace(min(uNoiseData),max(uNoiseData)); %empirical CDF
plot(x_values,cdf(pdU,x_values),'r-')        %alpha stable
plot(x_values,normcdf(x_values,mean(uNoiseData),std(uNoiseData)),'g-') %normal distribution
%plot(x_values,cdf(test_cdf1,x_values,'y-')) %normal distribution
legend('Empirical CDF','Alpha-Stable','Normal','Location','best')

%% alpha stable low order statistic
load('fault5001.mat')
section=190;
tempNoiseFault=simout(section:end,2)
uNoiseFault=simout(section:end,1)
% 
% tempNoiseDataN=y(section:end);
% uNoiseDataN=u(section:end);

sector=30;

% s0NominalTemp=exp(mean(log(abs(tempNoiseDataN(195:195+4)))))

for i=1:5:length(tempNoiseFault)-5
%     s0NominalTemp(i)=exp(mean(log(abs(tempNoiseDataN(i:i+4)))));
    s0FaultTemp(i)=exp(mean(log(abs(tempNoiseFault(i:i+4)))));
%     s0NominalU(i)=exp(mean(log(abs(uNoiseDataN(i:i+4)))));
    s0FaultU(i)=exp(mean(log(abs(uNoiseFault(i:i+4)))));
end

figure(1)
subplot(1,2,1)
plot(s0NominalTemp)
hold on
plot(s0FaultTemp)
legend('Nominal','Fault')
subplot(1,2,2)
plot(s0NominalU)
hold on
plot(s0FaultU)
legend('Nominal','Fault')

cg=1.78;
alphaAlt=1.83;
gamma=0.0752;

s0Alt=(gamma)^(1/alphaAlt)










