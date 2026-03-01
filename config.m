classdef config
    properties (Constant)
        CAMERA_ID     = 1;
FRAME_WIDTH   = 640;   % keep this, higher res = more lag
FRAME_HEIGHT  = 480;
FPS           = 60;    % max camera FPS

% --- Detection ---
DETECTION_THRESHOLD = 0.3;  % lower = more detections
NMS_THRESHOLD       = 0.3;
INPUT_SIZE          = [416 416];  % best accuracy for YOLO
        FOCAL_LENGTH = 800;
        REAL_WIDTH_VEHICLE = 1.8;
        REAL_WIDTH_STOP_SIGN = 0.6;
        REAL_WIDTH_TRAFFIC_LIGHT = 0.3;
        SAFE_FOLLOWING_DISTANCE = 15;
        CRITICAL_DISTANCE = 5;
        MAX_SPEED = 30;
        DEFAULT_CRUISE_SPEED = 20;
    end
end