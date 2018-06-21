clear
clc
close all

%% read first file
[x,Fs] = audioread('src/clean_speech.wav'); % audio
x_length = length(x);                       % audio length
frame_length = fix(Fs * 0.018);             % frame length (seconds)
overlap_length = fix(frame_length * 0.6);   % overlap length (percentage)
SNR = -5;                                   % SNR for noise
filter = 'shann';



%% Model and segment
y = awgn(x, SNR, 'measured');   % noisy signal
Y = segment(y, frame_length, overlap_length, filter);

%% Memory
xsize = length(Y(:,1));
ysize = length(Y(1,:));
Pnn = zeros(xsize,ysize);
Pyy = zeros(xsize,ysize);
S_hat =  zeros(xsize,1);
SNRi =  zeros(xsize,1);
Speech =  zeros(2,ysize);
SNR = zeros(xsize,ysize);
X = zeros(xsize,ysize);
Speech1 = zeros(xsize,ysize);
Speech2 = zeros(xsize,ysize);

%% Variables
alpha_noisePSD = 0.98;  % alpha for noise estimate
alpha_SNR = 0.99;       % alpha for SNR estimation
L = 1;                  % dimension of bartlett estimate
K = 1;                  % asumed stationary for K frames (SNR_ml) 
silent_frames = 10;     % number of init silence frames
tic
%% Noise Enhancement
for i = 1 : size(Y,2)   % for each frame
    Yi = fft(Y(:,i));                       % current frame
    
    %Pyyi = (abs(Yi).^2) / frame_length;     % spectrum noisy signal
    Pyyi = abs(Yi).^2;
    Pyy(:,i) = Pyyi;
    
    if L > 1 && i > L   % bartlett estimate
        for j = 1:frame_length
        Pyyi(j) = sum(Pyy(j,i-L+1:i))./L;
        end
    end
    
    % Noise PSD Estimation
    if i < silent_frames
        %Pnni = (abs(Yi).^2) / frame_length;
        Pnni = abs(Yi).^2;
        speechFlag = 0;
        speechFlag2 = 0;
    else
        [speechFlag, speechFlag2] = vad(Yi, Pnn(:, i-1), SNRi);
        Pnni = noisePSD(Yi, Pnn(:, i-1), speechFlag2, alpha_noisePSD);
    end
    Pnn(:,i) = Pnni;
    Speech(1,i) = speechFlag;
    Speech(2,i) = speechFlag2;
    
    % Target PSD Estimation
    SNRi = snr_dd(Pyyi, Pnni, S_hat ,alpha_SNR);   % directed decision
    %SNRi = snr_ml(Pyyi, Pnni, K);
    SNR(:,i) = SNRi;
    
    % Target Estimation
    %S_hat = spectral_substraction(Pyyi, Pnni, Yi, sqrt(0.1));
    S_hat = wiener(Yi, SNRi);
    
    X(:,i) = ifft(S_hat);

end
toc
%% Overlap add and sound

x = overlap_addv3(X, overlap_length, filter);
x = real(x);
for i = 1:frame_length
    Speech1(i,:) = Speech(1,:);
    Speech2(i,:) = Speech(2,:);
end

Speech_1 = overlap_addv3(Speech1, overlap_length, filter);
Speech_2 = overlap_addv3(Speech2, overlap_length, filter);
%error = x(1:577655)-y;
%plot(error)
figure
hold on
plot(y(1:250000))
plot(x(1:250000))
plot(Speech_2(1:250000))
%soundsc(x(1:250000), Fs);