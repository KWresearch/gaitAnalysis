classdef Interface_Periodic < Interface
    methods
        function obj = Interface_Periodic(smoothing, windowSize, alignment_type, feature_type, manifold_filename, filename_interpolant, display_screen)
            obj = obj@Interface(smoothing, windowSize, alignment_type, feature_type, manifold_filename, filename_interpolant, display_screen);
            
            obj.dynamics_model = Dynamics_Model_Periodic(filename_interpolant, display_screen+1);
        end
        function initialise(obj, initial_alpha, sigma_estimation, sigma_test, possible_local_minimum)
            if possible_local_minimum && obj.N > 15
                
                figure(obj.display_screen)
                clf(obj.display_screen)
                
                % choose the most likely initial X
                llh_X = [0,0,0,0];
                
                % start from 0
                obj.dynamics_model.initialise(0, initial_alpha, sigma_estimation, sigma_test);
                
                for i=1:15
                    obj.dynamics_model.process_new_frame(obj.Y(i,:), obj.T(i));
                end
                
                llhs = obj.dynamics_model.compute_loglikelihood_dynamics_forced(1:15);
                llh_X(1) = sum( llhs(isfinite(llhs)) );
                
                
                % start from 0.25
                obj.dynamics_model.initialise(0.25, initial_alpha, sigma_estimation, sigma_test);
                
                for i=1:15
                    obj.dynamics_model.process_new_frame(obj.Y(i,:), obj.T(i));
                end
                
                llhs = obj.dynamics_model.compute_loglikelihood_dynamics_forced(1:15);
                llh_X(2) = sum( llhs(isfinite(llhs)) );
                
                % start from 0.5
                obj.dynamics_model.initialise(0.5, initial_alpha, sigma_estimation, sigma_test);
                
                for i=1:15
                    obj.dynamics_model.process_new_frame(obj.Y(i,:), obj.T(i));
                end
                
                llhs = obj.dynamics_model.compute_loglikelihood_dynamics_forced(1:15);
                llh_X(3) = sum( llhs(isfinite(llhs)) );
                
                % start from 0.75
                obj.dynamics_model.initialise(0.75, initial_alpha, sigma_estimation, sigma_test);
                
                for i=1:15
                    obj.dynamics_model.process_new_frame(obj.Y(i,:), obj.T(i));
                end
                
                llhs = obj.dynamics_model.compute_loglikelihood_dynamics_forced(1:15);
                llh_X(4) = sum( llhs(isfinite(llhs)) );
                
                % choose best
                [~, ind] = max(llh_X);
                x = [0,0.25,0.5,0.75];
                x_ini = x(ind);
                
                obj.dynamics_model.initialise(x_ini, initial_alpha, sigma_estimation, sigma_test);
           else
                %default
                obj.dynamics_model.initialise(0, initial_alpha, sigma_estimation, sigma_test);
           end
        end
    end
end