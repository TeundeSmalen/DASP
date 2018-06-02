function Sk_hat = spectral_substraction(Yk, Nk, L, thres)
    % allow less arguments
    if nargin == 2
        L = 0;
        thres = 0;
    elseif nargin == 3
        thres = 0;
    end

    Yk_phase = angle(Yk);   % store phase and cut

    PNN = abs(Nk).^2;       % get spectral densities
    PYY = bartlett_estimate(Yk, L); % bartlett estimate

    Sk_hat = 1-PNN./PYY;    % spactral substraction
    Sk_hat(Sk_hat<thres) = thres;   % negative PDF estimates
    Sk_hat = sqrt(Sk_hat).*abs(Yk);
    Sk_hat = Sk_hat.*exp(i*Yk_phase);
end

function PYY = bartlett_estimate(Yk, L)
    PYY = abs(Yk).^2;
    
    PYY_ = PYY;
    for i = 1 : L
        PYY_ = PYY_ + circshift(PYY, i);
    end
    PYY = PYY_/(L+1);
end

