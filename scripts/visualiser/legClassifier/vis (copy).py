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

net = caffe.Net('/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/test.prototxt',
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

out = net.forward()


#INPUT:
inputImg = np.transpose(np.squeeze(net.blobs['data'].data))
plt.imshow(inputImg)
plt.show()
#pool1:
im = np.transpose(np.squeeze(net.blobs['pool1'].data))
plt.imshow(im)
plt.show()



