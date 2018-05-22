function [segments, segment_size] = segmentation(audio, frame_size)

y = audio;
segment_size = Fs*frame_size/1000;
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