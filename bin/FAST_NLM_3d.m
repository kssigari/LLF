function DenoisedImg = FAST_NLM_3d(NoisyImg,PatchSizeHalf,WindowSizeHalf,Sigma)

NoisyImg = (single(NoisyImg));
[nx,ny,nz] = size(NoisyImg);

% Initialize the denoised image
u = (zeros(nx,ny,nz,'single')); 
% Initialize the weight max
M = u; 
% Initialize the accumlated weights
Z = M;

PaddedImg = padarray(NoisyImg,[PatchSizeHalf,PatchSizeHalf,PatchSizeHalf],0);
PaddedV = padarray(NoisyImg,[WindowSizeHalf,WindowSizeHalf,WindowSizeHalf],0);
% Main loop
for dz = -WindowSizeHalf:WindowSizeHalf
    for dx = -WindowSizeHalf:WindowSizeHalf
        for dy = -WindowSizeHalf:WindowSizeHalf
            if dx ~= 0 || dy ~= 0 || dz ~= 0
                % Compute the Integral Image
                Sd = integralImgSqDiff(PaddedImg,dx,dy,dz);
                % Obtaine the Square difference for every pair of pixels
                SqDist = -Sd(1:end-2*PatchSizeHalf,1:end-2*PatchSizeHalf,1:end-2*PatchSizeHalf) + Sd(2*PatchSizeHalf+1:end,1:end-2*PatchSizeHalf,1:end-2*PatchSizeHalf) ...
                    + Sd(1:end-2*PatchSizeHalf,2*PatchSizeHalf+1:end,1:end-2*PatchSizeHalf) + Sd(1:end-2*PatchSizeHalf,1:end-2*PatchSizeHalf,2*PatchSizeHalf+1:end) ...
                    + Sd(2*PatchSizeHalf+1:end,2*PatchSizeHalf+1:end,2*PatchSizeHalf+1:end) ...
                    - Sd(1:end-2*PatchSizeHalf,2*PatchSizeHalf+1:end,2*PatchSizeHalf+1:end) - Sd(2*PatchSizeHalf+1:end,1:end-2*PatchSizeHalf,2*PatchSizeHalf+1:end)...
                    - Sd(2*PatchSizeHalf+1:end,2*PatchSizeHalf+1:end,1:end-2*PatchSizeHalf);
                % Compute the weights for every pixels
                SqDist = max(SqDist,0);
                w = exp(-SqDist/(2*Sigma^2));
                
                % Obtaine the corresponding noisy pixels
                v = PaddedV((WindowSizeHalf+1+dx):(WindowSizeHalf+dx+nx),(WindowSizeHalf+1+dy):(WindowSizeHalf+dy+ny),(WindowSizeHalf+1+dz):(WindowSizeHalf+dz+nz));
                
                % Compute and accumalate denoised pixels
                u = u+w.*v;
                M = max(M,w);
                Z = Z+w;
            end
        end
    end
end
% Speical controls to accumlate the contribution of the noisy pixels to be denoised        
u = (u)./(Z);
u(isnan(u)) = NoisyImg( isnan(u));
u(isinf(u)) = NoisyImg(isinf(u));
% Output denoised image
DenoisedImg = u;


function Sd = integralImgSqDiff(v,dx,dy,dz)
% FUNCTION intergralImgDiff: Compute Integral Image of Squared Difference
% Decide shift type, tx = vx+dx; ty = vy+dy
t = img3DShift(v,dx,dy,dz);
% Create sqaured difference image
diff = abs(v-t).^2;
% Construct integral image along x
Sd = cumsum(diff,1);
% Construct integral image along y
Sd = cumsum(Sd,2);
% Construct integral image along z
Sd = cumsum(Sd,3);

function t = img3DShift(v,dx,dy,dz)
% FUNCTION img2DShift: Shift Image with respect to x and y coordinates
t = (zeros(size(v),'single'));

[nx, ny, nz] = size(v);

x = max(1,1+dx):min(nx,nx+dx);
y = max(1,1+dy):min(ny,ny+dy);
z = max(1,1+dz):min(nz,nz+dz);

t(x-dx,y-dy,z-dz) = v(x,y,z);
% -------------------------------------------------------------------------
