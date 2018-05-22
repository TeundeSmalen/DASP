function s = power_spectral_substraction(y, np, L)
Y = abs(Y(1:fix(end/2),:)).^2;  % Specrogram
Y = Y - std;  % Substraction 
Y(Y<0.1) = 0.1; % Removing zeros
Y = Y.^(1/2);
y = real(ifft(Y));
y = reshape(y, length(x), 1);

sound(y, Fs)
end

