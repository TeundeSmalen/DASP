function Sk_hat = wiener(Yk, Nk)
PYY = abs(Yk).^2;       % get spectral densities
PNN = abs(Nk).^2;       % get spectral densities

H = 1-PNN./PYY;
Sk_hat = H.*Yk;
end

