classdef Feature_joint_position < Feature
    methods
        function obj = Feature_joint_position()
            obj = obj@Feature();
        end
        function features = extract_low_level_features(obj, aligned_shapes)
            P = size(aligned_shapes,2);
            N = size(aligned_shapes,1);
            
            % joint position
            features = zeros(N,P*3);
            for i = 1:N
                features(i,:) = reshape(squeeze(aligned_shapes(i,:,:))',1,3*P);
            end
        end
    end
end