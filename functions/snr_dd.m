function snr = snr_dd(Pyy, Pnn, S_prev, alpha)
if nargin < 3
   alpha = 0.98; 
end

tresh = ones(length(Pyy),size(Pyy,2))*0;
Pss = abs(S_prev).^2;

    Pssi1 = alpha .* Pss./Pnn;
    
    Pssi2 = (1-alpha) .* max((Pyy - Pnn),tresh);
        
    Pss(:,1) = Pssi1 + Pssi2;
    snr = Pss./Pnn;
end

