function Q_out = MinStatQ(Pyy, Q_prev, alpha)
    Q_out =  alpha*Q_prev + (1-alpha)*Pyy;
end