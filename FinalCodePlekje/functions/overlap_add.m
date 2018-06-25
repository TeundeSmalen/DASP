function y = overlap_add(Y, overlap_size, filter)
    % calculate the step sizes and number of frames
    frame_size = size(Y,1);
    step_size = fix(frame_size - overlap_size/2);
    
    % Choose filter
    switch(filter)
        case 'rect'
            h = rectwin(frame_size);
        case 'hann'
            h = hann(frame_size);
            h(1) = 10^-9;
            h(frame_size) = 10^-9;
        case 'hamm'
            h = hamming(frame_size);
        case 'shann'
            h = sqrt(hann(frame_size));
            h(1) = 10^-9;
            h(frame_size) = 10^-9;
        case 'black'
            h = blackmanharris(frame_size);
        case 'nutt'
            h = nuttallwin(frame_size);
    end
    h = repmat(h, 1, size(Y,2));
    
    
    % retrieve signal
    y = zeros(step_size * size(Y,2)-(frame_size-overlap_size), 1);
    h_out = zeros(step_size * size(Y,2)-(frame_size-overlap_size), 1);
    for i = 0 : size(Y,2) - 2
        index1 = i*step_size + 1;
        index2 = index1 + frame_size - 1;
        y(index1 : index2) = y(index1 : index2) + Y(:, i + 1);
        h_out(index1 : index2) = h_out(index1 : index2) + h(:, i + 1);
    end
    h_out = 1./h_out;
    y = h_out .* y;
end

