classdef Feature_joint_velocity < Feature
    properties
        fps
    end
    methods
        function obj = Feature_joint_velocity()
            obj = obj@Feature();
            
            obj.fps = 1;
        end
        function features = extract_low_level_features(obj, aligned_shapes)
            P = size(aligned_shapes,2);
            N = size(aligned_shapes,1);
            
            % joint position
            positions = zeros(N,P*3);
            for i = 1:N
                positions(i,:) = reshape(squeeze(aligned_shapes(i,:,:))',1,3*P);
            end
            
            % joint velocity
            features = zeros(N-1,P*3);
            for i = 1:P
                for j = 1:3
                    DistP = positions(:,(i-1)*3+j)';
                    SpeedP_temp = (DistP(2:end)-DistP(1:end-1)) / (1/obj.fps);
                    
                    features(:,(i-1)*3+j) = SpeedP_temp';
                end
            end
        end
    end
end