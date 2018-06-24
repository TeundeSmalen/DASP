clear
clc
close all

%% signals
[s,Fs] = audioread('src/clean_speech.wav'); % audio

%% samples and segment variables
samples = 250000;
s = s(fix(end/2):fix(end/2) + samples);
frame_length = fix(Fs*0.018);
overlap_length = fix(frame_length * 0.6);
filter = 'shann';

%% variables
c = 340;    % speed of light
d = 0.25*c/Fs;   % maximum distance between microphones
M = 9;      % number of microphones
N = frame_length;
theta = 90;
SNR = 5;

%% segment each source
S = segment(s, frame_length, overlap_length, filter);
Sk = fft(S);

%% Model the microphones
% variables
tau = cosd(theta)*d/c*Fs;
m = (0:M-1)';

% creating the model
Yk = zeros(frame_length,size(Sk,2),M);
disp('Creating model...');
for j = 1 : size(Sk,2)  % for each frame
   for k = 1 : frame_length     % for each frequency bin
       dk = exp(-1i*2*pi*m*k*tau/N);
       Yk(k,j,:) =dk'*Sk(k,j)/M ;
   end
end

disp('Overlap add...');
Y = ifft(Yk);
for j = 1 : M
    y(:,j) = overlap_addv3(Y(:,:,j), overlap_length, filter);
end
y([1 end], :) = 0;
y = y(1:length(s),:);
y = awgn(y, SNR, 'measured');

%% Beamforming
for i = 1 : M
    Y(:,:,i) = segment(y(:,i), frame_length, overlap_length, filter); 
end
Yk = fft(Y);

disp('Beamforming...');
Skhat = zeros(size(Sk));
for j = 1 : size(Y,2)   % for each frame
   for k = 1 : frame_length   % for each frequency
       d = exp(-1i*2*pi*m*k*tau/N);
       w = d/(d'*d);
       Skhat(k,j) = w'*squeeze(Yk(k,j,:));
   end
end

Shat = ifft(Skhat);
shat = overlap_addv3(Shat, overlap_length, filter);
shat([1 end]) = 0;

plot(real(y(:,1))); hold on
plot(real(shat));
axis tight
xlabel('sample');
ylabel('magnitude');
title('Sum and Delay Beamformer');
legend('original', 'filtered');
