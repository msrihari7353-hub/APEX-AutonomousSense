%% MAIN
clear; clc; close all;
addpath('src');

cfg      = Config();
camera   = CameraInterface(cfg);
detector = ObjectDetector(cfg);
depth    = DistanceEstimator(cfg);
rules    = TrafficRuleEngine(cfg);

fig = figure('Name', 'Detection', 'Position', [100 100 800 600], ...
    'KeyPressFcn', @(~,~) setappdata(gcf, 'stop', true), ...
    'MenuBar', 'none', 'ToolBar', 'none');
setappdata(fig, 'stop', false);

[initFrame, ~] = camera.getFrame();
hImg  = imshow(initFrame);
hTitle = title('Loading...', 'FontSize', 10);

% --- Shared state between display and detection ---
latestFrame  = initFrame;
latestBboxes = [];
latestScores = [];
latestLabels = [];
latestDists  = [];
state        = 'CRUISE';
currentSpeed = 0;
detectionDue = true;

% --- Async detection using parfeval ---
pool = gcp('nocreate');
if isempty(pool)
    pool = parpool(1);  % 1 background worker for detection
end
detFuture = [];

while ishandle(fig) && ~getappdata(fig, 'stop')

    % 1. Always grab latest camera frame
    [latestFrame, ~] = camera.getFrame();

    % 2. If previous detection is done, collect results and fire next one
    if ~isempty(detFuture) && strcmp(detFuture.State, 'finished')
        [latestBboxes, latestScores, latestLabels] = fetchOutputs(detFuture);
        latestBboxes = scaleBboxes(latestBboxes, size(latestFrame), cfg.INPUT_SIZE);
        latestDists  = depth.estimate(latestBboxes, latestLabels);
        [target, state] = rules.decide(latestBboxes, latestLabels, latestDists, currentSpeed);
        currentSpeed = target;
        detFuture = [];
    end

    % 3. Fire new detection if none running
    if isempty(detFuture)
        detFuture = parfeval(pool, @runDetect, 3, detector, latestFrame, cfg.DETECTION_THRESHOLD);
    end

    % 4. Display is NEVER blocked — always shows latest frame
    displayFrame = annotateFrame(latestFrame, latestBboxes, latestScores, latestLabels, latestDists);
    set(hImg, 'CData', displayFrame);
    set(hTitle, 'String', sprintf('%s | Objects:%d', state, size(latestBboxes,1)));
    drawnow limitrate;
end

camera.release();
delete(pool);
close all;
disp('Stopped');

%% Local Functions

function [bboxes, scores, labels] = runDetect(detector, frame, threshold)
    [bboxes, scores, labels] = detect(detector.detector, frame, ...
        'Threshold', threshold);
    validIdx = contains(string(labels), ["car","truck","bus","vehicle"], 'IgnoreCase', true);
    bboxes   = bboxes(validIdx, :);
    scores   = scores(validIdx);
    labels   = labels(validIdx);
end

function bboxes = scaleBboxes(bboxes, frameSize, inputSize)
    if isempty(bboxes), return; end
    scaleX = frameSize(2) / inputSize(2);
    scaleY = frameSize(1) / inputSize(1);
    bboxes(:, [1 3]) = bboxes(:, [1 3]) * scaleX;
    bboxes(:, [2 4]) = bboxes(:, [2 4]) * scaleY;
end

function frame = annotateFrame(frame, bboxes, scores, labels, distances)
    if isempty(bboxes), return; end
    for i = 1:size(bboxes, 1)
        frame = insertShape(frame, 'Rectangle', bboxes(i,:), ...
            'Color', 'green', 'LineWidth', 3);
        labelStr = sprintf('%s: %.2f (%.1fm)', labels(i), scores(i), distances(i));
        frame = insertText(frame, [bboxes(i,1) bboxes(i,2)-20], labelStr, ...
            'FontSize', 12, 'BoxColor', 'green', 'TextColor', 'white');
    end
end