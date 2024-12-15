function processedImg = preprocessSignRegion(frame, boundary, CENTER_CROP_PERCENTAGE, TARGET_SIZE)
    % Compute bounding box
    minX = floor(min(boundary(:,2)));
    maxX = ceil(max(boundary(:,2)));
    minY = floor(min(boundary(:,1)));
    maxY = ceil(max(boundary(:,1)));

    % Crop the region from the original frame
    croppedImg = imcrop(frame, [minX, minY, (maxX - minX), (maxY - minY)]);

    % Crop out center portion of the sign to isolate the number
    [h, w, ~] = size(croppedImg);
    cropFactor = CENTER_CROP_PERCENTAGE/100;
    newH = round(h * (1 - cropFactor));
    newW = round(w * (1 - cropFactor));
    startY = round((h - newH) / 2);
    startX = round((w - newW) / 2);
    endY = startY + newH - 1;
    endX = startX + newW - 1;
    croppedImg = croppedImg(startY:endY, startX:endX, :);

    % Resize and convert to grayscale
    processedImg = imresize(croppedImg, TARGET_SIZE);
    processedImg = rgb2gray(processedImg);
end
