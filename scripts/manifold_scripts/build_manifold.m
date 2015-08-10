%LBcoef : 1 for Laplace-Beltrami
%Nsteps : 1 is fine
%robust : usually 0.01
function manifold_coords = build_manifold(trainingData, numDim, use_kNN, robust_coef, LBcoef, Nsteps, filename)

%similarity graph
X = trainingData; Y = trainingData;
m = size(X,1); n = size(Y,1);
Yt = Y';
XX = sum(X.*X,2);   YY = sum(Yt.*Yt,1);
dist = XX(:,ones(1,n)) + YY(ones(1,m),:) - 2*X*Yt;    % distance (squared)

dist_temp = dist;
dist_temp(dist_temp<10^-3) = 100000;
sigma = sum(min(dist_temp))/size(dist,1);
W = exp(-dist/(sigma^0.5));

% kNN
if (use_kNN ~= 0) || (robust_coef ~= 0)
    kNN = floor(length(W)/4);
    [~,index] = sort(W);
    [~,index_col] = sort(W,2);
    n = size(W,1);
    mask = zeros(n);
    for ii = 1:n
        mask(index(n-kNN:n,ii),ii) = 1;
        mask(ii, index_col(ii,n-kNN:n)) = 1;
    end
end

if (use_kNN ~= 0)
    W = mask .* W;
end

if (robust_coef ~= 0)
    W = (1-robust_coef) * W + robust_coef * mask;
end

% Laplace-Beltrami
if (LBcoef > 0)
    q = sum(W,2);
    D = diag(1./q.^LBcoef);
    W = sparse(D)*sparse(W)*sparse(D);
end

% normalized laplacian
D = sum(W,2);  % Degree matrix D
D = diag(1./D);
P = sparse(D)*W;

% eigen decomposition
[eigVet,eigVal,~]=svds(P,numDim+1);
eigVal = diag(eigVal)';
eigVet = diag(diag(D).^0.5)*eigVet;
eigVet = eigVet/eigVet(1,1);

m = size(eigVet,1);
manifold_coords = repmat(eigVal(2:numDim+1).^Nsteps,m,1) .* eigVet(:,2:numDim+1);

figure(4)
plot3(manifold_coords(:,1),manifold_coords(:,2),manifold_coords(:,3),'.')
figure(5)
plot(manifold_coords(:,1))
figure(6)
plot(manifold_coords(:,2))

structure = struct('trainingData', trainingData, 'numDim', numDim, 'eigVet', eigVet, 'eigVal', eigVal, 'manifold_coords_trainingPoints', manifold_coords, 'q', q, 'sigma', sigma, 'use_kNN', use_kNN, 'kNN', kNN, 'LBcoef', LBcoef, 'Nsteps', Nsteps, 'robust', robust_coef);
save(filename,'structure');

end
