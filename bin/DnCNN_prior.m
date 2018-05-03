function [ img_denoised ] = DnCNN_prior( img )
%DnCNN Summary of this function goes here
%   Detailed explanation goes here
addpath(genpath('C:/caffe/caffe-master/matlab'));

% Please change if you use CPU
caffe.set_mode_gpu();
gpu_id = 0;
caffe.set_device(gpu_id);

net_weights = ['DnCNN_6ds_iter_100000.caffemodel']; 
net_model = ['DnCNN_deploy_test.prototxt'];
net = caffe.Net(net_model, net_weights, 'test');

[nx, ny, nz] = size(img);

nslice = 5;
hslice = round((nslice-1)/2);
    
img_proposed3d = zeros(nx, ny, nz, 'single');
weight_overlap = zeros(1, nz, 'single');

img_denoised = zeros(nx, ny, nz, 'single');

Scaling = 100./mean(img(img>0)); % we have trained with this scale

img = img*Scaling;

for iz = 1+hslice:1:nz-hslice
    
    img_noise = img(:,:,iz-hslice:iz+hslice);       
    testpatch(:,:,1:5) = img_noise;
    tmp = net.forward({testpatch});
    
    denoisedimg = tmp{1}(:,:,:);
    img_proposed3d(:,:,iz-hslice:iz+hslice) = img_proposed3d(:,:,iz-hslice:iz+hslice) + max(denoisedimg,0);
    weight_overlap(iz-hslice:iz+hslice) = weight_overlap(iz-hslice:iz+hslice)+1;
end

for iz = 1:nz
    img_denoised(:,:,iz) = img_proposed3d(:,:,iz)./weight_overlap(iz);
end
img_denoised(isnan(img_denoised)) = 0;

img_denoised = img_denoised./Scaling;

end

