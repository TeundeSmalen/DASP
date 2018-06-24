clear
clc
close all

%% read first file
[x,Fs] = audioread('src/clean_speech.wav'); % audio
x_length = length(x);                       % audio length
frame_length = fix(Fs * 0.018);             % frame length (seconds)
overlap_length = fix(frame_length * 0.6);   % overlap length (percentage)
SNR1 = 20;                                   % SNR for noise
filter = 'shann';                           % filter

%% Model and segment
y = awgn(x, SNR1, 'measured');   % noisy signal
Y = segment(y, frame_length, overlap_length, filter);

%% Memory
xsize = length(Y(:,1));
ysize = length(Y(1,:));
Pnn = zeros(xsize,ysize);
Pyy = zeros(xsize,ysize);
S_hat1 =  zeros(xsize,1);
S_hat2 =  zeros(xsize,1);
Q =  zeros(xsize,ysize);
SNRi1 =  zeros(xsize,1);
SNR1 = zeros(xsize,ysize);
SNRi2 =  zeros(xsize,1);
SNR2 = zeros(xsize,ysize);
X1 = zeros(xsize,ysize);
X2 = zeros(xsize,ysize);

%% Variables
alpha_noisePSD = 0.98;  % alpha for noise estimate
alpha_SNR = 0.98;       % alpha for SNR estimation
L = 1;                  % dimension of bartlett estimate
QL = 50;                % Length of Min Stat vector
K = 1;                  % asumed stationary for K frames (SNR_ml) 
silent_frames = 50;     % number of init silence frames

%% Noise Enhancement
tic
w = waitbar(0);
for i = 1 : size(Y,2)   % for each frame
    waitbar(i/size(Y,2), w);
    Yi = fft(Y(:,i));% current frame
    
    % received PSD estimation
    Pyyi = abs(Yi).^2;
    Pyy(:,i) = Pyyi;
    
    % Noise PSD Estimation
    if i < silent_frames
        Pnni = abs(Yi).^2;
        if i > 1
           Q(:,i) = alpha_noisePSD*Q(:,i-1)+(1-alpha_noisePSD)*Pnni;
        else
           Q(:,i) = (1-alpha_noisePSD)*Pnni;  
        end
    else
        [Pnni, Q] = MinStat(Pyyi, Q, i, QL, alpha_noisePSD);
    end
    Pnn(:,i) = Pnni;
    
    % Target PSD Estimation
    SNRi1 = snr_dd(Pyyi, Pnni, S_hat1 ,alpha_SNR);   % directed decision
    SNR1(:,i) = SNRi1;
    SNRi2 = snr_dd(Pyyi, Pnni, S_hat2 ,alpha_SNR);   % directed decision
    SNR2(:,i) = SNRi2;
    
    % Target Estimation
    S_hat1 = spectral_substraction(Pyyi, Pnni, Yi, sqrt(0.1));
    S_hat2 = wiener(Yi, SNRi2);
    
    X1(:,i) = ifft(S_hat1);
    X2(:,i) = ifft(S_hat2);
end
close(w)
toc
%% Overlap add and sound
xh1 = overlap_addv3(X1, overlap_length, filter);
xh1 = real(xh1);
xh1 = xh1(1:size(y(:,1),1));
factor = max(y)/max(xh1);
xh1 = factor*xh1;

xh2 = overlap_addv3(X2, overlap_length, filter);
xh2 = real(xh2);
xh2 = xh2(1:size(y(:,1),1));
factor = max(y)/max(xh2);
xh2 = factor*xh2;

till = 250000;
figure
subplot(121); hold on
plot(y(1:till))
plot(xh1(1:till))
axis tight;

subplot(122); hold on
e1 = abs(x-xh1).^2;
plot(e1(1:till));
axis tight;

figure
subplot(121); hold on
plot(y(1:till))
plot(xh2(1:till))
axis tight;

subplot(122); hold on
e2 = abs(x-xh2).^2;
plot(e2(1:till));
axis tight;
