% Load the trained CNN
load('trainedModel.mat', 'net');

% Parameters
cameraURL = 'http://192.168.137.206:81/stream'; 
arduinoIP = '192.168.137.129';
port = 12345;
MIN_RADIUS = 30;
TARGET_SIZE = [32, 32];
CENTER_CROP_PERCENTAGE = 65;
current_speed = 1;

% Set up camera and UDP communication
cam = ipcam(cameraURL);
frame = snapshot(cam);
udpClient = udpport("IPV4");

% Create figure for visualization
figMain = figure();
ax1 = subplot(1,2,1);
ax2 = subplot(1,2,2);

hImg = imshow(frame, 'Parent', ax1);
hold(ax1, 'on');
title(ax1, 'Main Video');
greenCircle = plot(ax1, nan, nan, 'g-', 'LineWidth', 2);

hProcessed = imshow(zeros(32,32), 'Parent', ax2);
hold(ax2, 'on');
title(ax2, 'Processed Image and Prediction');

% Main loop
while ishandle(figMain)
    % Acquire frame
    frame = snapshot(cam);

    % Detect the sign
    [boundary, ~] = detectSign(frame, MIN_RADIUS);

    % Update main video
    set(hImg, 'CData', frame);

    % Update boundary display
    if ~isempty(boundary)
        x = boundary(:,2);
        y = boundary(:,1);
        set(greenCircle, 'XData', x, 'YData', y, 'Visible', 'on');
    else
        set(greenCircle, 'XData', nan, 'YData', nan, 'Visible', 'off');
    end

    % If sign detected, process and classify
    if ~isempty(boundary)
        processedImg = preprocessSignRegion(frame, boundary, CENTER_CROP_PERCENTAGE, TARGET_SIZE);
        imshow(processedImg, 'Parent', ax2);

        % Classify
        label = classify(net, processedImg);
        current_speed = str2double(string(label));
    end

    disp(current_speed);

    % Send speed to Arduino
    strSpeed = num2str(current_speed);
    write(udpClient, uint8(strSpeed), "uint8", arduinoIP, port);
end
