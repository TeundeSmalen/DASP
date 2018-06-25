function [SNR , Pss] = snr_ml(Pyy,Pnn, K)
% Pnn is estimated for each frame
% K is number of frames signal power is equal in previous frames

SNR = Pyy./Pnn - 1; % SNR per frame per frequency
Pss(1:K, :) = Pyy(1:K, :) - Pnn(1:K, :);

    for i = K : size(Pyy, 2)
        Pss(i, :) = sum(Pyy(i-K+1 : i, :) - Pnn(i-K+1 : i, :))/K;
    end

end

