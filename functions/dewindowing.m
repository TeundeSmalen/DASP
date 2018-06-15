function Y_out = dewindowing(Y, filter)
frame_size = size(Y,1);
    switch(filter)
        case 'rect'
            h = rectwin(frame_size);
        case 'hann'
            h = hann(frame_size);
        case 'hamm'
            h = hamming(frame_size);
        case 'shann'
            h = sqrt(hann(frame_size));
            h(1) = 1;
            h(frame_size) = 1;
        case 'black'
            h = blackmanharris(frame_size);
        case 'nutt'
            h = nuttallwin(frame_size);
    end
    Y_out = 1./repmat(h, 1, size(Y,2)) .* Y;    
end