function Sk_hat = wiener(Yi, SNR)


H = SNR./(SNR+1);
Sk_hat = H.*abs(Yi);
Sk_hat = Sk_hat.*exp(1i*angle(Yi));
end

