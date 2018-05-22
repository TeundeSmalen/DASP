clear
clc
close all

%% read first file
[y,Fs] = audioread('src/clean_speech.wav');
soundsc(y,Fs);