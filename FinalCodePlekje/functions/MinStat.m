function [Pnn, Q] = MinStat(Pyy, Q, i, L, K, alpha)
    Pnn = zeros(288,1); %Allocate Pnn for output

    Q_new = alpha*Q(i-1) + (1-alpha)*Pyy; %Determine the Q of current Sample
    Q(:,i) = Q_new;     %Add to Q-Matrix
    lbound = i-L+1;     %Determine Lowerbound of Q values used
    if lbound < 1 %Make sure that it is not too low
        lbound = 1;
    end
    
    for k =1:size(Q,1) %Run for all k frequency bins
        pos = find(Q(k,lbound:i) == min(Q(k,lbound:i))); %Find position of minimum
        mlow = pos(1)+lbound-1-K;   %Mean Low Bound
        if mlow > 1     %If Low Bound is too small
            B = 1/mean(Q(k,mlow:i));
        else
            B = 1/mean(Q(k,1:i));
        end
        Pnn(k,1) = Q(k,pos(1)+lbound-1)*B; %Add to Pnn for kth frequency bin
    end
end