classdef Preprocessing
    properties
        smoothing_filter  %  1 for smoothing of skeleton coordinates, 0 otherwise
        windowSize  % 9 is fine
        
        alignment_module
        feature_extractor
    end
    methods
        function obj = Preprocessing(smoothing, windowSize, alignment_type, feature_type, flipped_bool)
            obj.smoothing_filter = smoothing;
            if smoothing
                obj.windowSize = windowSize;
            end
            
            switch lower(alignment_type)
                case 'procrustes'
                    obj.alignment_module = Alignment_Procrustes(flipped_bool);
                    
                case 'torso_scaling'
                    obj.alignment_module = Alignment_torso_scaling();
                case 'none'
                    obj.alignment_module = Alignment_none();
                otherwise
                    disp('Error: Unknown alignment method!')
            end
            
            switch lower(feature_type)
                case 'angles'
                    disp('Feature module is not ready')
                case 'joint_position'
                    obj.feature_extractor = Feature_joint_position();
                case 'joint_velocity'
                    obj.feature_extractor = Feature_joint_velocity();
                case 'pairwise_relative_positions'
                    obj.feature_extractor = Feature_pairwise_relative_positions();
                case 'pairwise_relative_angles'
                    obj.feature_extractor = Feature_pairwise_relative_angles();
                otherwise
                    disp('Error: Unknown feature type!')
            end
        end
        function [new_coords,selection] = preprocess(obj, sequence)
            sequence = sequence*10^-3;
            
            if obj.smoothing_filter
                sequence = obj.filtering(sequence); % smoothing filter
            end
            
            [aligned_shapes,selection] = obj.alignment_module.align(sequence);
            
            new_coords = obj.feature_extractor.extract_low_level_features(aligned_shapes);
        end
        function filtered_coords = filtering(obj, raw_coords)
            filtered_coords = raw_coords;
            
            for i=1:size(raw_coords,2)
                filtered_coords(:,i) = smooth(raw_coords(:,i), obj.windowSize);
            end
%             windowSize = 10;
%             filtered_coords = filter(ones(1,windowSize)/windowSize,1,raw_coords);
%             filtered_coords = filtered_coords(windowSize+2:end,:);
        end
    end
end