function [speechFlag, speechFlag2] = vad(Yframe, Pnn_old, SNR)
frame_length = length(Yframe);      % frame length
Pnn_old = log(Pnn_old);
thres = sum(Pnn_old)/frame_length; %Stationary Threshold
%thres = log(sum((abs(Pnn_old).^2)/frame_length));         % threshold= speech log energy
SNRavg = mean(SNR);
thres2 = thres+log(SNRavg)/6; %Adaptive Threshold

E = sum(abs(Yframe).^2) / frame_length;  % Energy
Elog = log(E);                      % Log Energy

speechFlag = Elog > thres;          % one if speech is present
speechFlag2 = Elog > thres2;
end