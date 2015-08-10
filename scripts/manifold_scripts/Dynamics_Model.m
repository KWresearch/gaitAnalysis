classdef Dynamics_Model < handle
    properties
        num_dim_Y
                
        interpolant_XY
        
        sigma_estimation
        sigma_test
        alpha_initial
        initial_estimate_X
        
        X
        T
        Y
        previous_N_fixed
        N_fixed
        nb_times_fixed
        
        current_alpha
        alpha_variable
        confidence
        window_size
        
        display_screen
        marginal_X_Yi
        limits_Yi
    end
    methods
        function obj = Dynamics_Model(filename_interpolant, display_screen)
            obj.display_screen = display_screen;
            if obj.display_screen ~= -1
                figure(display_screen)
                clf(display_screen)
            end
            
            structure = load(filename_interpolant);

            obj.interpolant_XY = structure.interpolant_XY;
            
            obj.num_dim_Y = size(structure.interpolant_Y.GridVectors,2);
            
            N = size(structure.interpolant_Y.GridVectors{1}, 2);
            for i=1:obj.num_dim_Y
                obj.limits_Yi(i,1) = structure.interpolant_Y.GridVectors{i}(1);
                obj.limits_Yi(i,2) = structure.interpolant_Y.GridVectors{i}(N);
            end
            
            for i=1:obj.num_dim_Y
                obj.marginal_X_Yi(:,:,i) = flipdim(structure.P_Yi_knowing_X(:,:,i),1);
            end
        end
        function initialise(obj, initial_X, alpha_ini, sigma_estimation, sigma_test)
            obj.T = [];
            obj.X = [];
            obj.Y = [];
            obj.N_fixed = 0;
            obj.current_alpha = alpha_ini;
            obj.alpha_variable = [];
            obj.window_size = [];
            obj.confidence = [];
            obj.nb_times_fixed = [];
            
            obj.initial_estimate_X = initial_X;
            obj.alpha_initial = alpha_ini;
            obj.sigma_estimation = sigma_estimation;
            obj.sigma_test = sigma_test;
        end
        function process_new_frame(obj, Yt, Tt)
            obj.T = [obj.T; Tt];
            obj.Y = [obj.Y; Yt(:,1:obj.num_dim_Y)];
            frame = size(obj.T,1);
            
            % estimate alpha and adjust the window size
            alpha = obj.estimate_alpha();
            sprintf('estimated alpha_variable: %f', alpha)
            obj.current_alpha = alpha;
            obj.window_size = [obj.window_size, frame - obj.N_fixed];
            
            % estimate X inside the window (and update N_fixed)
            obj.previous_N_fixed = obj.N_fixed;
            obj.estimate_X(alpha);
            sprintf('"normalised" log likelihood of X (or confidence): %f', obj.confidence(frame))
            obj.plot_estimated_X();
            
            % save the value of alpha for the frames that have converged
            if obj.previous_N_fixed < obj.N_fixed
                for i=obj.previous_N_fixed+1:obj.N_fixed
                    obj.alpha_variable(i) = alpha;
                end
            end
        end
        function alpha = estimate_alpha(obj)
            N = size(obj.X,1);
            
            if N < 5
                alpha = obj.alpha_initial;
                return
            end
            
            first_index = max(obj.N_fixed, 1);
            nb_points = N - first_index + 1;
            
            if nb_points < 3 % we need at least 2 intervals to compute the mean
                alpha = obj.alpha_initial;
            else
                X_2_to_N = obj.X(first_index+1:N);
                X_1_to_Nminus1 = obj.X(first_index:N-1);
                T_2_to_N = obj.T(first_index+1:N);
                T_1_to_Nminus1 = obj.T(first_index:N-1);

                delta_X = X_2_to_N - X_1_to_Nminus1;
                delta_T = T_2_to_N - T_1_to_Nminus1;

                factors = delta_X ./ delta_T;

                alpha = mean(factors);

                if alpha <= 0.75 * obj.alpha_initial; %0.015  0.75
                    alpha = 0.75 * obj.alpha_initial; %0.015;
                end
                if alpha >= 1.25 * obj.alpha_initial; %0.015  1.25
                    alpha = 1.25 * obj.alpha_initial; %0.015;
                end
%                     if alpha <= 0.015
%                         alpha = 0.015;
%                     end
                    
%                     if alpha > 0.025
%                         alpha = 0.025;
%                     end
            end
        end
        function estimate_X(obj, alpha)
            if obj.N_fixed > 0
                last_fixed_X = obj.X(obj.N_fixed);
            else
                last_fixed_X = obj.initial_estimate_X;
            end

            %function to be minimised over new_X, with extra parameters Y, alpha and T
            f = @(variable_X)(-obj.logP_x_knowing_y_partialUpdate(last_fixed_X,variable_X,alpha,obj.sigma_estimation));

            N = size(obj.X,1);

            if N > obj.N_fixed
                X_ini = obj.X(obj.N_fixed+1:N);
            else
                X_ini = [];
            end

            if N == 0
                new_X_ini = obj.initial_estimate_X;
            elseif N == 1
                new_X_ini = obj.X(N) + alpha;
            else
                new_X_ini = obj.X(N) + alpha * (obj.T(N+1) - obj.T(N));
            end

            X_ini = [X_ini; new_X_ini];

            [new_X_variable,loglikelihood] = fminunc(f,X_ini);
            obj.confidence = [obj.confidence, -loglikelihood / size(new_X_variable,1)];

            new_X = [obj.X(1:obj.N_fixed); new_X_variable];

            % comparer X_estimated et X_0 et noter ceux qui ne bougent plus
            % et ceux qui bougent encore

            candidates_new_N_fixed = [];

            for i = obj.N_fixed + 1 : N
                while i > size(obj.nb_times_fixed,1)
                    obj.nb_times_fixed = [obj.nb_times_fixed; 0];
                end
                
                if abs(obj.X(i) - new_X(i)) < 1e-3
                    obj.nb_times_fixed(i) = obj.nb_times_fixed(i)+1;
                else
                    obj.nb_times_fixed(i) = 0;
                end

                if obj.nb_times_fixed(i) >= 2
                    candidates_new_N_fixed = [candidates_new_N_fixed i];
                end
            end

            new_N_fixed = obj.N_fixed;
            i = obj.N_fixed + 1;
            for j=1:size(candidates_new_N_fixed,2)
                if i ~= candidates_new_N_fixed(j)
                    break;
                end
                new_N_fixed = i;
                i = i+1;
            end

            if new_N_fixed > N-3
                new_N_fixed = N-3;
            end

            if new_N_fixed < 0
                new_N_fixed = 0;
            end

            if new_N_fixed < N-13
                new_N_fixed = N-13;
            end
            
            if size(new_X, 1) < 12
                new_N_fixed = size(new_X, 1) - 2;
                if new_N_fixed < 0
                    new_N_fixed = 0;
                end
            elseif size(new_X, 1) == 12
                new_N_fixed = 0;
            end

            obj.N_fixed = new_N_fixed;
            obj.X = new_X;
        end
        function loglikelihood = logP_x_knowing_y_partialUpdate(obj, last_fixed_X, variable_X, alpha, sigma)
            N_variable = size(variable_X,1);

            % if N == 1, we only maximise P_cond_y(Y(1),X(1))
            % if N == 2, we maximise P_cond_y(Y(2),X(2)) * P_x_Markov_simple(X(2),X(1)) * P_cond_y(Y(1),X(1)) with P_x_Markov_simple(X(2),X(1)) = 0 if delta_X is negative, and uniform proba otherwise

            if obj.N_fixed == 0
                loglikelihood = obj.logP_cond_y(obj.Y(1,:),variable_X(1));
            else
                loglikelihood = obj.logP_cond_y(obj.Y(obj.N_fixed+1,:),variable_X(1)) + obj.logP_x_Markov(variable_X(1),last_fixed_X,obj.T(obj.N_fixed+1),obj.T(obj.N_fixed),alpha,sigma);
            end

            if N_variable > 1
                Y_2_to_N = obj.Y(obj.N_fixed+2:obj.N_fixed+N_variable,:);
                X_2_to_N = variable_X(2:N_variable);
                X_1_to_Nminus1 = variable_X(1:N_variable-1);
                T_2_to_N = obj.T(obj.N_fixed+2:obj.N_fixed+N_variable);
                T_1_to_Nminus1 = obj.T(obj.N_fixed+1:obj.N_fixed+N_variable-1);

                ll_proba_cond_y = obj.logP_cond_y(Y_2_to_N, X_2_to_N);
                ll_proba_x_Markov = obj.logP_x_Markov(X_2_to_N,X_1_to_Nminus1,T_2_to_N,T_1_to_Nminus1,alpha,sigma);
                vect_tmp = ll_proba_cond_y + ll_proba_x_Markov;

                loglikelihood = loglikelihood + sum(vect_tmp);
            end
        end
        function loglikelihood = logP_cond_y(obj, Yi, Xi)
            s = size(Yi,1);
            comp_small = repmat(obj.limits_Yi(:,1)',s,1);
            comp_big = repmat(obj.limits_Yi(:,2)',s,1);
            
            too_small = Yi < comp_small;
            too_big = Yi > comp_big;
            
            Yi(too_small) = comp_small(too_small);
            Yi(too_big) = comp_big(too_big);
            
            xy = [obj.normalise_X(Xi) Yi];
            
            if isempty(xy)
                loglikelihood = [];
                return;
            end
            
            loglikelihood = log(obj.interpolant_XY(xy));
        end
        function loglikelihood = logP_x_Markov(obj, Xi, Xim, Ti, Tim, alpha, sigma)
                        
            difference = (Xi - Xim) - alpha .* (Ti - Tim);

            % penalise negative dX
            indexes = Xi - Xim <= 0;
            if length(alpha) > 1
                difference(indexes) = 5 * (Xi(indexes) - Xim(indexes)) - alpha(indexes) .* (Ti(indexes) - Tim(indexes));
            else
                difference(indexes) = 5 * (Xi(indexes) - Xim(indexes)) - alpha .* (Ti(indexes) - Tim(indexes));
            end

            if isempty(difference)
                loglikelihood = -100;
            else
                loglikelihood = log(normpdf(difference,0,sigma));
            end
        end
        function llh_dynamics = compute_loglikelihood_dynamics_inwindow(obj)
            N = size(obj.X,1);
            start_frame = obj.N_fixed + 1;
            nb_points = N - start_frame + 1;
            
            if nb_points == 1
                llh_dynamics = nan;
                return
            end
            
            X_2_to_N = obj.X(start_frame+1:N);
            X_1_to_Nminus1 = obj.X(start_frame:N-1);
            T_2_to_N = obj.T(start_frame+1:N);
            T_1_to_Nminus1 = obj.T(start_frame:N-1);
            
            terme1 = sum( obj.logP_cond_y(obj.Y(start_frame:N,:), obj.X(start_frame:N)) );
            terme2 = sum( obj.logP_x_Markov(X_2_to_N,X_1_to_Nminus1,T_2_to_N,T_1_to_Nminus1,obj.current_alpha,obj.sigma_test) );
            llh_dynamics = (terme1 + terme2) / nb_points;
        end
        function list_frames = get_converged_frames(obj)
            if obj.previous_N_fixed < obj.N_fixed
                list_frames = [obj.previous_N_fixed+1:obj.N_fixed];
            else
                list_frames = [];
            end
        end
        function llh_dynamics = compute_loglikelihood_dynamics(obj, frames)
            indexes_float = frames > obj.N_fixed;
            if sum(indexes_float) ~= 0
                sprintf('compute_loglikelihood_dynamics() warning: the following frames have not converged yet:')
                frames(indexes_float)
                
                llh_dynamics(indexes_float) = nan;
            end
            
            llh_dynamics(frames <= 1) = nan;
            
            indexes = frames > 1 & frames <= obj.N_fixed;
            
            terme1 = obj.logP_cond_y(obj.Y(frames(indexes),:), obj.X(frames(indexes)));
            terme2 = obj.logP_x_Markov(obj.X(frames(indexes)),obj.X(frames(indexes)-1),obj.T(frames(indexes)),obj.T(frames(indexes)-1),obj.alpha_variable(frames(indexes))',obj.sigma_test);
            llh_dynamics(indexes) = terme1 + terme2;
        end
        function llh_dynamics = compute_loglikelihood_dynamics_forced(obj, frames)
            llh_dynamics(frames <= 1) = nan;
            
            indexes = frames > 1 & frames <= length(obj.T);
            
            terme1 = obj.logP_cond_y(obj.Y(frames(indexes),:), obj.X(frames(indexes)));
            terme2 = obj.logP_x_Markov(obj.X(frames(indexes)),obj.X(frames(indexes)-1),obj.T(frames(indexes)),obj.T(frames(indexes)-1),obj.alpha_variable(end),obj.sigma_test);
            llh_dynamics(indexes) = terme1 + terme2;
        end
        function plot_estimated_X(obj)
            if obj.display_screen ~= -1
                N = size(obj.X,1);
                start_frame = max(N - 50, 1);
                
                figure(obj.display_screen)
                
                for i=1:obj.num_dim_Y
                    subplot(obj.num_dim_Y,1,i)
                    hold off
                    imagesc([0 1],[obj.limits_Yi(i,1) obj.limits_Yi(i,2)],obj.marginal_X_Yi(:,:,i),'CDataMapping','scaled')
                    title(['Likelihood of (X,Y_' i ') to be normal (color plot) and estimated (X,Y_' i ') (black crosses)'])
                    xlabel('Percentage of movement completion X')
                    ylabel(['Manifold coordinate Y_' i])
                    hold on
                    plot(obj.normalise_X(obj.X(start_frame:N)),obj.Y(start_frame:N,i),'.k')
                end
            end
        end
    end
    methods (Abstract)
        X = normalise_X(obj, X)
        periodic = is_periodic(obj)
    end
end