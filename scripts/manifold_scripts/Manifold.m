classdef Manifold < handle
    properties
        trainingData
        numDim
        eigVet
        eigVal
        q
        sigma
        use_kNN
        kNN
        LBcoef  % 1 for Laplace-Beltrami
        Nsteps  % 1 is fine
        robust  % usually 0.01
        manifold_coords_trainingPoints
        
        %temporary variables
        P_new
    end
    methods
        function obj = Manifold(filename)
            load(filename);
            obj.trainingData = structure.trainingData;
            obj.numDim = structure.numDim;
            obj.eigVet = structure.eigVet;
            obj.eigVal = structure.eigVal;
            obj.manifold_coords_trainingPoints = structure.manifold_coords_trainingPoints;
            obj.q = structure.q;
            obj.sigma = structure.sigma;
            obj.use_kNN = structure.use_kNN;
            obj.kNN = structure.kNN;
            obj.LBcoef = structure.LBcoef;
            obj.Nsteps = structure.Nsteps;
            obj.robust = structure.robust;
        end
        function manifold_coords = projection(obj, newdata)
            n = size(obj.trainingData,1);
            
            distnew = sum((repmat(newdata,n,1)-obj.trainingData).^2,2);
            W_new = exp(-distnew/(obj.sigma^0.5));
                        
            if (obj.use_kNN ~= 0) || (obj.robust ~= 0)
                [~,index] = sort(W_new);
                mask = zeros(n,1);
                mask(index(n-obj.kNN:n,1)) = 1;
            end
            
            if obj.use_kNN ~= 0
                W_new = mask .* W_new;
            end
            
            if obj.robust ~= 0
                W_new = (1-obj.robust) * W_new + obj.robust * mask;
            end
            
            W_new = W_new ./ obj.q;  % vector
            D_new = 1 ./ sum(W_new, 1);  % scalar
            obj.P_new = D_new .* W_new;  % vector
            
            manifold_coords = obj.eigVal(2:obj.numDim+1).^(obj.Nsteps-1) .* (obj.P_new' * obj.eigVet(:,2:obj.numDim+1));
        end
    end
end