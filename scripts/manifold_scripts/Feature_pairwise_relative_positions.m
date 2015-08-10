classdef Feature_pairwise_relative_positions < Feature
    properties
        joint_pairs
    end
    methods
        function obj = Feature_pairwise_relative_positions()
            obj = obj@Feature();
            
            % get joint pairs index
            joint_pairs_matrix1 = repmat(1:15,15,1);
            Low_mat1 = tril(joint_pairs_matrix1,-1);
            joint_pairs_idx1 = Low_mat1(Low_mat1 ~= 0);
            
            joint_pairs_matrix2 = repmat([1:15]',1,15);
            Low_mat2 = tril(joint_pairs_matrix2,-1);
            joint_pairs_idx2 = Low_mat2(Low_mat2 ~= 0);
            
            obj.joint_pairs = [joint_pairs_idx1,joint_pairs_idx2];
        end
        function features = extract_low_level_features(obj, aligned_shapes)
            N = size(aligned_shapes,1);
            
            % pairwise Euclidean distances
            features = zeros(N,3*length(obj.joint_pairs));
            for i = 1:N
                relative_position = aligned_shapes(i,obj.joint_pairs(:,1),:) - aligned_shapes(i,obj.joint_pairs(:,2),:);
                features(i,:) = relative_position(:)';
            end
        end
    end
end