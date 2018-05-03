clear all;
addpath('bin');

load Data/SinoDS10.mat
ParamSetting;


% % % sinogram gap mask 
% mask = ones(param.nR, param.nA, 'uint8'); % if gap is interpolated
mask = uint8(mask);


%% SART
param.nsubset = 1;
Norimg = PETbackproj3d(PETproj3d(ones(param.nx,param.ny,param.nz,'single'),param,0),mask,param,0);

param.nsubset = 16;
BG = ScSino; % Scatter + random
img = zeros(param.nx, param.ny, param.nz, 'single');

%%
beta = 0.2;

for iter = 1:10
    
    for isubset = 0:param.nsubset-1
        
        tic;
        % diff back projection
        sino_diff = PETproj3d(img,param,isubset) + BG(:,isubset+1:param.nsubset:end,1:param.nSinogram) - SinoDS(:,isubset+1:param.nsubset:end,1:param.nSinogram);
        Diffimg = PETbackproj3d(sino_diff,mask,param,isubset);
        
        % Quadratic penalty (img, param, # of neighbor pixels: more pixel more blurr)
        [NU, DE] = quadratic3D(img, param, 1);
        
        % update
        img = max(img- (Diffimg+beta.*NU)./(Norimg+beta.*DE),0);
        img(isnan(img))=0;
        
        figure(11); 
        subplot(1,3,1); imagesc(max(img(:,:,round(end/2)),0)); axis off; axis equal; colormap gray; colorbar;   title(['iter - ',num2str(iter),' || sub - ',num2str(isubset)]);
        subplot(1,3,2); imagesc(max(squeeze(img(:,round(end/2),:))',0)); axis off; axis equal; colormap gray; colorbar;   title(['iter - ',num2str(iter),' || sub - ',num2str(isubset)]);
        subplot(1,3,3); imagesc(max(squeeze(img(round(end/2),:,:))',0)); axis off; axis equal; colormap gray; colorbar;   title(['iter - ',num2str(iter),' || sub - ',num2str(isubset)]);
        pause(0.01);
        exetime = toc;
        
        disp([num2str(iter),' - iteration done.. ','/ Exe. time (sec) : ', num2str(exetime)]);
    end
end
