

%% Parameter setting %%
% Sinogram domain
param.nR = 256;	% radial bin
param.nA = 288; % azimuthal bin

param.dr = 1.218750; % mm
param.da = 3.141592/param.nA;  % radian

% Image domain
param.nx = 256; % number of pixels
param.ny = 256;
param.nz = 207;

param.dx = param.dr; % mm
param.dy = param.dr;
param.dz = param.dr;	

% % filter option: 'ram-lak'(no lowpass), 'hamming', 'hann', ... 
param.filter='hamming'; % 

% % 3D sinogram setting: If you don't know "segment", please study "michelogram"
param.Span = 9;
param.Segment = 3; 

% % Geometric parameter
param.diameter = 469;  % mm
param.radius = param.diameter/2;


%% Related variables for calculation (Auto calculation)
param.sumSino = zeros(param.Segment+1,1);
param.nSino = zeros(param.Segment+1,1);

param.nSinogram = param.nz;
param.sumSino(1) = param.nz;
param.nSino(1) = param.nz;
for i=1:param.Segment        
    param.nSino(i+1) = ((param.nz - (param.Span+1))-(i-1)*2*param.Span);
    param.nSinogram = param.nSinogram + 2*param.nSino(i+1);    
    param.sumSino(i+1) = param.nSinogram;
end

param.tan_seg = zeros(param.Segment+1,1);
param.cos_seg = zeros(param.Segment+1,1);
param.tan_seg(1) = 0;
param.cos_seg(1) = 1;
for i=1:param.Segment        
    param.tan_seg(i+1) = param.Span*i*param.dz/param.radius;
    param.cos_seg(i+1) = 1/sqrt(1+param.tan_seg(i+1)^2);
end

%% iteration setting
param.niter =6;  % iteration number
param.nsubset = 16; % subsets
