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

net = caffe.Net('/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjusted_IMG/withoutMeanSub/train_valTest.prototxt','/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjusted_IMG/withoutMeanSub/a_iter_200000.caffemodel',
              
                caffe.TEST)

# input preprocessing: 'data' is the name of the input blob == net.inputs[0]
transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
transformer.set_transpose('data', (2,0,1))
#transformer.set_mean('data', np.load(caffe_root + 'python/caffe/imagenet/ilsvrc_2012_mean.npy').mean(1).mean(1)) # mean pixel
#transformer.set_raw_scale('data', 255)  # the reference model operates on images in [0,255] range instead of [0,1]
#transformer.set_channel_swap('data', (2,1,0))  # the reference model has channels in BGR order instead of RGB

#net.blobs['data'].reshape(1,3,227,227)
#net.blobs['data'].data[...] = transformer.preprocess('data', caffe.io.load_image('/home/sphere/gait_cnn/datasets/staircase/video_training/Subject1_Normal1/meanBG2273chan/depth_335.png'))

"""
blob sizes:
[('data', (1, 1, 227, 227)),
 ('label', (1, 3)),
 ('data_data_0_split_0', (1, 1, 227, 227)), 
('data_data_0_split_1', (1, 1, 227, 227)),
 ('data_data_0_split_2', (1, 1, 227, 227)),
 ('out', (1, 3, 227, 227)), 
('conv1', (1, 96, 55, 55)),
 ('norm1', (1, 96, 55, 55)),
 ('pool1', (1, 96, 27, 27)),
 ('conv2', (1, 256, 27, 27)),
 ('norm2', (1, 256, 27, 27)),
 ('pool2', (1, 256, 13, 13)), 
('conv3', (1, 384, 13, 13)), 
('conv4', (1, 384, 13, 13)),
 ('conv5', (1, 256, 13, 13)),
 ('pool5', (1, 256, 6, 6)),
 ('fc6', (1, 4096)),
 ('fc7', (1, 4096)),
 ('fc8', (1, 3)),
 ('loss', ())]

filter sizes:
[('conv1', (96, 3, 11, 11)),
 ('conv2', (256, 48, 5, 5)),
 ('conv3', (384, 256, 3, 3)),
 ('conv4', (384, 192, 3, 3)),
 ('conv5', (256, 192, 3, 3)),
 ('fc6', (4096, 9216)),
 ('fc7', (4096, 4096)),
 ('new-fc8', (3, 4096))]


"""
print('blob sizes:')
print([(k, v.data.shape) for k, v in net.blobs.items()])

print('filter sizes:')
print([(k, v[0].data.shape) for k, v in net.params.items()])
i=0
#for i in range(0,38):
	#net.forward()

while(1):
	out = net.forward()
	print(out)
	#print("outpis #{}.".format(out['loss'].argmax()))



	#plt.imshow(transformer.deprocess('data', net.blobs['data'].data[0]))
	plt.imshow(np.transpose(np.squeeze(net.blobs['data'].data)))
	#plt.imshow(np.squeeze(net.blobs['data'].data))
	plt.show()

	# the parameters are a list of [weights, biases]
	filters = net.params['conv1'][0].data
        print(np.squeeze(filters.transpose(0, 2, 3, 1)).shape)
	vis_square(np.squeeze(filters.transpose(0, 2, 3, 1)))
	print('conv1:')
	#print(filters)

	feat = net.blobs['conv1'].data[0]
	vis_square(feat, padval=1)


	filters = net.params['conv2'][0].data
	vis_square(filters[:48].reshape(48**2, 5, 5))
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

