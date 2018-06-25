function noise_estimate = noisePSD(Y, noise_prev, VAD, alpha)
% noise_estimate = frame_sizex1
% Y = frame_sizex1
% noise_prev = frame_sizex1
% VAD = 0 or 1
% alpha = between 0 and 1

    if VAD == 0
        noise_estimate =  noise_prev;    
    else
        noise_estimate =  alpha*noise_prev + (1-alpha)*abs(Y)^2;
    end
end