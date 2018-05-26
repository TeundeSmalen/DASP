function x = overlap_add(X, Fs, n, segment_time, overlap_time)
% calc lengths
n_segment = segment_time*Fs;
n_frame = fix((overlap_time+segment_time)*Fs);
segments = floor(n/n_segment);

% reconstruct matrix
x = zeros(n, 1);
for i = 0 : segments-2 
    o = i * n_segment;
    x(o + 1 : o + n_frame) = x(o + 1 : o + n_frame) + X(i+1, :)';
end

end

