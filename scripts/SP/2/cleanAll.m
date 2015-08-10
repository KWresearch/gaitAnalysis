close all
clear all
clc
addpath('/space/data_to_backup/Ben/data');

load('selected_skeletons.mat');
cd('/space/data_to_backup/Ben/data/video_training');
files = cellstr(strsplit(ls())); %careful if command window is wider than 1 file name, order will be wrong
fileOffsets = [102,111,174,171,88,81,141,106,185,321,113,230,134,120,212,140,133];

for i=2:length(files)-1
   disp(files{i})
   cleanSequence(files{i},line_numbers{i}, fileOffsets(i))     
end