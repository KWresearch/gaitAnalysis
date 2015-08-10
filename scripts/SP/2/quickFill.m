function[filled_img] = quickFill(img) 
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/MinMaxFilterFolder');
while 1
    bad_apples = find(img < 10);
    if isempty(bad_apples)
        break;
    end
    img_ =  minmaxfilt(img,5, 'max', 'same');
    img(bad_apples) = img_(bad_apples);
end
filled_img = img;
end


