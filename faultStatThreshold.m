%statistical thresholding fault detection
function [y,y2,y3,s0FaultTemp,s0FaultU,errorTemp]= faultStatThreshold(u)
    %steady state regime time
    tss=200;
    %temperature conversion
    temp=u(1);
    %setpoint selector and probability distribution selection
    sp=u(3);
    switch sp
        case 50
            mu=50; sigma=0.1576;
            muC=70.2694; sigmaC=7.02037;
        case 60
            mu=59.99; sigma=0.12;
            muC=70.2694; sigmaC=7.02037;
        case 90
            mu=90.01; sigma=0.0918;
            muC=70.2694; sigmaC=7.02037;
        otherwise
            mu=sp; sigma=0.1;
            muC=70.2694; sigmaC=7.02037;
    end
    y=0;
    ub=3*sigma+mu;      %upper boundary for temperature
    lb=-3*sigma+mu;     %lower boundary for temperature
    ubc=3*sigmaC+muC;   %upper boundary for control
    lbc=-3*sigmaC+muC;  %lower boundary for control
    
    %condition 2 indicator (same response)
     c2Ind= u(1)==u(6) && u(6)==u(7);

        
    %statistical thresholding normal distribution
    %condition for fault 1
    if (temp>=lb && temp<=ub) && (u(5)>=tss)
        y=1; %nominal
    elseif (u(5)<tss)
        y=1;
    elseif (temp<lb && u(2)>=ubc && c2Ind==1 ) && (u(5)>=tss)
        y=3;  %sensor fault
    else
        y=2; %actuator fault
    end
    y2=temp;
    
    
    %statistical thresholding alpha stable using geometric power
    %sliding window for geometric power claculation
    %only works for 50 degrees setpoint
    tempAlpha=[u(1) u(6) u(7) u(8) u(9) u(10)];
    uAlpha=[u(2) u(11) u(12) u(13) u(14) u(15)];
    s0FaultTemp=exp(mean(log(abs( tempAlpha  ))));
    s0FaultU=exp(mean(log(abs( uAlpha  ))));
    %decision threshold
    if (s0FaultTemp>=49 && s0FaultTemp<=51) && (u(5)>=tss)
        y2=1; %nominal
    elseif (u(5)<tss)
        y2=1;
    elseif (c2Ind==1) && (u(5)>=tss)
        y2=3;  %sensor fault
    else
        y2=2; %actuator fault
    end
    
    % Parity fault detection
    errorTemp=  u(16) - temp;
    errorU=     u(17) - u(2);
    parityUBTemp=-0.05+3*0.1753;
    parityLBTemp=-0.05-3*0.1753;
    
    parityUBU=-0.2+3*7.1;
    parityLBU=-0.2-3*7.1;
    y3=0;
    if(errorTemp>=parityLBTemp && errorTemp<=parityUBTemp)
        y3=1;
    elseif    (errorTemp>=parityLBTemp && c2Ind==1)    
        y3=3;    
        
    elseif    (errorTemp>=parityUBTemp)
        y3=2;
    
    else
        y3=0;
    end        
    
    
end




