classdef DistanceEstimator < handle
    properties (Access = private)
        config
    end
    methods
        function obj = DistanceEstimator(cfg)
            obj.config = cfg;
        end
        function distances = estimate(obj, bboxes, labels)
            n = size(bboxes, 1);
            distances = zeros(n, 1);
            for i = 1:n
                w = bboxes(i, 3);
                % Check if label is vehicle, car, truck, etc.
                labelStr = char(labels(i));
                if contains(lower(labelStr), 'car') || contains(lower(labelStr), 'truck') || contains(lower(labelStr), 'bus')
                    rw = obj.config.REAL_WIDTH_VEHICLE;
                else
                    rw = 1;
                end
                distances(i) = (rw * obj.config.FOCAL_LENGTH) / w;
            end
        end
    end
end