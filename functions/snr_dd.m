function snr = snr_dd(Yk, Pnn, alpha)
if nargin < 3
   alpha = 0.98; 
end

Pyy = abs(Yk).^2;

Pss1 = Pyy(1, :) - Pnn(1, :) - 1;
Pss1(Pss1 < 0) = 0;
Pss(1, :) = Pss1;

for i = 2 : size(Yk,2)
    Pssi1 = alpha .* Pss(i-1, :)./Pnn(i, :);
    
    Pssi2 = (1-alpha) .* (Pyy(i, :) - Pnn(i, :) - 1);
    Pssi2(Pssi2 < 0) = 0;
        
    Pss(i, :) = Pssi1 + Pssi2;
end

end

