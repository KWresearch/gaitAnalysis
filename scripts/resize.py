 #-*- coding: utf-8 -*-
import PIL
from PIL import Image
basewidth = 300
img=Image.open('Subject1_Normal1/Subject1_Normal1_quickFill/extractedFG3channelDepth/depth_173.png')
img = img.resize((227,227), PIL.Image.ANTIALIAS)
 img.save('./S1N1_depth_173_227x227.jpg')
