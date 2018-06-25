function Y = segment(y, frame_size, overlap_size, filter)
    if nargin < 4
        disp(1)
       filter = 'hann'; 
    end
    
    % calculate the step sizes and number of frames
    step_size = fix(frame_size - overlap_size/2);
    num_frames = fix(length(y) / step_size) + 1;
    
    pad = num_frames*frame_size - length(y);
    y = padarray(y, pad, 'post');

    % Choose filter
    switch(filter)
        case 'rect'
            h = rectwin(frame_size);
        case 'hann'
            h = hann(frame_size);
        case 'hamm'
            h = hamming(frame_size);
        case 'shann'
            h = sqrt(hann(frame_size));
        case 'black'
            h = blackmanharris(frame_size);
        case 'nutt'
            h = nuttallwin(frame_size);
    end
    
    % generate the frames
    for i = 0 : num_frames
        index = i*step_size + 1;
        Y(:, i + 1) = y(index: index + frame_size - 1);
    end   
    
    % apply window
    Y = repmat(h, 1, size(Y,2)) .* Y;
end