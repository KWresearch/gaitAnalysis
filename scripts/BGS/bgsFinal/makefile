CC=g++

CFLAGS=-I/space/data_to_backup/Libraries/opencv-2.4.11/include

LDFLAGS=-L/space/data_to_backup/Libraries/opencv-2.4.11/lib -lopencv_core -lopencv_imgproc -lopencv_features2d -lopencv_flann -lopencv_contrib -lopencv_calib3d -lopencv_gpu -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_video -lopencv_highgui

EXEC=gaitBGS

all: 
	g++ bgs.cpp ./package_bgs/dp/*.cpp  -o bgs -I/space/data_to_backup/Libraries/opencv-2.4.11/include -L/space/data_to_backup/Libraries/opencv-2.4.11/lib -lopencv_core -lopencv_imgproc -lopencv_features2d -lopencv_flann -lopencv_contrib -lopencv_calib3d -lopencv_gpu -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_video -lopencv_highgui


gaitBGS: gaitBGS.o
	$(CC) -o gaitBGS gaitBGS.o /space/data_to_backup/Ben/bgslibrary/package_bgs/FrameDifferenceBGS.cpp $(LDFLAGS)

gaitBGS.o: gaitBGS.cpp
	$(CC) -o gaitBGS.o -c gaitBGS.cpp /space/data_to_backup/Ben/bgslibrary/package_bgs/FrameDifferenceBGS.cpp $(CFLAGS)

clean:
	rm -rf *.o

mrproper: clean
	rm -rf $(EXEC)

