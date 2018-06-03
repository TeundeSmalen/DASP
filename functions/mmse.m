function Sk_hat = mmse(sigmaN, sigmaS, y, v, gam)
    beta = 1;
    
end

function pA = probA(a)
    pA = (gam*beta^v)/(gamma(v)) * a^(gam*v-1) * exp(-beta*a^gam);
end

