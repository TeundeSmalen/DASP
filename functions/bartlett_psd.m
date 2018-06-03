function PByy = bartlett_psd(Pyy, M)
    PByy = Pyy;
    for i = M : size(Pyy,1)-M
        PByy(i,:) = Pyy(i,:);
        for j = i-M+1 : i-1
            PByy(i,:) = PByy(i,:) + Pyy(j,:);
        end
        PByy(i,:) = PByy(i,:)/M;
    end
end

