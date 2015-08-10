classdef Dynamics_Model_Periodic < Dynamics_Model
    methods
        function obj = Dynamics_Model_Periodic(filename_interpolant, display_screen)
            obj = obj@Dynamics_Model(filename_interpolant, display_screen);
        end
        function X = normalise_X(obj, X)
            X = mod(X, 1);
        end
        function periodic = is_periodic(obj)
            periodic = 1;
        end
    end
end