function [filtered, a, b] = LLF3d(input, prior, win_size)
% Local linear fitting function

input = (single(input));
prior = (single(prior));

half = floor(win_size / 2);
pad_x = (padarray(input, [half, half, half], 'both'));
pad_p = (padarray(single(prior), [half, half, half], 'both'));

b = (zeros(size(input),'single'));
sigmai = b;
cross = b;

mu_x = b;
mu_p = b;


%constructing denominator image;
initial_denom = (ones(size(pad_p),'single'));
denom = b;

paddedpsquare = pad_p.^2;
paddedxdp = pad_p.*pad_x;

for i = -half : half
    for j = -half : half
        for k = -half : half            
            mu_x = mu_x + pad_x(half+1+i:end-half+i,half+1+j:end-half+j,half+1+k:end-half+k);
            mu_p = mu_p + pad_p(half+1+i:end-half+i,half+1+j:end-half+j,half+1+k:end-half+k);
            denom = denom + initial_denom(half+1+i:end-half+i,half+1+j:end-half+j,half+1+k:end-half+k);
        end
    end
end

mu_x = mu_x ./ denom;
mu_p = mu_p ./ denom;

% calculating sum over each window by shifting and adding
for i = -half : half
    for j = -half : half
        for k = -half : half
            sigmai = sigmai + paddedpsquare(half+1+i:end-half+i,half+1+j:end-half+j,half+1+k:end-half+k) - b.*pad_p(half+1+i:end-half+i,half+1+j:end-half+j,half+1+k:end-half+k) ;
            cross = cross + paddedxdp(half+1+i:end-half+i,half+1+j:end-half+j,half+1+k:end-half+k);
        end
    end
end
EPS = 0.0;
% % calculating the linear coefficients a and b
a = (cross ) ./ (sigmai +EPS);
a(isinf(a)) = 1;
a(isnan(a)) = 1;
b = mu_x - a .* mu_p;

% the filtered image
filtered =  a.* prior + b;
    

end

