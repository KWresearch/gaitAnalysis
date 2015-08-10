classdef Feature_pairwise_relative_angles < Feature
    properties
        angle_pairs
        n
    end
    methods
        function obj = Feature_pairwise_relative_angles()
            obj = obj@Feature();
            
            % get segment pairs index
            segment_pairs_matrix1 = repmat(1:14,14,1);
            Low_mat1 = tril(segment_pairs_matrix1,-1);
            segment_pairs_idx1 = Low_mat1(Low_mat1 ~= 0);
            
            segment_pairs_matrix2 = repmat([1:14]',1,14);
            Low_mat2 = tril(segment_pairs_matrix2,-1);
            segment_pairs_idx2 = Low_mat2(Low_mat2 ~= 0);
            
            segment_pairs = [segment_pairs_idx1,segment_pairs_idx2];
            
            angle_pairs_idx = [1,2;2,3;2,4;3,5;4,6;5,7;6,8;2,9;9,10;9,11;10,12;11,13;12,14;13,15];
            obj.angle_pairs(:,1:2) = angle_pairs_idx(segment_pairs(:,1),:);
            obj.angle_pairs(:,3:4) = angle_pairs_idx(segment_pairs(:,2),:);
            obj.n = size(obj.angle_pairs,1);
        end
        function features = extract_low_level_features(obj, aligned_shapes)
            N = size(aligned_shapes,1); % #frames
            
            % pairwise Euclidean distances
            features = zeros(N,4*obj.n);
            for i = 1:N
                shape = squeeze(aligned_shapes(i,:,:));
                
                feature = zeros(4*obj.n,1);
                for j = 1:obj.n
                    bone1_global = shape(obj.angle_pairs(j, 2),:)' - shape(obj.angle_pairs(j, 1),:)';
                    bone2_global = shape(obj.angle_pairs(j, 4),:)' - shape(obj.angle_pairs(j, 3),:)';
                    R = vrrotvec2mat(vrrotvec(bone1_global, [1, 0, 0]));
                    feature(4*j-3:4*j,1) = vrrotvec(R*bone1_global, R*bone2_global); 
                end
                
                features(i,:) = feature(:)';
            end
        end
    end
end