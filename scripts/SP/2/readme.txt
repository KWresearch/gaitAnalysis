This dataset contains sequences of skeletons (tracked by the OpenNI SDK) of people walking up stairs.
It does not contain the RGB and depth images. A complete dataset that include both images and skeleton data will be released at www.irc-sphere.ac.uk/work-package-2/movement-quality .

This data have been acquired for the experiments in:
A. Paiement, L. Tao, M. Camplani, S. Hannuna, D. Damen, M. Mirmehdi, Online quality assessment of human movement from skeleton data, in Proceedings of BMVC 2014.
When using it, please cite this article and the Sphere project: http://www.irc-sphere.ac.uk/ .

*------------------------------------------------------------------------------*
*Structure of folders*

./training_data: contains the data used to create the manifold and the statistical models in the BMVC paper

./training_data/full_sequences: full sequences. Each file contains one sequence.
./training_data/training_frames_for_BMVC_paper: selected frames used for training in the BMVC paper. Some frames at the beginning and end of the sequences in ./training_data/full_sequences have been discarded due to the failure of the skeleton tracker.
	'frames_manifold.xlsx': specifies which frames of the original sequences are retained for building the manifold.
	'skeleton_data_manifold.mat': contains the 15 joint positions of the skeleton (45 coordinates in total) for all the frames used for building the manifold. Columns order is the same than in the raw text files (see below).
	'frames_gait_cycles.xlsx': specifies the frame numbers of the identified cycles that are used to build the statistical models.
	'skeleton_stage_gait_cycles.mat': contains the 15 joint positions of all the frames of the identified cycles, together with their estimated movement stage x.

./testing_data: full sequences used for testing

*------------------------------------------------------------------------------*
*Sequence files*

The files containing full sequences are named
Subject[x]_[gait_type].txt

Possible values for [gait_type]:
Normal
RL: right leg lead (i.e. right leg always step first)
LL: left leg lead (i.e. left leg always steps first)
StopX1: subject freezes once during the sequence
StopX2: subject freezes twice during the sequence


These files contain the 15 OpenNI joints, with x,y,z coordinates for each joint.
Each line contains one frame, in the following format:
[frame number] [JOINT_HEAD] [JOINT_NECK] [JOINT_LEFT_SHOULDER] [JOINT_RIGHT_SHOULDER] [JOINT_LEFT_ELBOW] [JOINT_RIGHT_ELBOW] [JOINT_LEFT_HAND] [JOINT_RIGHT_HAND] [JOINT_TORSO] [JOINT_LEFT_HIP] [JOINT_RIGHT_HIP] [JOINT_LEFT_KNEE] [JOINT_RIGHT_KNEE] [JOINT_LEFT_FOOT] [JOINT_RIGHT_FOOT]

The format of JOINT_X is:
[flag (can be ignored)] [x] [y] [z]

*------------------------------------------------------------------------------*
*Ground-truth detections of abnormal events*

The file ./groundtruth_detections_of_abnormal_events.xlsx contains the frame numbers of abnormal events (RL, LL and StopXx) manually annotated by a physiotherapist.
