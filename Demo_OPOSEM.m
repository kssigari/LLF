clc;
clear all;
addpath('bin');
ParamSetting;

%%

load('Data/SinoFDGfull.mat');
Downsamplingfactor = 1; % 1 (full), 4, 6, 8, 10

if Downsamplingfactor>1
    load(['Data/SinoDS',num2str(Downsamplingfactor),'.mat']);
    Sino = SinoDS;
else
    Sino = PromptSino.*AttSino;
end

BG = ScSino;

%% initial reconstruction

img = ones(param.nx,param.ny,param.nz,'single');
sino = zeros(param.nR, param.nA/param.nsubset, param.nSinogram,'single');

EPS = 1e-8;

for iter = 1:param.niter
    for sub = 0:param.nsubset-1
        
        RatioSino =  (Sino(:,sub+1:param.nsubset:param.nA,:)+EPS)./(PETproj3d( img, param, sub )+BG(:,sub+1:param.nsubset:param.nA,:)+EPS);
        RatioSino(isnan(RatioSino)) = 0;
        RatioSino(isinf(RatioSino)) = 0;
        
        Norimg = PETbackproj3d( ones(param.nR,param.nA/param.nsubset,param.nSinogram,'single'), mask, param, sub);
        Ratioimg = PETbackproj3d( RatioSino , mask, param, sub);
        
        img = max(img.*Ratioimg./Norimg ,0);
        img(isnan(img)) = 0;
        img(isinf(img)) = 0;
        
        figure(11); imagesc(img(:,:,round(end/2))); axis off; axis equal; colormap gray; colorbar; title(['Iter:',num2str(iter),' / subset:',num2str(sub)])
        pause(0.01);
    end
end

img_osem = img;
save('-v7.3',['Data/OPOSEM_DS',num2str(Downsamplingfactor),'.mat'],'img_osem');
