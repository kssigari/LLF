# LLF

Hello,

I am Kyungsang Kim. (kssigari(at)gmail.com, kkim24(at)mgh.harvard.edu) 

The code was used for the following paper: 
Kyungsang Kim et al. "Penalized PET reconstruction using deep learning prior and local linear fitting", IEEE Transactions on Medical Imaging.

Please read below carefully because data files are provided with link.

Abstract

Motivated by the great potential of deep learning in medical imaging, we propose an iterative positron emission tomography (PET) reconstruction framework using a deep learning-based prior. We utilized the denoising convolutional neural network (DnCNN) method and trained the network using full-dose images as the ground truth and low dose images reconstructed from downsampled data by Poisson thinning as input. Since most published deep networks are trained at a predetermined noise level, the noise level disparity of training and testing data is a major problem for their applicability as a generalized prior. In particular, the noise level significantly changes in each iteration, which can potentially degrade the overall performance of iterative reconstruction. Due to insufficient existing studies, we conducted simulations and evaluated the degradation of performance at various noise conditions. Our findings indicated that DnCNN produces additional bias induced by the disparity of noise levels. To address this issue, we propose a local linear fitting (LLF) function incorporated with the DnCNN prior to improve the image quality by preventing unwanted bias. We demonstrate that the resultant method is robust against noise level disparities despite the network being trained at a predetermined noise level. By means of bias and standard deviation studies via both simulations and clinical experiments, we show that the proposed method outperforms conventional methods based on total variation (TV) and non-local means (NLM) penalties. We thereby confirm that the proposed method improves the reconstruction result both quantitatively and qualitatively.

Details:

0. Linux/Windows Compatible (Sorry for Mac users: difficult to link openmp)

1. We provide pre-compiled Simens-type projector and backprojector,
Parallel computing based on OpenMP is used. "libomp" should be linked.
First you can try Demo_OPOSEM.m, if you see errors please check this:

    1.1) Linux:
    https://www.mathworks.com/matlabcentral/answers/125117-openmp-mex-files-static-tls-problem

    1.2) Windows:
    I have not seen errors yet, but if you see errors, please let me know.

    +extra) The Geometric parameters are in ParamSetting.m
            This code can be used for HR+, Biograph as well.
            You can change ParamSetting.m, 
            The sinogram should be arc-corrected! 
            (Please study: Michellogram and arc-correction)


2. Sinograms in Data folder
We provide one clinical data for test.
The scanner is the high-resolution research tomograph (HRRT) dedicated for brain studies, Siemens.
We provide full data (4800 sec), and downsampled data for 4x, 6x, 8x, 10x. 

    Please download the "Data" folder: https://www.dropbox.com/sh/33kqnvbbclhvscr/AACAj0_qmCZby_yjKZjuCdLia?dl=0


3. Demo examples

    4.1 OPOSEM (ordinary poisson ordered subsets expectation maximization)
    
    4.2 OS-SQS+Non local means penalty (ordered subsets separable quadratic surrogates):
        Non-local means implementation is clearly explained in this paper:
        Kim et al. "Low-dose CT reconstruction using spatially encoded nonlocal penalty", Medical Physics.

    4.3 Proposed method: OS-SQS + DnCNN + local linear fitting (LLF)

    +4.4 OS-SART + Quadratic penalty (for researchers)


4. Install Caffe version 1
Please install Caffe with Matlab option on. 
First install CPU version, and if it works, then try to install GPU version.
GPU version is more complicated. So if you just want to compare with your results and you are not a Caffe user,
I highly recommend to install CPU version. But computational time will be very slow.

These are pre-trained outputs:
"DnCNN_6ds_iter_100000.caffemodel"
"DnCNN_6ds_iter_100000.solverstate"

The network is:
"DnCNN_deploy_test.prototxt"

After installation Caffe v1,
please open "bin/DnCNN_prior.m" and "bin/DnCNN_prior_grad.m"
and then change this option:

//////////////////////

caffe.set_mode_gpu();

gpu_id = 0;

caffe.set_device(gpu_id);

//////////////////////

if you use CPU or another GPU number, change this:
ex) caffe.set_mode_cpu();
or gpu_id = 2;

Enjoy,

Kyungsang






















