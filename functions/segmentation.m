function [segments, segment_size] = segmentation(audio, Fs, time_frame)

y = audio;
segment_size = Fs*time_frame/1000;
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