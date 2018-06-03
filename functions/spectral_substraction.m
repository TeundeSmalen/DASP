function Sk_hat = spectral_substraction(Yk, Nk, L, thres)
    % allow less arguments
    if nargin == 2
        L = 1;
        thres = 0;
    elseif nargin == 3
        thres = 0;
    end

    Yk_phase = angle(Yk);   % store phase and cut

    PNN = abs(Nk).^2/size(Nk,2);       % get spectral densities
    Pyy = abs(Yk).^2/size(Yk,2);       % get spectral densities
    PYY = bartlett_psd(Pyy, L);

    Sk_hat = 1-PNN./PYY;            % spactral substraction
    Sk_hat(Sk_hat<thres) = thres;   % negative PDF estimates
    Sk_hat = sqrt(Sk_hat).*abs(Yk);
    Sk_hat = Sk_hat.*exp(i*Yk_phase);
end

function PYY = bartlett_estimate(Yk, L)
   
end

