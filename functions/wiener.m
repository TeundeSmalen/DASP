function Sk_hat = wiener(Pyy, Pnn)
H = 1-Pnn./Pyy;
Sk_hat = H.*Yk;
end

