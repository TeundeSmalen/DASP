clear
clc
close all

%% signals
[x1,~] = audioread('src/clean_speech.wav'); % audio
[x2,Fs] = audioread('src/babble_noise.wav'); % audio

samples = 250000;
x1 = x1(fix(end/2):fix(end/2) + samples);
x2 = x2(fix(end/2):fix(end/2) + samples);

%% model
SNR = 20;
M = 5;
theta_babble = (30:1:70)';    % babble range
theta = [0;theta_babble];       % complete angles       
Delta = 0.5;

% create A and source
A = exp(1i*2*pi*Delta*(0:M-1)'*sind(theta'));
x_babble = kron(ones(1,length(theta_babble)), x2)/length(theta_babble);
S = [x1';x_babble'];

% create model
X = awgn(A*S, SNR, 'measured');

%% direction estimation
Rx = X*X'/size(X,2);
[U, ~, ~] = eig(Rx);
Un = U(:,1);
a = exp(1i*2*pi*Delta*(0:M-1)'*sind((-90:90)));

J = diag(a'*a)./diag(a'*Un*Un'*a);
[~, loc] = findpeaks(abs(J), 'SortStr',  'descend');

angles = loc-90;
if 0
    figure;
    semilogy(-90:90, abs(J))
    xlabel('angle [deg]');
    ylabel('magnitude [dB]');
    axis tight;
    grid;
    title('Direction Estimation');
end

%% MVDR
t = loc(1)-91;
a = exp(1i*2*pi*Delta*(0:M-1)'*sind(t));
w = Rx\a/(a'/Rx*a);
shat = real(w'*X);

%% ZF
wh = pinv(a);
s_est = real(wh*X);

%% spatial response
ax = exp(1i*2*pi*Delta*(0:M-1)'*sind((-90:90)));
yzf = abs((wh*ax));
ymvdr = abs((w'*ax));

%% plotting
clear x_babble S S_est
err_zf = abs(x1'-s_est);
err_mvdr = abs(x1'-shat);
if 1
    figure;
    subplot(221);
    plot(x1);
    xlabel('samples');
    ylabel('magnitude');
    title('Original Source');
    axis tight;
    grid;

    subplot(222)
    semilogy(-90:90, abs(J))
    xlabel('angle [deg]');
    ylabel('magnitude [dB]');
    title('Direction Estimation');
    axis tight;
    grid;
    

    subplot(223)
    plot(abs(err_zf)); hold on;
    plot(abs(err_mvdr));
    xlabel('samples');
    ylabel('error |s-s_est|');
    title('Estimation Error');
    legend('ZF', 'MVDR');
    axis tight;
    grid;
    
    subplot(224)
    plot((-90:90), yzf); hold on;
    plot((-90:90), ymvdr);
    xlabel('angle [deg]');
    ylabel('response');
    title('Spatial Response');
    legend('ZF', 'MVDR');
    axis tight;
    grid;
end
