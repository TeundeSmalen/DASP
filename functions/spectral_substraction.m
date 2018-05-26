function Sk_hat = spectral_substraction(Yk, Nk)
% store phase and cut
Yk_phase = angle(Yk);
Yk = Yk(:, 1:end/2+1);
Nk = Nk(:, 1:end/2+1);

% get spectral densities
PNN = abs(Nk).^2;  
PYY = abs(Yk).^2;
PNN(2:end-1) = 2*PNN(2:end-1);
PYY(2:end-1) = 2*PYY(2:end-1);

% spectral substraction
PSS = PYY - PNN;
PSS = [PSS fliplr(PSS(:, 1:end-2))];
PSS(PSS<0) = 0;

% retreive signal
Sk_hat = sqrt(PSS);
Sk_hat = Sk_hat.*exp(i*Yk_phase);
end

