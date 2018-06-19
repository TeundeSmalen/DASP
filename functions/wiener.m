function Sk_hat = wiener(Pyy, Pnn, Yi, SNR)
%H = 1-Pnn./Pyy;
%Pss = Pyy - Pnn;
%H = Pss./Pnn./(Pss./Pnn+1);
H = SNR./(SNR+1);
Sk_hat = H.*abs(Yi);
Sk_hat = H.*angle(Yi);
end

