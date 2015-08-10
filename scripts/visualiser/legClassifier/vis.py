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



caffe.set_mode_cpu()

net = caffe.Net('/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/train_val.prototxt',
'/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/a_iter_740000.caffemodel',
                caffe.TEST)
"""
blob sizes:
[('data', (1, 1, 128, 256)),
 ('label', (1, 3)),
 ('conv1', (1, 16, 128, 256)),
 ('pool1', (1, 16, 43, 86)),0.38
 ('conv2', (1, 32, 43, 86)),
 ('pool2', (1, 32, 15, 30)),
 ('conv3', (1, 32, 15, 30)),
 ('pool3', (1, 32, 5, 11)),
 ('fc4', (1, 1024)),
 ('fc5', (1, 3)),
 ('loss', ())]

filter sizes:
[('conv1', (16, 1, 11, 11)),
 ('conv2', (32, 16, 11, 11)),
 ('conv3', (32, 32, 7, 7)),
 ('fc4', (1024, 1760)),
 ('fc5', (3, 1024))]


"""
print('blob sizes:')
print([(k, v.data.shape) for k, v in net.blobs.items()])

print('filter sizes:')
print([(k, v[0].data.shape) for k, v in net.params.items()])
i=0;
while(i<=20):
	net.forward()
	i=i+1

out = net.forward()
print("output:")
print(net.blobs['fc2'].data) # or whatever you want
print("label:")
print(net.blobs['label'].data)
print("loss:")
print(net.blobs['loss'].data)

#INPUT:
inputImg = np.transpose(np.squeeze(net.blobs['data'].data))
plt.imshow(inputImg)
plt.show()
#pool1:
im = np.transpose(np.squeeze(net.blobs['pool1'].data))
plt.imshow(im)
plt.show()

#CONV1:
print('conv1:')
#filters: ('conv1', (16, 1, 6, 6))
#print('biases:')
bias = net.params['conv1'][1].data
#print(bias)
#print('filters:')
filters = net.params['conv1'][0].data
#print(filters);
vis_square(np.squeeze(filters.transpose(0, 3, 2, 1)))
#features: ('conv1', (1, 16, 64, 128))
print('features')
feat = np.squeeze(net.blobs['conv1'].data[0])
feat = feat.transpose(0,2,1)
#print(feat)
vis_square(feat, padval=1)



"""
	#FC6:
	print('fc6:')
	#filters: ('fc6', (1024, 16384))
	print('bias:')
	bias = net.params['fc6'][1].data
	print(bias)
	print('filter:')
	filters = net.params['fc6'][0].data
	filters = filters.transpose(1,0)
	filters = np.expand_dims(filters,0)
	vis_square(filters)
	#features: ('pool1', (1, 16384))-->('fc6', (1, 1024))
	print('features')
	plt.plot(net.blobs['pool1'].data[0])
	plt.show()


        print(np.squeeze(filters.transpose(0, 3, 2, 1)).shape)
	vis_square(np.squeeze(filters.transpose(0, 3, 2, 1)))
	#features: ('conv2', (1, 32, 32, 64))
	print('features')
	feat = net.blobs['conv1'].data[0]
	print(np.squeeze(feat.transpose(3,0,1,2)).shape)
	vis_square(np.squeeze(feat.transpose(3,0,1,2)), padval=1)


	filters = net.params['conv2'][0].data
	vis_square(filters.reshape(512, 3, 3))
	print('conv2:')
	#print(filters)

	feat = net.blobs['conv2'].data[0, :36]
	vis_square(feat, padval=1)


	filters = net.params['conv3'][0].data
	print('conv3:')
	#print(filters)

	feat = net.blobs['conv3'].data[0]
	vis_square(feat, padval=0.5)

	filters = net.params['conv4'][0].data
	print('conv4:')
	#print(filters)
	feat = net.blobs['conv4'].data[0]
	vis_square(feat, padval=0.5)


	filters = net.params['conv5'][0].data
	print('conv5:')
	#print(filters)
	feat = net.blobs['conv5'].data[0]
	vis_square(feat, padval=0.5)


	filters = net.params['fc6'][0].data
	print('fc6:')
	#print(filters)

	feat = net.blobs['fc6'].data[0]
	plt.subplot(2, 1, 1)
	plt.plot(feat.flat)
	plt.subplot(2, 1, 2)
	_ = plt.hist(feat.flat[feat.flat > 0], bins=100)




	filters = net.params['fc7'][0].data
	print('fc7:')
	print(filters)

	feat = net.blobs['fc7'].data[0]
	plt.subplot(2, 1, 1)
	plt.plot(feat.flat)
	plt.subplot(2, 1, 2)
	_ = plt.hist(feat.flat[feat.flat > 0], bins=100)


	filters = net.params['new-fc8'][0].data
	print('fc8 filter:')
	print(filters)

	feat = net.blobs['fc8'].data[0]
	print('output feature:')
	print(feat)
	plt.plot(feat.flat)

	plt.show()


	print("output:")
	print(net.blobs['fc8'].data) # or whatever you want
	print("label:")
	print(net.blobs['label'].data)
	print("loss:")
	print(net.blobs['loss'].data)

"""

