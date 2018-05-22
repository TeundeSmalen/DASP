clear
clc
close all

%% read first file
[x1,Fs] = audioread('src/clean_speech.wav');
timeframe = 0.01;
SNR = 20;

%% padding
segment_size = timeframe*Fs;
x = [x1; zeros(segment_size - mod(length(x1), segment_size),1)];

%% model noise
std = sqrt(rms(x1)^2/(10^(SNR/20)));
n = std.*randn(length(x),1);
y = x + n;

%% Wiener
y = reshape(y, segment_size, []);
x = reshape(x, segment_size, []);
n = reshape(n, segment_size, []);

PSY = sum(x.*y)./segment_size;
PYY = sum(y.*y)./segment_size;
PNN = sum(n.*n)./segment_size;
H1 = PSY./PYY;
H2 = 1-PNN./PYY;
Y = fft(y);
D = H2.*Y;
d = ifft(D);

%% test
x = 1 : 160*10;
o = sin(x/160);
h = hamming(160);
h_full = zeros(1,length(o));
for i = 1 : 5 : length(o)-160
    h_full(i: i+160-1) = h_full(i: i+160-1) + h';
end
plot(h_full)