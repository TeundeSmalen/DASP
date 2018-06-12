clear
clc
close all

%% read the file and variables
[x,Fs] = audioread('src/clean_speech.wav');
sequence_size = length(x);
frame_size = fix(Fs * 0.018);            % Fs * miliseconds(integer)
overlap_size = fix(frame_size * 0.60);    % overlap sample size (integer)
SNR = 20;

y = awgn(x, SNR, 'measured');
n = y-x;
sigma_n = std(n);


%% segmenting
Y = segment(y, frame_size, overlap_size, 'shann');
N = segment(n, frame_size, overlap_size, 'shann');

Yk = fft(Y);
N = fft(N);
Pnn = log(sum((abs(N).^2)/frame_size));

%% Algorithms
std = log(sum(abs(Yk).^2)/frame_size);
std = kron(std, ones(1,fix(length(y)/length(std))));
std = [std, zeros(1, length(y)-length(std)) ];

thres = mean(Pnn(1:end-1)) + 0.5;
std(std > thres) = max(y);
std(std < thres) = 0;

%% overlap add
yhat = overlap_add(Y, overlap_size);
yhat = yhat(1:length(y));

%% maybe plotting
t = (0 : length(x) - 1)/Fs;
plot(t, y);
hold on
axis tight
plot(t, std, 'Linewidth', 1.5)
title('Voice Activity Detection');
xlabel('Time [s]');
ylabel('Amplitude [W] and [dBW]');

% subplot(211)
% plot(x)
% axis tight
% subplot(212)
% plot(y)
% axis tight



