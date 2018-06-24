function [Pnn, Q] = MinStat(Pyy, Q, i, L, alpha)
% noise_estimate = frame_sizex1
    Pnn = zeros(288,1);

    K = 1000;
    Q_new = MinStatQ(Pyy, Q(i-1), alpha);
    Q(:,i) = Q_new;
    lbound = i-L+1;
    if lbound < 1 
        lbound = 1;
    end
    for k =1:size(Q,1)
%        Mean = mean(Q(:,lbound:i));
%        pos = find(Mean == min(Mean(:)));
%        Pnn = Q(:,pos(1)+lbound-1);
        pos = find(Q(k,lbound:i) == min(Q(k,lbound:i)));
        %if pos(1)+lbound-K-1>1
        %    B = 1/mean(Q(k,pos(1)+lbound-K-1:pos(1)+lbound-2));
       % else
        %    B = 1/mean(Q(k,pos(1)+lbound:pos(1)+lbound+K-1));
        %end
        B = 1/mean(Q(k,1:i));
        Pnn(k,1) = Q(k,pos(1)+lbound-1)*B;
    end
end