function [ img_grad ] = DnCNN_prior_grad( img, res )
%DnCNN Summary of this function goes here
%   Detailed explanation goes here
% addpath(genpath('C:/caffe/caffe-master/matlab'));

%%
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

img_grad = zeros(nx, ny, nz, 'single');

Scaling = 100./mean(img(img>0)); % we have trained with this scale.

img = img*Scaling;

% % Gradients of CNN about image have values only at near voxels.
% % Thus we can calculate garadients of voxels in parallel.
% % Voxels for the same gradient calculation should have a certain distance 
% % to avoid affecting gradient to each other, here, we use "parallel_term"
parallel_term = 5;
stepsize = 0.1;

for iz = 1+hslice:1:nz-hslice
    
    img_noise = img(:,:,iz-hslice:iz+hslice); 
    img_res = res(:,:,iz-hslice:iz+hslice); 
   
    grad_img = zeros(nx, ny, 'single');
    
    % Numerical gradient: grad f(x)/x_j = (f(x_j+a) - f(x_j-a))/(2a)
    % a - stepsize
    for islice = hslice
        for idx =1:parallel_term
            for idy = 1:parallel_term
                
                img_tmp = img_noise;
                img_tmp(idx:parallel_term:end, idy:parallel_term:end,islice) = img_tmp(idx:parallel_term:end, idy:parallel_term:end,islice) + stepsize;
                testpatch(:,:,1:5) = img_tmp;
                tmp_plus = net.forward({testpatch});
                tmp_plus = tmp_plus{1}(:,:,:);
                
                img_tmp = img_noise;
                img_tmp(idx:parallel_term:end, idy:parallel_term:end,islice) = img_tmp(idx:parallel_term:end, idy:parallel_term:end,islice) - stepsize;
                testpatch(:,:,1:5) = img_tmp;
                tmp_minus = net.forward({testpatch});
                tmp_minus = tmp_minus{1}(:,:,:);
                
                half = ceil((parallel_term-1)/2);
                
                img_diff = (tmp_plus - tmp_minus)/(2*stepsize).*img_res;
                img_diff_pad = padarray(img_diff,[half,half,0],0);
                tmp_sum = zeros(size(img_noise(idx:parallel_term:end, idy:parallel_term:end, islice)),'single');
                
                for ii = -half:half
                    for jj = -half:half
                        tmp = sum(img_diff_pad(idx+ii+half:parallel_term:end, idy+jj+half:parallel_term:end,:),3);
                        tmp_sum = tmp_sum + tmp(1:size(tmp_sum,1),1:size(tmp_sum,2));
                    end
                end
                
                grad_img(idx:parallel_term:end, idy:parallel_term:end) =  tmp_sum; 
                
            end
        end
    end
    img_proposed3d(:,:,iz-hslice:iz+hslice) = img_proposed3d(:,:,iz-hslice:iz+hslice) + repmat(grad_img,[1,1,nslice]);
    weight_overlap(iz-hslice:iz+hslice) = weight_overlap(iz-hslice:iz+hslice)+1;
end

for iz = 1:nz
    img_grad(:,:,iz) = img_proposed3d(:,:,iz)./weight_overlap(iz);
end
img_grad(isnan(img_grad)) = 0;

img_grad = img_grad./Scaling;


end

