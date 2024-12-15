function [boundaryOut, mask] = detectSign(img, minRadius)
    % Constants
    CIRCULAR_THRESHOLD = 0.8;

    boundaryOut = [];

    % Convert RGB to HSV
    hsvImg = rgb2hsv(img);
    hue = hsvImg(:,:,1);
    sat = hsvImg(:,:,2);
    val = hsvImg(:,:,3);

    % Create binary mask for red color
    mask = createRedMask(hue, sat, val);

    % Remove small objects and dilate
    mask = bwareaopen(mask, 50);
    se = strel('disk', 4);
    mask = imdilate(mask, se);

    % Find boundaries
    [B,~] = bwboundaries(mask, 'noholes');

    bestRadius = 0;
    for k = 1:length(B)
        boundary = B{k};
        if isempty(boundary)
            continue;
        end

        % Compute circularity
        [circularity, radius] = computeCircularity(boundary);
        
        % Check conditions for sign detection
        if radius >= minRadius && circularity >= CIRCULAR_THRESHOLD
            if radius > bestRadius
                bestRadius = radius;
                boundaryOut = boundary;
            end
        end
    end
end
