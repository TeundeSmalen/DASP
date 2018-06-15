clear
clc
close all

%% read first file
[x,Fs] = audioread('src/clean_speech.wav'); % audio
x_length = length(x);                       % audio length
frame_length = fix(Fs * 0.018);             % frame length (seconds)
overlap_length = fix(frame_length * 0.6);   % overlap length (percentage)
SNR = 20;                                   % SNR for noise
filter = 'shann';



%% Model and segment
y = awgn(x, SNR, 'measured');   % noisy signal
Y = segment(y, frame_length, overlap_length, filter);

%% Memory
xsize = length(Y(:,1));
ysize = length(Y(1,:));
Pnn = zeros(xsize,ysize);
Pyy = zeros(xsize,ysize);
%Pnn = [];
%Pyy = [];
SNR = [];
%X = [];
X = zeros(xsize,ysize);

%% Variables
alpha_noisePSD = 0.1;   % alpha for noise estimate
alpha_SNR = 0.98;       % alpha for SNR estimation
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
    
    if L > 1    % bartlett estimate
        Pyyi = sum(Pyy(:,end-L+1:end))./L;
    end
    
    % Noise PSD Estimation
    if i < silent_frames
        %Pnni = (abs(Yi).^2) / frame_length;
        Pnni = abs(Yi).^2;
    else
        speechFlag = vad(Yi, Pnn(:, i-1));
        Pnni = noisePSD(Yi, Pnn(:, i-1), speechFlag, alpha_noisePSD);
    end
    Pnn(:,i) = Pnni;
    
    % Target PSD Estimation
    %SNRi = snr_dd(Pyyi, Pnni, alpha_SNR);   % directed decision
    %SNRi = snr_ml(Pyyi, Pnni, K);
    
    % Target Estimation
    S_hat = spectral_substraction(Pyyi, Pnni, Yi);
    %S_hat = wiener(Pyyi, Pnni);
    
    X(:,i) = ifft(S_hat);

end
toc
%% Overlap add and sound
x = overlap_addv3(X, overlap_length, filter);
x = real(x);
x = x*max(y)/max(x);

error = x(1:577655)-y;
plot(error)
%soundsc(x, Fs);