% Parameters
cameraURL = 'http://192.168.137.206:81/stream'; 
MIN_RADIUS = 30;
TARGET_SIZE = [32, 32];
CENTER_CROP_PERCENTAGE = 65;
DATASET_ROOT = 'dataset123';    
CLASSES = {'1', '2', '3', '4'}; 
FIXED_CLASS_LABEL = '1';

% Set up camera
cam = ipcam(cameraURL);
frame = snapshot(cam);

% Counter for images
count = 0;

% Global variables for callbacks
global shouldCapture;
shouldCapture = false;
global shouldQuit;
shouldQuit = false;

% Create figure
figMain = figure('Name','Image Collection','NumberTitle','off','KeyPressFcn',@keyPressCallback);
hImg = imshow(frame);
hold on;
boundaryOverlay = plot(nan, nan, 'g-', 'LineWidth', 2);
title('Press SPACE to capture sign, ESC to quit');

while ishandle(figMain) && ~shouldQuit
    frame = snapshot(cam);
    [boundary, ~] = detectSign(frame, MIN_RADIUS);

    set(hImg, 'CData', frame);
    if ~isempty(boundary)
        x = boundary(:,2);
        y = boundary(:,1);
        set(boundaryOverlay, 'XData', x, 'YData', y, 'Visible', 'on');
    else
        set(boundaryOverlay, 'XData', nan, 'YData', nan, 'Visible', 'off');
    end
    drawnow;

    if shouldCapture && ~isempty(boundary)
        shouldCapture = false;

        % Preprocess sign region
        croppedImg = preprocessSignRegion(frame, boundary, CENTER_CROP_PERCENTAGE, TARGET_SIZE);

        % AUGMENTATION STEPS:
        % 1. Random rotation by 0, 90, or 180 degrees
        possibleAngles = [0, 90, 180];
        rotAngle = possibleAngles(randi(3));
        augImg = imrotate(croppedImg, rotAngle);

        % 2. Random brightness scaling between 0.5 and 1.5
        brightnessFactor = 0.5 + rand * 1.0;
        augImg = im2double(augImg);
        augImg = augImg * brightnessFactor;
        augImg = im2uint8(augImg);

        % 3. Add random Gaussian noise
        augImg = imnoise(augImg, 'gaussian');

        % Create folder if not exist
        classFolder = fullfile(DATASET_ROOT, FIXED_CLASS_LABEL);
        if ~exist(classFolder, 'dir')
            mkdir(classFolder);
        end

        timestamp = datestr(now,'yyyymmdd_HHMMSS_FFF');
        filename = fullfile(classFolder, ['sign_' timestamp '.png']);

        imwrite(augImg, filename);
        fprintf('Saved: %d\n', count);
        count = count + 1;
    end
end

if ishandle(figMain)
    close(figMain);
end

% Callback for key presses
function keyPressCallback(~, event)
    global shouldCapture shouldQuit;
    switch event.Key
        case 'space'
            shouldCapture = true;
        case 'escape'
            shouldQuit = true;
    end
end
