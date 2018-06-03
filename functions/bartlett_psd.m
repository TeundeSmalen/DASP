function PSD_bartlett = bartlett_psd(PSD, M)
h = ones(M,1);
PSD_bartlett = filter(h, 1, PSD);
end

