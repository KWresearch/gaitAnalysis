#!/usr/bin/env python
"""
classify.py is an out-of-the-box image classifer callable from the command line.

By default it configures and runs the Caffe reference ImageNet model.
"""
import numpy as np
import os
import sys
import argparse
import glob
import time
import matplotlib.pyplot as plt
import caffe
import math

from mpl_toolkits.mplot3d import Axes3D
def l2Norm(v1,v2):
	s=0
	i=0		
	#print(type(v1))
	for v2i in v2:
		v1i = v1.item(i)
		i=i+1
		#print(type(v1i))
		#print(v1i)
		#print(type(v2i))
		#print( v2i)
		s=s+pow(float(v1i)-float(v2i),2)
	return 0.5*math.sqrt(s)
	
def main(argv):
	pycaffe_dir = os.path.dirname(__file__)

	parser = argparse.ArgumentParser()
	# Required arguments: 
	parser.add_argument(
		"input_file",
		help="Input image, directory, or npy."
	)
	parser.add_argument(
		"output_file",
		help="Output npy filename."
	)
	# Optional arguments.
	parser.add_argument(
		"--model_def",
		default=os.path.join(pycaffe_dir,
		        "../models/bvlc_reference_caffenet/deploy.prototxt"),
		help="Model definition file."
	)
	parser.add_argument(
		"--pretrained_model",
		default=os.path.join(pycaffe_dir,
		        "../models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel"),
		help="Trained model weights file."
	)
	parser.add_argument(
		"--gpu",
		action='store_true',
		help="Switch for gpu computation."
	)
	parser.add_argument(
		"--center_only",
		action='store_true',
		help="Switch for prediction from center crop alone instead of " +
		     "averaging predictions across crops (default)."
	)
	parser.add_argument(
		"--images_dim",
		default='256,256',
		help="Canonical 'height,width' dimensions of input images."
	)
	parser.add_argument(
		"--mean_file",
		default=os.path.join(pycaffe_dir,
		                     'caffe/imagenet/ilsvrc_2012_mean.npy'),
		help="Data set image mean of [Channels x Height x Width] dimensions " +
		     "(numpy array). Set to '' for no mean subtraction."
	)
	parser.add_argument(
		"--input_scale",
		type=float,
		help="Multiply input features by this scale to finish preprocessing."
	)
	parser.add_argument(
		"--raw_scale",
		type=float,
		default=255.0,
		help="Multiply raw input by this scale before preprocessing."
	)
	parser.add_argument(
		"--channel_swap",
		default='2,1,0',
		help="Order to permute input channels. The default converts " +
		     "RGB -> BGR since BGR is the Caffe default by way of OpenCV."
	)
	parser.add_argument(
		"--ext",
		default='jpg',
		help="Image file extension to take as input when a directory " +
		     "is given as the input file."
	)
	args = parser.parse_args()

	image_dims = [int(s) for s in args.images_dim.split(',')]

	mean, channel_swap = None, None
	if args.mean_file:
		mean = np.load(args.mean_file)
	if args.channel_swap:
		channel_swap = [int(s) for s in args.channel_swap.split(',')]

	if args.gpu:
		caffe.set_mode_gpu()
		print("GPU mode")
	else:
		caffe.set_mode_cpu()
		print("CPU mode")

	# Make classifier.
	net = caffe.Classifier(args.model_def, args.pretrained_model,
		    image_dims=image_dims, mean=mean,
		    input_scale=args.input_scale, raw_scale=args.raw_scale,
		    channel_swap=channel_swap)
	fileNames = []
	inputs=[]
	# Load numpy array (.npy), directory glob (*.jpg), or image file.
	args.input_file = os.path.expanduser(args.input_file)
	if args.input_file.endswith('npy'):
		print("Loading file: %s" % args.input_file)
		inputs = np.load(args.input_file)
	elif os.path.isdir(args.input_file):
		print("Loading folder: %s" % args.input_file)
		#inputs =[caffe.io.load_image(im_f)
				# for im_f in glob.glob(args.input_file + '/*.' + args.ext)]
		for im_f in glob.glob(args.input_file + '/*.' + args.ext):
			#print(im_f)
			fileNames.append(im_f)
			inputs.append(caffe.io.load_image(im_f))
	
	else:
		print("Loading file: %s" % args.input_file)
		inputs = [caffe.io.load_image(args.input_file)]
	#print(fileNames)

	#loadLabels:
	labels={}
	f = open('/home/sphere/gait_cnn/Caffe/caffe/gait/datasets/1/staircaseData.txt')
	for line in f.readlines(): 
		#print(line)
		values = line.split(' ')
		if values[0].find('Subject1_Normal1') == -1:
			break
		imgNumberStart = values[0].find('depth_')
		imageNumber = values[0][imgNumberStart:imgNumberStart+9]
		#print values
		label = []
		label.append(float(values[1]))
		label.append(float(values[2]))
		label.append(float(values[3]))
		#    print(label)
		#  labels.append(label)
		labels[imageNumber]=label
	#print(labels)
	f.close()    

	print("Classifying %d inputs." % len(inputs))
	predictions = {}
	labelsx = []
	labelsy = []
	labelsz = []
	predictionsx = []
	predictionsy = []
	predictionsz = []
	losses = []
	# Classify.
	for img,filename in zip(inputs,fileNames):
		imgNumberStart = filename.find('depth_')
		imageName = filename[imgNumberStart:imgNumberStart+9]
		plt.imshow(img)
		plt.show()
		input1=[]
		input1.append(img)

		prediction = net.predict(input1)
		predictions[imageName]=prediction
	

		np.set_printoptions(precision=5)  
		print('image:')
		print(imageName) 
		print('label:')
		print(labels[imageName])    
		print('net output:')
		print(prediction)
		print('loss:')
		print(l2Norm(prediction,labels[imageName]))

		print('\n\n')
		labelsx.append(labels[imageName][0])
		labelsy.append(labels[imageName][1])
		labelsz.append(labels[imageName][2])
		predictionsx.append(prediction.item(0))
		predictionsy.append(prediction.item(1))
		predictionsz.append(prediction.item(2))
		losses.append(l2Norm(prediction,labels[imageName]))
	plt.hist(np.array(losses), bins=40)
	
	fig = plt.figure()
	ax = fig.add_subplot(111, projection='3d')
	print(type(predictions.values()[0]))
	print(type(labels.values()[0]))
	print(predictions.values()[0])
	print(labels.values()[0])
   # print()) 
   # print(labels.values())
	ax.scatter(predictionsx, predictionsy, predictionsz, c='r', marker='o')
	ax.scatter(labelsx, labelsy, labelsz, c='b', marker='^')
	ax.set_xlabel('X ')
	ax.set_ylabel('Y ')
	ax.set_zlabel('Z ')

	plt.show()
	# Save
    
    #print("Saving results into %s" % args.output_file)
   # np.save(args.output_file, predictions)


if __name__ == '__main__':
    main(sys.argv)
