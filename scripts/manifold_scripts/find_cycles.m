% training_data: manifold coordinates of the concatenated training sequences
% T: corresponding time of frames
function [X_training, Y_training, indexes_training, nb_cycles] = find_cycles(training_data, T)
N = length(T);

list_t0 = [];
list_first_frame = [];
list_last_frame = [];

X_training = [];
Y_training = [];
indexes_training = [];

nb_cycles = 0;
nb_sequences = 0;

ta = T(1);
ya = training_data(1,1);

for i=2:N-1
    tb = T(i);
    yb = training_data(i,1);
    
    if tb < ta % new sequence -> save current sequence and start analysing new one
        [X_training, Y_training, indexes_training, nb_cycles] = save_cycles_of_sequence(list_first_frame, list_last_frame, list_t0, X_training, Y_training, indexes_training, T, training_data, nb_cycles);
        
        list_t0 = [];
        list_first_frame = [];
        list_last_frame = [];
        
        ta = tb;
        ya = yb;
        
        nb_sequences = nb_sequences + 1;
        
        continue
    end
    
    if ya > 0 && yb < 0 && training_data(i+1,1) < 0
        t0 = ta - ya * (tb - ta) / (yb - ya);
        list_t0 = [list_t0; t0];
        if size(list_first_frame) > 0
            list_last_frame = [list_last_frame; i-1];
        end
        list_first_frame = [list_first_frame; i];
    end
    
    ta = tb;
    ya = yb;
end

nb_sequences = nb_sequences + 1
[X_training, Y_training, indexes_training, nb_cycles] = save_cycles_of_sequence(list_first_frame, list_last_frame, list_t0, X_training, Y_training, indexes_training, T, training_data, nb_cycles);

nb_cycles
size(indexes_training)

end


function [X_training, Y_training, indexes_training, nb_cycles] = save_cycles_of_sequence(list_first_frame, list_last_frame, list_t0, X_training, Y_training, indexes_training, T, Y, nb_cycles)
    Nty0 = size(list_t0,1);
    
    % find sequences
    for i = 1:Nty0-1
        frame1 = list_first_frame(i);
        frame2 = list_last_frame(i);
        X_training = [X_training; (T(frame1:frame2) - list_t0(i)) / (list_t0(i+1) - list_t0(i))];
        Y_training = [Y_training; Y(frame1:frame2,:)];
        indexes_training = [indexes_training; (frame1:frame2)'];
        nb_cycles = nb_cycles + 1;
        
        figure(10)
        plot(T(frame1:frame2),Y(frame1:frame2,1))
        figure(11)
        plot(T(frame1:frame2),Y(frame1:frame2,2))
    end
    
    
end