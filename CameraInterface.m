classdef CameraInterface < handle
    properties (Access = private)
        cameraObj
    end
    methods
        function obj = CameraInterface(cfg)
            obj.cameraObj = webcam(cfg.CAMERA_ID);
            obj.cameraObj.Resolution = sprintf('%dx%d', cfg.FRAME_WIDTH, cfg.FRAME_HEIGHT);
            for i = 1:3, snapshot(obj.cameraObj); end
            disp('Camera ready');
        end
        function [frame, ts] = getFrame(obj)
            frame = snapshot(obj.cameraObj);
            ts = now;
        end
        function release(obj)
            clear obj.cameraObj;
        end
    end
end