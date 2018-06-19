clear
clc
close all

%% signals
[x1,~] = audioread('src/clean_speech.wav'); % audio
[x2,Fs] = audioread('src/babble_noise.wav'); % audio
n1 = length(x1);
n2 = length(x2);
minn = min(n1,n2);
x = x1(1:minn) + x2(1:minn);

%% model
M = 5;
theta = [0;70];
Delta = 0.5;

A = exp(1i*2*pi*Delta*(0:M-1)'*sind(theta'));
S = [x1(1:minn)';x2(1:minn)'];
X = A*S;

%% direction estimation
Rx = X*X'/size(X,2);
[U, ~, ~] = eig(Rx);
Un = U(:,1:3);
a = exp(1i*2*pi*Delta*(0:M-1)'*sind((-90:90)));

J = diag(a'*a)./diag(a'*Un*Un'*a);
[~, loc] = findpeaks(abs(J), 'SortStr',  'descend');
loc+-90

%% beamforming
Wh = pinv(A);
S_est = Wh*X;
