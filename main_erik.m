clear
clc
close all

%% read first file
[x,Fs] = audioread('src/clean_speech.wav');
t = (0 : length(x)-1)/Fs;
n = length(x);

%% variables
segment_time = 0.020;    % 20ms
overlap_time = 0.015;

%% segmenting
X = segment(x, Fs, segment_time, overlap_time);

%% overlap add
d = overlap_add(X, Fs, n, segment_time, overlap_time);

plot(x) 
hold on
plot(d)