%% evaluate data prognostability
clear;
load("resDeg501Up.mat");
[row,col]=size(healthIndicators);

for i=1:row
    clear aux
    for j=2:col
        aux(:,j-1)= healthIndicators{i,j}';
    end
    newHealth{i}=aux(:,1:7);
end
    figure(1)
    subplot(3,1,1)
    monotonicity(newHealth)
    set(gca,'Fontsize',14);
    subplot(3,1,2)
    prognosability(newHealth)
    set(gca,'Fontsize',14);
    subplot(3,1,3)
    trendability(newHealth)
    set(gca,'Fontsize',14);
    
    %plot health indicators
    indicatorsPlot=newHealth{1,:};
    figure(2)
    subplot(2,3,1)
    plot(indicatorsPlot(:,1))
    title("Var 1: Temp mean")
    subplot(2,3,2)
    plot(indicatorsPlot(:,2))
    title("Var 2: Temp std")
    subplot(2,3,3)
    plot(indicatorsPlot(:,3))
    title("Var 3: control mean")
    subplot(2,3,4)
    plot(indicatorsPlot(:,4))
    title("Var 4: control std")
    subplot(2,3,5)
    plot(indicatorsPlot(:,5))
    title("Var 5: Temp RMS")
    subplot(2,3,6)
    plot(indicatorsPlot(:,6))
    title("Var 6: control RMS")
    
    
%% calculate RUL
%% linear degradation model of a component RUL estimation
load("resDeg501Up.mat");
[row,col]=size(healthIndicators);
%quick data transformation
for i=1:row
    time=(healthIndicators{1,1}');
    tempHealth=(healthIndicators{1,5}');
    info{i}=table(time,tempHealth);
    
end
%split data for comparison
info=info';
auxTest=info{1};
test=auxTest(50,:);
figure(5)
plot(auxTest.time,auxTest.tempHealth)
hold on
thresholdLine=42.8*ones(1,length(auxTest.tempHealth));
plot(thresholdLine,'r+')
xlabel('Heating cycles batch (500 per division)')
ylabel('Health indicator: control mean')
set(gca,'Fontsize',14);

%calculate linear model
mdl = linearDegradationModel('LifeTimeUnit',"hours");
fit(mdl,info,"time","tempHealth")
threshold = 42.8;
estRUL = predictRUL(mdl,test,threshold)
aux=table2array(auxTest(:,2))';
estRULHist= predictRUL(mdl,auxTest(1,:),threshold);

%calculate exponential model
mdlExp = exponentialDegradationModel('LifeTimeUnit',"hours");
fit(mdlExp,info,"time","tempHealth")
% load('linTestData.mat','linTestData1')
threshold = 42.8;
estRUL = predictRUL(mdlExp,test,threshold)

%plot remaining useful life
[row,col]=size(auxTest);
for i=1:row
timeTest=i;
estRUL = predictRUL(mdl,auxTest(timeTest,:),threshold);
estRULExp = predictRUL(mdlExp,auxTest(timeTest,:),threshold);

remainingLife(i)=hours(estRUL)-table2array(auxTest(timeTest,1));
remainingLifeExp(i)=hours(estRULExp)-table2array(auxTest(timeTest,1));
if remainingLife(i)<=0
    remainingLife(i)=0;
    remainingLifeExp(i)=0;
end
end
plot(remainingLife)
hold on
plot(remainingLifeExp)
legend('Linear','Exponential')
xlabel('Heating cycles batch (500 per division)')
ylabel('RUL (Heating cycles batch)')




    
    