python deployNet.py /home/sphere/gait_cnn/Caffe/caffe/gait/datasets/1/video_training/Subject1_Normal1/Subject1_Normal1_quickFill/extractedFG3channelDepth/227x227 \
./output \
--model_def=/home/sphere/gait_cnn/Caffe/caffe/gait/models/2/deploy.prototxt \
--pretrained_model=/home/sphere/gait_cnn/Caffe/caffe/gait/models/2/caffe_alexnet_train_iter_270000.caffemodel \
--gpu \
--mean_file='' \
--ext='png' \
--images_dim='227, 227'
