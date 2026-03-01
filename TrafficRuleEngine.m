classdef TrafficRuleEngine < handle
    properties (Access = private)
        config
    end
    methods
        function obj = TrafficRuleEngine(cfg)
            obj.config = cfg;
        end
        function [targetSpeed, state] = decide(obj, bboxes, labels, distances, currentSpeed)
            targetSpeed = obj.config.DEFAULT_CRUISE_SPEED;
            state = 'CRUISE';
            if isempty(distances), return; end
            [minDist, ~] = min(distances);
            if minDist < obj.config.CRITICAL_DISTANCE
                targetSpeed = 0; state = 'STOP';
            elseif minDist < obj.config.SAFE_FOLLOWING_DISTANCE
                targetSpeed = currentSpeed * 0.5; state = 'SLOW';
            end
        end
    end
end