classdef Pose_Model < handle
    properties
        num_dim_Y
        
        interpolant_Y
        limits_Yi
    end
    methods
        function obj = Pose_Model(interpolant_filename)
            structure = load(interpolant_filename);
            
            obj.interpolant_Y = structure.interpolant_Y;
            obj.num_dim_Y = size(obj.interpolant_Y.GridVectors,2);
            
            N = size(obj.interpolant_Y.GridVectors{1}, 2);
            for i=1:obj.num_dim_Y
                obj.limits_Yi(i,1) = obj.interpolant_Y.GridVectors{i}(1);
                obj.limits_Yi(i,2) = obj.interpolant_Y.GridVectors{i}(N);
            end
        end
        function loglikelihood = compute_loglikelihood_Y(obj, y)
            y = y(:,1:obj.num_dim_Y);
            
            s = size(y,1);
            comp_small = repmat(obj.limits_Yi(:,1)',s,1);
            comp_big = repmat(obj.limits_Yi(:,2)',s,1);
            
            too_small = y < comp_small;
            too_big = y > comp_big;
            
            y(too_small) = comp_small(too_small);
            y(too_big) = comp_big(too_big);
            
            loglikelihood = log(obj.interpolant_Y(y));
        end
    end
end