
Hello,

I am Kyungsang Kim. (kssigari@gmail.com, kkim24@mgh.harvard.edu) 

I share the code used for the paper "Penalized PET reconstruction using deep learning prior and local linear fitting", 
IEEE Transactions on Medical Imaging.

0. Linux/Windows Compatible (Sorry Mac users: more difficult to link openmp)

1. We provide pre-compiled Simense-type projector and backprojector,
Parallel computing based on OpenMP is used. "libomp" should be linked.
First you can try Demo_OPOSEM.m, if you see errors please check this:

    1.1) Linux
    https://www.mathworks.com/matlabcentral/answers/125117-openmp-mex-files-static-tls-problem

    1.2) Windows
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


3. Demo examples

    4.1 OPOSEM (ordinary poisson ordered subsets expectation maximization)
    4.2 OS-SQS+Non local means penalty (ordered subsets separable quadratic surrogates)
        Non-local means implementation is clearly explained in this paper:
        "Low?dose CT reconstruction using spatially encoded nonlocal penalty", Medical Physics.

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

-------------
caffe.set_mode_gpu();
gpu_id = 0;
caffe.set_device(gpu_id);
--------------

if you use CPU or another GPU number, change this:
ex) caffe.set_mode_cpu();
or gpu_id = 2;

Enjoy,

Kyungsang




















