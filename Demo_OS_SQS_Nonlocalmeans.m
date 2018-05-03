clear all;

%% Geometric parameter setting
addpath('bin'); % function add
ParamSetting;

%% Downsampling study for 4, 6, 8, 10
Downsamplingfactor = 10; 

load(['Data/SinoDS',num2str(Downsamplingfactor),'.mat']);
load('Data/SinoFDGfull.mat');
load(['Data/OPOSEM_DS',num2str(Downsamplingfactor),'.mat']); % for initialization

Sino = SinoDS;
clear SinoDS;
BG = ScSino;
clear ScSino;

sino = zeros(param.nR, param.nA/param.nsubset, param.nSinogram,'single');

%% Hyper-parameter
beta = 0.04;

%% initialization
img= img_osem; 
EPS = 1e-8;

patchsize_half = 1;
windowsize_half = 1;
sigma = 1;

%% Iteration
for iter = 1:4
        
    for sub = 0:param.nsubset-1
        
        % Calculating NLM
        img_nlm = FAST_NLM_3d(img,patchsize_half,windowsize_half,sigma);
                
        % SQS calculation
        RatioSino =  1 - (Sino(:,sub+1:param.nsubset:param.nA,:)+EPS)./(PETproj3d( img, param, sub )+BG(:,sub+1:param.nsubset:param.nA,:) + EPS);
        Norimg = PETbackproj3d( PETproj3d(ones(param.nx,param.ny,param.nz,'single'),param,sub) ./ (Sino(:,sub+1:param.nsubset:param.nA,:) + EPS), mask, param, sub);
        Ratioimg = PETbackproj3d( RatioSino , mask, param, sub);
        
        % Update image
        img = max(img- (Ratioimg./Norimg + beta.*(img-img_nlm))./(1 + beta),0); 
        img(isnan(img)) = 0;
        img(isinf(img)) = 0;
        
        figure(31); 
        subplot(1,2,1); imagesc(img(:,:,round(end/2))); axis off; axis equal; colormap gray; colorbar;
        subplot(1,2,2); imagesc(img_nlm(:,:,round(end/2))); axis off; axis equal; colormap gray; colorbar;
        title(['Outer: ',num2str(iter),' / Subset: ',num2str(sub)]);
        pause(0.01);
        
    end

end

img_nlm = img;
save('-v7.3',['Data/OSSQS_nlm_DS',num2str(Downsamplingfactor),'.mat'],'img_nlm');