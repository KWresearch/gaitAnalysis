% prepare the pdf interpolants for the dynamics model
function prepare_models_part2

load 'proba_2D.mat'

num_dim = length(size(Proba_XY));
dims = size(Proba_XY);
Nx = dims(1);

%% compute proba Y conditional on X
Proba_X = Proba_XY;
for i=2:num_dim
    Proba_X = sum(Proba_X,i);
end

dims_rep = dims;
dims_rep(1) = 1;
rep = repmat(Proba_X,dims_rep);

Proba_Y_knowing_X = Proba_XY ./ rep;

str = 'griddedInterpolant(';
for i=1:num_dim
    str = [str sprintf('X_%d,',i)];
end
str = [str 'Proba_Y_knowing_X);'];
interpolant_XY = eval(str);

%% compute the marginals for display

for i=2:num_dim
    tmp = Proba_Y_knowing_X;
    for j=2:num_dim
        if j == i
            continue
        end
        tmp = sum(tmp,j);
    end
    P_Yi_knowing_X(:,:,i-1) = rot90(squeeze(tmp));
end

%% compute proba Y
Proba_Y = squeeze(sum(Proba_XY,1));

args = {};
for i=2:num_dim
    tmp = eval(sprintf('X_%d',i));
    
    str = 'tmp(1,';
    for j=2:i-1
        str = [str '1,'];
    end
    str = [str ':'];
    for j=i+1:num_dim
        str = [str ',1'];
    end
    str = [str ');'];
    
    tmp = eval(str);
    
    args{i-1} = squeeze(tmp);
end
interpolant_Y = griddedInterpolant(args, Proba_Y);

%% save
save('interpolants_2D.mat','interpolant_XY','interpolant_Y','P_Yi_knowing_X');

end