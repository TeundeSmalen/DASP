function speechFlag = vad(Yframe, Pnn_old)
frame_length = length(Yframe);      % frame length
thres = log(sum((abs(Pnn_old).^2)/frame_length));         % threshold= speech log energy

E = sum(abs(Yframe).^2) / frame_length;  % Energy
Elog = log(E);                      % Log Energy

speechFlag = Elog > thres;          % one if speech is present
end

