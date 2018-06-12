clear
clc
close all

%% read first file
[x,Fs] = audioread('src/clean_speech.wav'); % audio
x_length = length(x);                       % audio length
frame_length = fix(Fs * 0.018);             % frame length (seconds)
overlap_length = fix(frame_length * 0.6);   % overlap length (percentage)
SNR = 20;                                   % SNR for noise



%% Model and segment
y = awgn(x, SNR, 'measured');   % noisy signal
Y = segment(y, frame_length, overlap_length, 'shann');

%% Memory
Pnn = [];
Pyy = [];
SNR = [];
X = [];

%% Variables
alpha_noisePSD = 0.9;   % alpha for noise estimate
alpha_SNR = 0.98;       % alpha for SNR estimation
L = 1;                  % dimension of bartlett estimate
K = 1;                  % asumed stationary for K frames (SNR_ml) 
silent_frames = 10;     % number of init silence frames

%% Noise Enhancement
for i = 1 : size(Y,2)   % for each frame
    Yi = fft(Y(:,i));                       % current frame
    
    Pyyi = (abs(Yi).^2) / frame_length;     % spectrum noisy signal
    Pyy = [Pyy Pyyi];
    
    if L > 1    % bartlett estimate
        Pyyi = sum(Pyy(:,end-L+1:end))./L;
    end
    
    % Noise PSD Estimation
    if i < silent_frames
        Pnni = (abs(Yi).^2) / frame_length;
    else
        speechFlag = vad(Yi, Pnn(:, end));
        Pnni = noisePSD(Yi, Pnn(:, end), speechFlag, alpha_noisePSD);
    end
    Pnn = [Pnn Pnni];
    
    % Target PSD Estimation
    SNRi = snr_dd(Pyyi, Pnni, alpha_SNR);   % directed decision
    %SNRi = snr_ml(Pyyi, Pnni, K);
    
    % Target Estimation
    S_hat = spectral_substraction(Pyyi, Pnni, Yi);
    %S_hat = wiener(Pyyi, Pnni);
    
    X = [X ifft(S_hat)];
end

%% Overlap add and sound
x = overlap_add(X, overlap_length);
soundsc(x, Fs);