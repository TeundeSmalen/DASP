function y = overlap_addv2(Y, overlap_size)
    % calculate the step sizes and number of frames
    frame_size = size(Y,1);
    step_size = fix(frame_size - overlap_size/2);
    
    % retrieve signal
    y = zeros(step_size * size(Y,2), 1);
    for i = 0 : size(Y,2) - 2
        index1 = i*step_size + 1;
        index2 = index1 + frame_size - 1;
        y(index1 : index2) = y(index1 : index2) + Y(:, i + 1);
    end
end

