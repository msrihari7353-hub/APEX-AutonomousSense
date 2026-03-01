classdef ObjectDetector < handle
    properties (Access = private)
        detector
        config
    end

    properties (Constant, Access = private)
        VALID_CLASSES = ["car", "truck", "bus", "vehicle"];
    end

    methods
        function obj = ObjectDetector(cfg)
            obj.config = cfg;

            modelPath = 'models/yoloWeights.mat';
            assert(isfile(modelPath), 'Model file not found: %s', modelPath);

            data         = load(modelPath);
            obj.detector = data.detector;

            disp('OPTIMIZED: YOLO with balanced settings');
        end

        function processed = preprocess(obj, frame)
            processed = imresize(frame, obj.config.INPUT_SIZE);
        end

        function [bboxes, scores, labels] = detect(obj, frame)
            [bboxes, scores, labels] = detect( ...
                obj.detector, frame, ...
                'Threshold', obj.config.DETECTION_THRESHOLD);
            validIdx = contains(string(labels), ObjectDetector.VALID_CLASSES, 'IgnoreCase', true);
            bboxes   = bboxes(validIdx, :);
            scores   = scores(validIdx);
            labels   = labels(validIdx);
        end
    end
end