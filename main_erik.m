clear
clc
close all

%% read first file
[s,Fs] = audioread('src/clean_speech.wav');
t = (0 : length(s)-1)/Fs;
sample_length = length(s);

%% variables
segment_time = 0.025;   % 25ms
overlap_time = 0.000;   % 0ms
SNR = 0;                % snr(s,n)

%% creating noise and segmenting
y = awgn(s, SNR, 'measured');   % measured noise [snr(s,n) = SNR]
n = y - s;                      % model is y = s + n
Y = segment(y, Fs, segment_time, overlap_time);
S = segment(s, Fs, segment_time, overlap_time);
N = segment(n, Fs, segment_time, overlap_time);

%% Algorithms
Yk = fft(Y, [], 2);        % row-wise fft
Nk = fft(N, [], 2);        % row-wise fft
Sk = fft(S, [], 2);        % row-wise fft

%% speech detection
Sk_hat = spectral_substraction(Yk, Nk, 1);
%Sk_hat = wiener(Yk, Nk);

S_hat = ifft(Sk_hat, [], 2);    % row wise ifft

%% overlap add
s_hat = overlap_add(S_hat, Fs, sample_length, segment_time, overlap_time);
sound(real(s_hat), Fs);
