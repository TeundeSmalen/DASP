function S = wiener(Y, PYY, PNN)
H = 1-PNN./PYY;
S = H.*Y;
end

