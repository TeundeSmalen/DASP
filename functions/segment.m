function X = segment(x, Fs, segment_time, overlap_time)
% calculate sizes
n = length(x);
n_segment = segment_time*Fs;
n_frame = fix((overlap_time+segment_time)*Fs);
segments = floor(n/n_segment);

% hamming filter
h = hamming(n_frame);

% constructing segmented array
for i = 0 : segments-2 
    o = i * n_segment;
    X(i+1, :) = x(o + 1 : o + n_frame).*h;
end

end

