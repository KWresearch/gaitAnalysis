classdef Alignment_Procrustes < Alignment
    properties
        reference_shape
        Q2
        c2
        scale_of_reference
    end
    methods
        function obj = Alignment_Procrustes(flipped_bool)
            obj = obj@Alignment();
            
            structure = load('Procrustes_reference_shape');
            obj.reference_shape = structure.reference_shape;
%             reference_shape_flipped = structure.reference_shape;
%            % if(flipped_bool)
%                 for joint=1:3:size(obj.reference_shape, 2);
%                    reference_shape_flipped(:,joint)=obj.reference_shape(:,joint).*-1;
%                 end
%             %end
%             centred_refshape = obj.reference_shape - repmat(mean(obj.reference_shape,2),1,size(obj.reference_shape,2)); 
%             centred_flipped_refshape = reference_shape_flipped - repmat(mean(reference_shape_flipped,2),1,size(reference_shape_flipped,2)); 
%             
%             obj.reference_shape = (centred_refshape + centred_flipped_refshape)./2;
%     
%            % shape = reshape(centred_refshape(10,:),3,15)';
%             PlotSkeleton_SDK(reference_shape_flipped);
%            % figure(10)
%             hold on
%             %plot_skeletons(flipped_low_level_features);
% 
%            % shape = reshape(centred_flipped_refshape(10,:),3,15)';
%             PlotSkeleton_SDK(centred_refshape);
%             pause;
%             hold off 
% 
%             PlotSkeleton_SDK(obj.reference_shape);
%             pause;

            obj.Q2 = obj.reference_shape';
            obj.c2 = obj.Q2 - repmat(mean(obj.Q2,2),1,size(obj.Q2,2));
            obj.scale_of_reference = sum(sum((obj.reference_shape-repmat(mean(obj.reference_shape,1),size(obj.reference_shape,1),1)).^2,1));
        end
        function [aligned_shapes,selection] = align(obj, data)
            P = size(data,2)/3; % # joints
            N = size(data,1); % # frames
            
            aligned_shapes = zeros(N,P,3);
            dissimilarity_measure = zeros(N,1);
            
            for i = 1:N % for each frame
                shape = reshape(data(i,:),3,P)';
                aligned_shapes(i,:,:) = obj.shape_alignment(shape);
                dissimilarity_measure(i) = obj.compute_dissimilarity(squeeze(aligned_shapes(i,:,:)));
                %[D, Z] = procrustes(obj.reference_shape, shape);
                %aligned_shapes(i,:,:) = Z;
                %dissimilarity_measure(i) = D;
            end
            
            figure(2)
            hold off
            plot(dissimilarity_measure)
            hold on
            plot(1:length(dissimilarity_measure),0.1)
            
            selection = dissimilarity_measure < 0.1;
        end
        function aligned_shape = shape_alignment(obj, shape)
            Q1 = shape';
            
            % move to centro1id
            c1 = Q1 - repmat(mean(Q1,2),1,size(Q1,2)); 
            
            % covariance matrix
            H = obj.c2*c1';

            % svd
            [U,~,V] = svd(H);
            X = U*V';

            %rotation matrix
            D = eye(3);
            if (round(det(X)) == -1)
               D(3,3) = -1;
            end
            R = U*D*V';

            %scaling factor
            s = obj.get_scaling_factor(c1, R);
            % translation
            T = repmat(mean(obj.Q2,2),1,size(obj.Q2,2)) - s*R*repmat(mean(Q1,2),1,size(obj.Q2,2));
            % result
            aligned_shape = s*R*Q1 + T;
            
            aligned_shape = aligned_shape';
        end
        function factor = get_scaling_factor(obj, c1, R)
            factor = trace(c1*obj.c2'*R)/trace(c1*c1');
        end
        function dissimilarity = compute_dissimilarity(obj, shape)
            %sum of squared distances of joints, standardized by a measure of the scale of the reference shape
            dissimilarity = sum(sum((shape - obj.reference_shape).^2,2)) / obj.scale_of_reference;
        end
    end
end