clear
clc
close all

%% read first file
[s,Fs] = audioread('src/clean_speech.wav');
t = (0 : length(s)-1)/Fs;
sample_length = length(s);

% find optimal percentage
MSE1 = [];
MSE2 = [];
MSE3 = [];
for p = 0.4 : 0.01 : 1

frame_size = 250;
overlap_size = fix(frame_size*p);
step_size = frame_size-fix(overlap_size/2);

h1 = sqrt(hann(frame_size));
h2 = hann(frame_size);
h3 = hamming(frame_size);

num = 100;
H1 = zeros(1,num*step_size + fix(overlap_size/2));
H2 = zeros(1,num*step_size + fix(overlap_size/2));
H3 = zeros(1,num*step_size + fix(overlap_size/2));
for i = 1 : num
    idx = 1+(i-1)*step_size;
    H1(idx:idx+frame_size-1) = H1(idx:idx+frame_size-1) + h1';
    H2(idx:idx+frame_size-1) = H2(idx:idx+frame_size-1) + h2';
    H3(idx:idx+frame_size-1) = H3(idx:idx+frame_size-1) + h3';
end

one = ones(1,length(H1));
MSE1 = [MSE1 mse(one,H1)];
MSE2 = [MSE2 mse(one,H2)];
MSE3 = [MSE3 mse(one,H3)];
end
subplot(121);
plot((0.4 : 0.01 : 1)*100, MSE1); hold on;
plot((0.4 : 0.01 : 1)*100, MSE2);
plot((0.4 : 0.01 : 1)*100, MSE3);
title('Optimal Overlap');
xlabel('overlap [%]');
ylabel('mse');
legend('sqrt-Hann', 'Hann', 'Hamming');
grid;

%% plot around optimal percentage
subplot(122)
r = 0.67 : 0.01 : 0.70;
for p = r
frame_size = 250;
overlap_size = fix(frame_size*p);
step_size = frame_size-fix(overlap_size/2);

h = sqrt(hann(frame_size));
%h = hann(frame_size);
num = 3;
H = zeros(1,num*step_size + fix(overlap_size/2));
for i = 1 : num
    idx = 1+(i-1)*step_size;
    H(idx:idx+frame_size-1) = H(idx:idx+frame_size-1) + h';
end

plot(linspace(0,3,length(H)),H); hold on;
end
title('Overlapped sqrt-Hann');
xlabel('frame');
ylabel('added windows');
grid;
legend([num2str(100*(r)') [' %';' %';' %';' %']]);