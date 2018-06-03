function psd = bartlett_psd(x, M)
    xx = reshape(x, [], M);         % split in M parts
    XX = fft(xx, length(x));        % get fft of normal length
    PXX = abs(XX).^2/length(xx);    % calculate individual PSD
    psd = sum(PXX, 2)/M;            % average PSD
end

