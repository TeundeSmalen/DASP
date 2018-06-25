function Sk_hat = spectral_substraction(Pyy, Pnn, Yk, thres)
    % allow less arguments
    if nargin < 4
       thres = 0; 
    end
    
    Yk_phase = angle(Yk);
   
    Sk_hat = 1-Pnn./Pyy;            % spactral substraction
    Sk_hat(Sk_hat<thres) = thres;   % negative PDF estimates
    Sk_hat = sqrt(Sk_hat).*abs(Yk);
    Sk_hat = Sk_hat.*exp(1i*Yk_phase);
end
