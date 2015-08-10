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

from mpl_toolkits.mplot3d import Axes3D

labels={}
f = open('/home/sphere/gait_cnn/Caffe/caffe/gait/datasets/1/staircaseData.txt')
for line in f.readlines(): 
    values = line.split(' ')
    imgNumberStart = values[0].find('depth_')
    imageNumber = values[0][imgNumberStart:imgNumberStart+9]
    #print values
    label = []
    label.append(values[1])
    label.append(values[2])
    label.append(values[3])
#    print(label)
  #  labels.append(label)
    labels[imageNumber]=label
print(labels)
f.close()
