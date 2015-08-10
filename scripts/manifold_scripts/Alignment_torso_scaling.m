classdef Alignment_torso_scaling < Alignment
    properties
        reference_height
    end
    methods
        function obj = Alignment_torso_scaling()
            obj = obj@Alignment();
            
            structure = load('Procrustes_reference_shape');
            reference_shape = structure.reference_shape;
            obj.reference_height = norm(reference_shape(2,:) - reference_shape(9,:));
        end
        function [aligned_shapes,selection] = align(obj, data)
            P = size(data,2)/3; % # joints
            N = size(data,1); % # frames
            
            aligned_shapes = zeros(N,P,3);
            
            for i = 1:N % for each frame
                shape = reshape(data(i,:),3,P)';
                %shape = (shape - repmat(mean(shape,1),length(shape),1));
                height = norm(shape(2,:) - shape(9,:));
                aligned_shapes(i,:,:) = shape * obj.reference_height / height;
            end
            
            selection = 1:N;
        end
    end
end