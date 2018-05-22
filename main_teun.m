clear
[y,Fs] = audioread('src/clean_speech.wav');

%Set the size (in ms) of each segment
frame = 20;

%%
segment_size = Fs*frame/1000;
N_segments = ceil(length(y)/segment_size);
segments(N_segments, segment_size) = 0;

for i = 1:N_segments
    begin = (i-1)*segment_size+1;
    endclip = i*segment_size;
    if endclip > length(y)
        y = padarray(y, endclip-length(y));
    end
    segments(i,:) = y(begin:endclip);
end
