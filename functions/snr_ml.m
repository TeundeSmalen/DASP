function [SNR , Pss] = snr_ml(Yk,Pnn, K, L)
% Pnn is estimated for each frame
% K is number of frames signal power is equal in previous frames

Pyy = abs(Yk).^2/size(Yk, 2);
PYY = bartlett_psd(Pyy, L);

SNR = PYY./Pnn - 1; % SNR per frame per frequency

Pss(1:K, :) = PYY(1:K, :) - Pnn(1:K, :);
for i = K : size(PYY, 2)
    Pss(i, :) = sum(Pyy(i-K+1 : i, :) - Pnn(i-K+1 : i, :))/K;
end

end

