classdef Interface < handle
    properties
        raw_data
        T
        low_level_features
        Y
        N
        
        preprocessor
        manifold
        pose_model
        dynamics_model
        
        loglikelihood_pose
        loglikelihood_dynamics_window
        loglikelihood_dynamics
        
        threshold_pose
        threshold_dynamics
        
        early_detection_abnormal
        early_detection_normal
        
        display_screen
    end
    methods
        function obj = Interface(smoothing, windowSize, alignment_type, feature_type, manifold_filename, interpolant_filename, display_screen)
            obj.preprocessor = Preprocessing(smoothing, windowSize, alignment_type, feature_type);
            obj.manifold = Manifold(manifold_filename);
            obj.pose_model = Pose_Model(interpolant_filename);
            
            obj.display_screen = display_screen;
        end
        function process_new_sequence(obj, filename, initial_alpha, sigma_estimation, sigma_test, possible_local_minimum, threshold_pose, threshold_dynamics)
            obj.threshold_pose = threshold_pose;
            obj.threshold_dynamics = threshold_dynamics;
            
            obj.raw_data = [];
            obj.T = [];%feed frame numbers into here
            obj.low_level_features = [];
            obj.Y = [];%feed network outputs into here
            obj.N = [];
            obj.loglikelihood_pose = [];
            obj.loglikelihood_dynamics_window = [];
            obj.loglikelihood_dynamics = [];
            obj.early_detection_abnormal = [];
            obj.early_detection_normal = [];
            
            obj.read_data(filename);
            obj.N = size(obj.T,1);
            
%             [obj.low_level_features,~] = obj.preprocessor.preprocess(obj.raw_data);
%             
%             for frame=1:obj.N
%                 obj.Y = [obj.Y; obj.manifold.projection(obj.low_level_features(frame,:))];
%             end
            
            if initial_alpha == -1
                % estimate initial_alpha from the main frequency of Y_1
                ft = smooth(abs(fft(obj.Y(:,1)-mean(obj.Y(:,1)))));
                [maxValue,indexMax] = max(ft(1:length(ft)/2));
                initial_alpha = indexMax / length(obj.Y(:,1));
            end
            
            obj.initialise(initial_alpha, sigma_estimation, sigma_test, possible_local_minimum);
            
            for frame=1:obj.N
                obj.process_frame(frame);
                
                if obj.display_screen ~= -1
                    obj.plot();
                end
            end
            
            remaining_frames = length(obj.loglikelihood_dynamics)+1:obj.N;
            obj.loglikelihood_dynamics(remaining_frames) = obj.dynamics_model.compute_loglikelihood_dynamics_forced(remaining_frames);%this is the normality result
        end
        function read_data(obj, filename)
            data = load(char(filename));
            
            S = data(:,2:end);
            P = (size(S,2))/4; % #joint points
            idx = reshape(1:P*4,4,P);
            index = reshape(idx(2:4,:),3*P,1);
            obj.raw_data = S(1:end,index);
            
            obj.T = data(:,1);
        end
        function process_frame(obj, frame_number)
            Yt = obj.Y(frame_number,:);
            Tt = obj.T(frame_number);
            
            obj.loglikelihood_pose(frame_number) = obj.pose_model.compute_loglikelihood_Y(Yt);
            
            obj.dynamics_model.process_new_frame(Yt, Tt);
            
            obj.loglikelihood_dynamics_window(frame_number) = obj.dynamics_model.compute_loglikelihood_dynamics_inwindow();
            list_frames_converged = obj.dynamics_model.get_converged_frames();
            obj.loglikelihood_dynamics(list_frames_converged) = obj.dynamics_model.compute_loglikelihood_dynamics(list_frames_converged);
        end
        function plot(obj)
            obj.dynamics_model.plot_estimated_X();
            
            figure(obj.display_screen);
            
            n = length(obj.loglikelihood_dynamics_window);
            
            subplot(4,1,1)
            hold off
            plot(obj.T(1:n),obj.Y(1:n,1))
            title('Pose representation')
            xlabel('frame number')
            ylabel('1st dimension')
            XL = xlim;
            
            subplot(4,1,2)
            hold off
            plot(obj.T(1:n),obj.loglikelihood_pose)
            hold on
            indexes_p = (obj.loglikelihood_pose < obj.threshold_pose);
            plot(obj.T(indexes_p),obj.loglikelihood_pose(indexes_p),'.r')
            title('Likelihood of the pose to be normal')
            xlabel('Frame number')
            ylabel('Log likelihood')
            xlim(XL)
            YL = ylim;
            YL1 = max(YL(1),-5);
            ylim([YL1 YL(2)])
            hold on
            
            subplot(4,1,3)
            hold off
            plot(obj.T(1:n),obj.loglikelihood_dynamics_window)
            hold on
            indexes_w = (obj.loglikelihood_dynamics_window < obj.threshold_dynamics);
            plot(obj.T(indexes_w),obj.loglikelihood_dynamics_window(indexes_w),'.r')
            title('Likelihood of the dynamics to be normal, computed in the dynamic window')
            xlabel('Frame number')
            ylabel('Log likelihood')
            xlim(XL)
            YL = ylim;
            YL1 = max(YL(1),-20);
            ylim([YL1 YL(2)])
            hold on
            
            subplot(4,1,4)
            hold off
            n2 = length(obj.loglikelihood_dynamics);
            plot(obj.T(1:n2),obj.loglikelihood_dynamics)
            hold on
            indexes_d = (obj.loglikelihood_dynamics < obj.threshold_dynamics);
            plot(obj.T(indexes_d),obj.loglikelihood_dynamics(indexes_d),'.r')
            title('Likelihood of the dynamics to be normal, computed for each converged frame')
            xlabel('Frame number')
            ylabel('Log likelihood')
            xlim(XL)
            YL = ylim;
            YL1 = max(YL(1),-20);
            YL2 = min(YL(2),10);
            ylim([YL1 YL2])
            hold on
            
            subplot(4,1,1)
            hold on
            plot(obj.T(indexes_p),obj.Y(indexes_p,1),'.r')
            %plot(obj.T(indexes_w),obj.Y(indexes_w,1),'.r')
            plot(obj.T(indexes_d),obj.Y(indexes_d,1),'.r')
            %indexes = indexes_p == 0 & indexes_w == 0 & [indexes_d ones(1,n-n2)] == 0;
            indexes = indexes_p == 0 & [indexes_d ones(1,n-n2)] == 0;
            plot(obj.T(indexes),obj.Y(indexes,1),'.g')
        end
    end
    methods (Abstract)
        initialise(obj, initial_alpha, sigma_estimation, sigma_test, possible_local_minimum)
    end
end