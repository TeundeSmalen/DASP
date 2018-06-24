clear
clc
close all

%% read first file
[x,Fs] = audioread('src/clean_speech.wav'); % audio
x_length = length(x);                       % audio length
frame_length = fix(Fs * 0.018);             % frame length (seconds)
overlap_length = fix(frame_length * 0.6);   % overlap length (percentage)
SNR = 20;                                   % SNR for noise
filter = 'shann';                           % filter

%% Model and segment
y = awgn(x, SNR, 'measured');   % noisy signal
Y = segment(y, frame_length, overlap_length, filter);

%% Memory
xsize = length(Y(:,1));
ysize = length(Y(1,:));
Pnn = zeros(xsize,ysize);
Pyy = zeros(xsize,ysize);
S_hat =  zeros(xsize,1);
Q =  zeros(xsize,ysize);
SNRi =  zeros(xsize,1);
Speech =  zeros(2,ysize);
SNR = zeros(xsize,ysize);

SNRdd = SNR;
SNRml = SNR;

X = zeros(xsize,ysize);
Speech1 = zeros(xsize,ysize);
Speech2 = zeros(xsize,ysize);

%% Variables
alpha_noisePSD = 0.98;  % alpha for noise estimate
alpha_SNR = 0.98;       % alpha for SNR estimation
L = 1;                  % dimension of bartlett estimate
QL = 50;                % Length of Min Stat vector
K = 1;                  % asumed stationary for K frames (SNR_ml) 
silent_frames = 50;     % number of init silence frames
tic
%% Noise Enhancement
w = waitbar(0);
for i = 1 : size(Y,2)   % for each frame
    waitbar(i/size(Y,2), w);
    Yi = fft(Y(:,i));% current frame
    
    Pyyi = abs(Yi).^2;
    Pyy(:,i) = Pyyi;
    
    if L > 1 && i > L   % bartlett estimate
        for j = 1:frame_length
        Pyyi(j) = sum(Pyy(j,i-L+1:i))./L;
        end
    end
    
    % Noise PSD Estimation
    if i < silent_frames
        Pnni = abs(Yi).^2;
        if i > 1
           Q(:,i) = alpha_noisePSD*Q(:,i-1)+(1-alpha_noisePSD)*Pnni;
        else
           Q(:,i) = (1-alpha_noisePSD)*Pnni;  
        end
        speechFlag = 0;
        speechFlag2 = 0;
    else
        [speechFlag, speechFlag2] = vad(Yi, Pnn(:, i-1), SNRi);
        [Pnni, Q] = MinStat(Pyyi, Q, i, QL, alpha_noisePSD);
    end
    Pnn(:,i) = Pnni;
    Speech(1,i) = speechFlag;
    Speech(2,i) = speechFlag2;
    
    % Target PSD Estimation
    SNRi = snr_dd(Pyyi, Pnni, S_hat ,alpha_SNR);   % directed decision
    SNRi1 = snr_ml(Pyyi, Pnni, K);
    SNR(:,i) = SNRi;
    
    SNRdd(:,i) = SNRi;
    SNRml(:,i) = SNRi1;
    
    % Target Estimation
    S_hat = wiener(Yi, SNRi);
    X(:,i) = ifft(S_hat);
end
close(w);
toc
%% Overlap add and sound
xh = overlap_addv3(X, overlap_length, filter);
xh = real(xh);
xh = xh(1:size(y(:,1),1));
factor = max(y)/max(xh);
xh = factor*xh;
for i = 1:frame_length
    Speech1(i,:) = Speech(1,:);
    Speech2(i,:) = Speech(2,:);
end

%% plotting
till = 250000;
p = till/length(x);
figure

subplot(121); hold on
plot(y(1:till))
plot(xh(1:till))
axis tight;

subplot(122);
Meanml = mean(SNRml);
Meanml = 20*log10(Meanml - min(Meanml));
Meanml(Meanml<1E-3) = 0;
e = p*length(Meanml);
movMeanml = movmean(Meanml,3);
plot(movMeanml(1:fix(e)));
axis tight;
% Meandd = mean(SNRdd);
% Meanml = mean(SNRml);
% Meandd = 10*log10(Meandd);
% Meandd(Meandd<1E-3) = 0;
% 
% e = p*length(Meandd);
% movMeandd = movmean(Meandd,3);
% plot(movMeandd(1:fix(e)));

