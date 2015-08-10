import numpy as np
import matplotlib.pyplot as plt
#%matplotlib inline

# Make sure that caffe is on the python path:
caffe_root = '/home/sphere/gait_cnn/Caffe/caffe/'  # this file is expected to be in {caffe_root}/examples
import sys
sys.path.insert(0, caffe_root + 'python')

import caffe

plt.rcParams['figure.figsize'] = (10, 10)
plt.rcParams['image.interpolation'] = 'nearest'
plt.rcParams['image.cmap'] = 'gray'

import os


# take an array of shape (n, height, width) or (n, height, width, channels)
# and visualize each (height, width) thing in a grid of size approx. sqrt(n) by sqrt(n)
def vis_square(data, padsize=1, padval=0):
    data -= data.min()
    data /= data.max()
    
    # force the number of filters to be square
    n = int(np.ceil(np.sqrt(data.shape[0])))
    padding = ((0, n ** 2 - data.shape[0]), (0, padsize), (0, padsize)) + ((0, 0),) * (data.ndim - 3)
    data = np.pad(data, padding, mode='constant', constant_values=(padval, padval))
    
    # tile the filters into an image
    data = data.reshape((n, n) + data.shape[1:]).transpose((0, 2, 1, 3) + tuple(range(4, data.ndim + 1)))
    data = data.reshape((n * data.shape[1], n * data.shape[3]) + data.shape[4:])
    
    plt.imshow(data)
    plt.show()


print'1'
caffe.set_mode_cpu()
print'2'
net = caffe.Net('/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjustBiases/train_valTest.prototxt',
                '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjustBiases/caffe_alexnet_train_iter_200000.caffemodel',
                caffe.TEST)
print'3'
# input preprocessing: 'data' is the name of the input blob == net.inputs[0]
transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
transformer.set_transpose('data', (2,0,1))
#transformer.set_mean('data', np.load(caffe_root + 'python/caffe/imagenet/ilsvrc_2012_mean.npy').mean(1).mean(1)) # mean pixel
#transformer.set_raw_scale('data', 255)  # the reference model operates on images in [0,255] range instead of [0,1]
#transformer.set_channel_swap('data', (2,1,0))  # the reference model has channels in BGR order instead of RGB

#net.blobs['data'].reshape(1,3,227,227)
#net.blobs['data'].data[...] = transformer.preprocess('data', caffe.io.load_image('/home/sphere/gait_cnn/datasets/staircase/video_training/Subject1_Normal1/meanBG2273chan/depth_335.png'))

out = net.forward()
print(out)
#print("outpis #{}.".format(out['loss'].argmax()))

print('blob sizes:')
print([(k, v.data.shape) for k, v in net.blobs.items()])

print('filter sizes:')
print([(k, v[0].data.shape) for k, v in net.params.items()])


#plt.imshow(transformer.deprocess('data', net.blobs['data'].data[0]))
#plt.imshow(np.transpose(np.squeeze(net.blobs['data'].data)))
#plt.show()

labelsx = []
labelsy = []
labelsz = []	
predictionsx = []
predictionsy = []
predictionsz = []
losses = []
i=0
frameNumber=[]


while(i<200):
	out = net.forward()
	print(out)
	#plt.imshow(np.transpose(np.squeeze(net.blobs['data'].data)))
	#plt.show()	
	print("output:")
	print(net.blobs['fc8'].data) # or whatever you want
	print("label:")
	print(net.blobs['label'].data)
	print("loss:")
	print(net.blobs['loss'].data)
	#if(net.blobs['loss'].data<0.0005):
	#	img = np.transpose(np.squeeze(net.blobs['data'].data))
	#	plt.imshow(img)	
	#	plt.show()
	#if(float(net.blobs['loss'].data)<0.2):
	labelsx.append(net.blobs['label'].data.item(0))
	labelsy.append(net.blobs['label'].data.item(1))
	labelsz.append(net.blobs['label'].data.item(2))
	predictionsx.append(net.blobs['fc8'].data.item(0))
	predictionsy.append(net.blobs['fc8'].data.item(1))
	predictionsz.append(net.blobs['fc8'].data.item(2))
	frameNumber.append(i)
	losses.append(float(net.blobs['loss'].data))
	i=i+1

plt.plot(frameNumber,predictionsx)
plt.ylabel('networkOutput[0]',fontsize=12)
plt.yticks(fontsize=10)
plt.xlabel('frame number',fontsize=12)
plt.xticks(fontsize=10)
plt.show()
