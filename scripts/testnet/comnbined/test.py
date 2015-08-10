
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

net = caffe.Net('/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/combined/2/train_valTest.prototxt','/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/combined/2/withLowLayerTuning_iter_140000.caffemodel',
              
                caffe.TEST)

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
leg0 = []
leg1 = []
losses = []
i=0
frameNumber=[]

i=0
while(i<112):
	net.forward()
	#img = np.transpose(np.squeeze(net.blobs['data'].data))
	#plt.imshow(img, cmap=cm.Greys_r)	
	#plt.show()
	
	print("output:")
	print(net.blobs['final-fc3'].data) # or whatever you want
	print("label:")
	print(net.blobs['label'].data)
	print("loss:")
	print(net.blobs['final-loss'].data)
	#if(net.blobs['loss'].data<0.0005):
	#	img = np.transpose(np.squeeze(net.blobs['data'].data))
	#	plt.imshow(img)	
	#	plt.show()
	#if(float(net.blobs['loss'].data)<0.2):
	labelsx.append(net.blobs['label'].data.item(0))
	labelsy.append(net.blobs['label'].data.item(1))
	labelsz.append(net.blobs['label'].data.item(2))
	leg0.append(net.blobs['detector-fc2'].data.item(0))
	leg1.append(net.blobs['detector-fc2'].data.item(1))
	predictionsx.append(net.blobs['final-fc3'].data.item(0))
	predictionsy.append(net.blobs['final-fc3'].data.item(1))
	predictionsz.append(net.blobs['final-fc3'].data.item(2))
	frameNumber.append(i)
	losses.append(float(net.blobs['final-loss'].data))
	i=i+1
"""
plt.hist(np.array(losses), bins=60)
plt.title('Validation Set Loss Distribution',fontsize=15,horizontalalignment='right')
plt.ylabel('Frequency',fontsize=12)
plt.yticks(fontsize=10)
plt.xlabel('Loss (l2norm)',fontsize=12)
plt.xticks(fontsize=10)
plt.show()

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.plot(predictionsx, predictionsy, predictionsz, 'o',c='r',label='Network Outputs')
ax.plot(labelsx, labelsy, labelsz, '^',c='b',label='Labels')
ax.set_xlabel('X ')
ax.set_ylabel('Y ')
ax.set_zlabel('Z ')
ax.set_title('Validation Set Output Comparison')
plt.show()

plt.legend(loc='upper left', numpoints=1, ncol=1, bbox_to_anchor=(0, 0))
plt.plot(frameNumber,predictionsx)
plt.ylabel('networkOutput[0]',fontsize=12)
plt.yticks(fontsize=10)
plt.xlabel('frame number',fontsize=12)
plt.xticks(fontsize=10)
plt.show()
"""



plt.figure(1)
plt.subplot(711)
plt.plot(frameNumber, leg0, 'bo', frameNumber, leg1, 'k')
plt.ylabel('LR leg score',fontsize=12)
plt.yticks(fontsize=10)
plt.xlabel('frame number',fontsize=12)
plt.xticks(fontsize=10)


plt.subplot(712)
plt.plot(frameNumber, predictionsx, 'r--')

plt.subplot(713)
plt.plot(frameNumber, predictionsy, 'r--')

plt.subplot(714)
plt.plot(frameNumber, predictionsz, 'r--')

plt.subplot(715)
plt.plot(frameNumber, labelsx, 'r--')

plt.subplot(716)
plt.plot(frameNumber, labelsy, 'r--')

plt.subplot(717)
plt.plot(frameNumber, labelsz, 'r--')
plt.show()


for item in thelist:
  print>>thefile, item


