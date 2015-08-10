
import numpy as np
import os
import sys
import argparse
import glob
import time
import matplotlib.pyplot as plt
import caffe
import math
import matplotlib.cm as cm

from mpl_toolkits.mplot3d import Axes3D

net = caffe.Net('/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/train_valTest.prototxt',
'/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/a_iter_60000.caffemodel',
                caffe.TRAIN)

print('blob sizes:')
print([(k, v.data.shape) for k, v in net.blobs.items()])

print('filter sizes:')
print([(k, v[0].data.shape) for k, v in net.params.items()])

labelsx = []
labelsy = []
labelsz = []	
predictionsx = []
predictionsy = []
predictionsz = []
losses = []
i=0
frameNumber=[]

i=0
while(i<1120):
	net.forward()
	img = np.transpose(np.squeeze(net.blobs['data'].data))
	plt.imshow(img, cmap=cm.Greys_r)	
	plt.show()
	
	print("output:")
	print(net.blobs['fc2'].data) # or whatever you want
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



	frameNumber.append(i)
	losses.append(float(net.blobs['loss'].data))
	i=i+1



