function [ Nuimg, Deimg ] = quadratic3D( img, Param, k )


img = (single(img));

[sx, sy, sz] = size(img);

tmp = (zeros(sx+2*k, sy+2*k, sz+2*k,'single'));
tmp(k+1:sx+k,k+1:sy+k,k+1:sz+k) = img;

Nuimg = (zeros(sx,sy,sz,'single'));
Deimg = (zeros(sx,sy,sz,'single'));

for iz = -k:k
    for iy = -k:k
        for ix = -k:k
            if (ix ~=0 || iy~=0 || iz~=0)         
                Nuimg = Nuimg + (img - tmp(k+1+ix:k+sx+ix,k+1+iy:k+sy+iy,k+1+iz:k+sz+iz))/(sqrt(ix*Param.dx*ix*Param.dx + iy*Param.dy*iy*Param.dy + iz*Param.dz*iz*Param.dz));
                Deimg = Deimg + 2/(sqrt(ix*Param.dx*ix*Param.dx + iy*Param.dy*iy*Param.dy + iz*Param.dz*iz*Param.dz));
            end
        end
    end
end

Nuimg = (Nuimg)./((2*k+1)^3-1);
Deimg = (Deimg)./((2*k+1)^3-1);



end

