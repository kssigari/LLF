clear all;

%% Geometric parameter setting
addpath('bin'); % function add
ParamSetting;

% % Gradient of DnCNN with respect to image takes longer time,
% % The value is very small compared to other terms.
% % You can skip the Gradient of DnCNN to get result faster.
% % 0 - Skip, 1 - using Gradient
Opt = 0;

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
gamma = 0.1;
alpha = 1;

%% initialization
img= img_osem; 
img_DnCNN = img;
q = ones(size(img),'single');
b = zeros(size(img),'single');
z = img*2; 
eta = zeros(size(img),'single');
EPS = 1e-8;

%% Iterative reconstruction

for iter = 1:4
    
    % caffe in matlab is unstable sometimes.
    reset(gpuDevice(1)); 
    
    for sub = 0:param.nsubset-1
        
        % Calculating DnCNN f_w(x)
        img_DnCNN = max(DnCNN_prior(img)  ,0);
        
        % Update x^D
        imgD = (beta.*q.*img - beta.*q.*b + gamma.*img_DnCNN + gamma.*eta)./(beta.*q.*q + gamma);
        
        % Update z
        z = (img + q.*imgD + b); 
        
        % Update q, b
        [img_D_LLF, q, b] = LLF3d(img, imgD , 5); % img_D_LLF = q.*imgD + b; 
        
        % Update gradient of DnCNN with respect to image
        if Opt == 1
            if mod(sub,4) == 0
                img_grad = DnCNN_prior_grad(img, imgD - img_DnCNN - eta);
            end        
        else
            img_grad = 0;
        end
        
        % SQS calculation
        RatioSino =  1 - (Sino(:,sub+1:param.nsubset:param.nA,:)+EPS)./(PETproj3d( img, param, sub )+BG(:,sub+1:param.nsubset:param.nA,:) + EPS);
        Norimg = PETbackproj3d( PETproj3d(ones(param.nx,param.ny,param.nz,'single'),param,sub) ./ (Sino(:,sub+1:param.nsubset:param.nA,:) + EPS), mask, param, sub);
        Ratioimg = PETbackproj3d( RatioSino , mask, param, sub);
        
        % Update image
        img = max(img- (Ratioimg./Norimg + beta.*(2*img-z)-gamma.*img_grad)./(1 + 2*beta + alpha*gamma),0); 
        img(isnan(img)) = 0;
        img(isinf(img)) = 0;
        
        % Update Lagrangian parameter
        eta = eta - (imgD - img_DnCNN); 
        
        figure(21); 
        subplot(2,2,1); imagesc(img(:,:,round(end/2))); axis off; axis equal; colormap gray; colorbar;
        subplot(2,2,2); imagesc(img_DnCNN(:,:,round(end/2))); axis off; axis equal; colormap gray; colorbar;
        subplot(2,2,3); imagesc(z(:,:,round(end/2))); axis off; axis equal; colormap gray; colorbar;
        subplot(2,2,4); imagesc(img_D_LLF(:,:,round(end/2))); axis off; axis equal; colormap gray; colorbar;
        title(['Outer: ',num2str(iter),' / Subset: ',num2str(sub)]);
        pause(0.01);
        
    end

end


