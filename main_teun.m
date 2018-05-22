clear
[y,Fs] = audioread('src/clean_speech.wav');

%Set the size (in ms) of each segment
time_frame = 20;

%%
[