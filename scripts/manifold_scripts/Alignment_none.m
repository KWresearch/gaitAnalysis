classdef Alignment_none < Alignment
    methods
        function obj = Alignment_none()
            obj = obj@Alignment();
        end
        function [aligned_shapes,selection] = align(obj, data)
            P = size(data,2)/3; % # joints
            N = size(data,1); % # frames
            
            aligned_shapes = zeros(N,P,3);
            
            for i = 1:N % for each frame
                shape = reshape(data(i,:),3,P)';
                aligned_shapes(i,:,:) = shape;
            end
            
            selection = 1:N;
        end
    end
end