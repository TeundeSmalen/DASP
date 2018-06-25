clear
%clc
%close all

%% read first file
[x,Fs] = audioread('src/clean_speech.wav'); % audio
x_length = length(x);                       % audio length
frame_length = fix(Fs * 0.018);             % frame length (seconds)
overlap_length = fix(frame_length * 0.6);   % overlap length (percentage)
SNR = 20;                                   % SNR for noise
filter = 'shann';                           % filter

%% Model and segment
y = awgn(x, SNR, 'measured');   % noisy signal
Y = segment(y, frame_length, overlap_length, filter); %Segmentate

%% Memory
xsize = length(Y(:,1));
ysize = length(Y(1,:));

Pnn = zeros(xsize,ysize); %Noise Estimate Power Matrix
Pyy = zeros(xsize,ysize); %Noise signal Power Matrix
S_hat = zeros(xsize,1); %Output
Q = zeros(xsize,ysize); %Q-Matrix for Min Stat
SNRi =  zeros(xsize,1); %SNR of current sample
Speech =  zeros(2,ysize); %SpeechFlags (VAD) stationary and adaptive
SNR = zeros(xsize,ysize); %SNR Matrix
X = zeros(xsize,ysize); %Output X

%% Variables
alpha_noisePSD = 0.98;  % alpha for noise estimate
alpha_SNR = 0.98;       % alpha for SNR estimation
L = 1;                  % dimension of bartlett estimate
QL = 50;                % Amount of samples used for Min of Min Stat vector
QK = 50;              % Amount of samples used for Mean of Min Stat vector
K = 1;                  % asumed stationary for K frames (SNR_ml) 
silent_frames = 50;     % number of init silence frames
thresSpec = sqrt(0.1);  % Threshold for Spectral Subtraction
VarNoise = 1;           % 0 is VAD method, 1 is MS method
VarSNR = 0;             % 0 is SNRdd, 1 is SNRml
VarTarget = 1;          % 0 is SSub, 1 is Wiener

tic
%% Noise Enhancement
w = waitbar(0);
for i = 1 : size(Y,2)   % for each frame
    waitbar(i/size(Y,2), w);
    Yi = fft(Y(:,i));   %current frame
    
    Pyyi = abs(Yi).^2;  %Power of noisy signal frame
    Pyy(:,i) = Pyyi;    %Add to noisy signal power matrix
    
    if L > 1 && i > L   % bartlett estimate
        for j = 1:frame_length
        Pyyi(j) = sum(Pyy(j,i-L+1:i))./L;
        end
    end
    
    % Noise PSD Estimation
    if i < silent_frames                %Within the Silent Frames set right flags
        Pnni = abs(Yi).^2;
            if i > 1 && VarNoise == 1   %Fix for first sample MS Method
               Q(:,i) = alpha_noisePSD*Q(:,i-1)+(1-alpha_noisePSD)*Pnni;
            elseif VarNoise == 1        %If MS Method
               Q(:,i) = (1-alpha_noisePSD)*Pnni;
            else                        %If VAD Method
                speechFlag = 0;
                speechFlag2 = 0;                
            end
    else
        if VarNoise == 0                %If VAD Method
            [speechFlag, speechFlag2] = vad(Yi, Pnn(:, i-1), SNRi);
            Pnni = noisePSD(Yi, Pnn(:, i-1), speechFlag2, alpha_noisePSD);
            Speech(1,i) = speechFlag;   %Add VAD stationary to matrix
            Speech(2,i) = speechFlag2;  %Add VAD addaptive to matrix
        else                            %If MS Method
            [Pnni, Q] = MinStat(Pyyi, Q, i, QL, QK, alpha_noisePSD);
        end
    end
    Pnn(:,i) = Pnni;
    
    % Target PSD Estimation
    if VarSNR == 0
        SNRi = snr_dd(Pyyi, Pnni, S_hat ,alpha_SNR);    %directed decision
    else
        SNRi = snr_ml(Pyyi, Pnni, K);                   %Maximum Likelihood
    end
    SNR(:,i) = SNRi; %Add to SNR Matrix
    
    % Target Estimation
    if VarTarget == 0   %Spectral Subtraction
        S_hat = spectral_substraction(Pyyi, Pnni, Yi, thresSpec);
    else                %Wiener filter
        S_hat = wiener(Yi, SNRi);
    end
    
    %Add to X Matrix
    X(:,i) = ifft(S_hat);
end
toc
close(w);
%% Overlap add and sound
xh = overlap_add(X, overlap_length, filter); %Overlap Add back to normal signal
xh = real(xh);              %Take the real part
xh = xh(1:size(y(:,1),1));  %Remove the extra padding that was added
factor = max(y)/max(xh);    %Matching factor
xh = factor*xh;             %Make xh same height as y

%% plotting
till = 250000; %Plot length
figure

subplot(121); hold on
plot(y(1:till))
plot(xh(1:till))

subplot(122); hold on
e = abs(x-xh).^2;
Pmean = movmean(mean(Pnn).^2, frame_length);
e = e * (max(Pmean)/max(e));
semilogy(e(1:till));
semilogy(linspace(1,till, length(Pnn)),Pmean)

