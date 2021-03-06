function [Y,Xf,Af] = faultNet2(X,~,~)
%FAULTNET2 neural network simulation function.
%
% Auto-generated by MATLAB, 05-Jul-2021 15:07:54.
% 
% [Y] = faultNet2(X,~,~) takes these arguments:
% 
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = 4xQ matrix, input #1 at timestep ts.
% 
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = 1xQ matrix, output #1 at timestep ts.
% 
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [295.889396902697;-254.410855826584;23;-273.541788251811];
x1_step1.gain = [0.029562886989156;0.00392610400254377;0.00587975892988388;0.00587081915650398];
x1_step1.ymin = -1;

% Layer 1
b1 = [-14.823865870882947604;-14.403906516874299015;4.7102719335528862032;-213.95316623571457626;-13.519706043795503447;-5.7666605559376256096;68.996363903059105382;-234.1559519404287073;-190.75112104149542347;13.571481669041524754];
IW1_1 = [-9.7927122831534223479 4.207996049947990258 -3.016958054697627567 4.0335758211941925566;-9.9052913862553690905 3.7166139021242505791 -3.2729419617624340155 4.3031675870619467972;-5.3132821141733659331 22.738815999368885201 -11.349194431038222675 -9.6324424173470717392;-482.94423272296415917 -236.06900870920961211 -67.903105912054172677 68.007297693044804987;-1.0192624516482369224 -3.3227227252179210026 10.02038447464019022 12.372088429771991969;-1.1280366291554413394 1.700885861952090794 2.9654028301094439435 3.6860163017283955611;-15.159992543411901167 81.699505599608372108 -70.998921651204923933 -78.591148326669980406;-529.24648077545396063 -259.10416029118732695 -76.032718748278782073 76.162366350449261176;-430.50591373522149752 -210.25029818168502516 -61.637186215391643884 61.708580387646691179;1.2005271587915002929 3.4634753355322729362 -11.083507842969435586 -11.317798665785771206];

% Layer 2
b2 = -3.4535976524586251557;
LW2_1 = [-44.004329958282852431 41.269190468871840949 -0.27367336172074435696 58.246415266023419122 -6.2223542560709095284 0.55316945789952887136 0.50592875814649018729 -36.702473428044548598 -21.541554109595566047 -6.1814296073888197469];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = 1;
y1_step1.xoffset = 1;

% ===== SIMULATION ========

% Format Input Arguments
isCellX = iscell(X);
if ~isCellX
  X = {X};
end

% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
  Q = size(X{1},2); % samples/series
else
  Q = 0;
end

% Allocate Outputs
Y = cell(1,TS);

% Time loop
for ts=1:TS

    % Input 1
    Xp1 = mapminmax_apply(X{1,ts},x1_step1);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = repmat(b2,1,Q) + LW2_1*a1;
    
    % Output 1
    Y{1,ts} = mapminmax_reverse(a2,y1_step1);
end

% Final Delay States
Xf = cell(1,0);
Af = cell(2,0);

% Format Output Arguments
if ~isCellX
  Y = cell2mat(Y);
end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
  y = bsxfun(@minus,x,settings.xoffset);
  y = bsxfun(@times,y,settings.gain);
  y = bsxfun(@plus,y,settings.ymin);
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
  a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
  x = bsxfun(@minus,y,settings.ymin);
  x = bsxfun(@rdivide,x,settings.gain);
  x = bsxfun(@plus,x,settings.xoffset);
end
