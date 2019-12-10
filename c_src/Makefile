CC		:= gcc
TARGET  := ../rclex.so
OBJ		:= ./obj
ROOTDIR := /opt/ros/dashing
RCLDIR	:= ..

SRCDIR	:= ./nif_src
CFLAGS	:= -O3 -c -fPIC
SOFLAGS  := -shared
# -c でオブジェクトだけ全部作って，-fpic -sharedすることで一つの.soにできる
LINK 	:= -lstdc++
INCLUDE := -I /usr/lib/erlang/erts-10.5.6/include -I $(ROOTDIR)/include
LDFLAGS	:= -L $(ROOTDIR)/lib
LIBS 	:= -lrcl -lrmw -lrcutils -lfastrtps
#LIBS	:= -lrcl -lrmw -lrcutils -lfastrtps -lrosidl_generator_c -lrosidl_typesupport_c -lstd_msgs__rosidl_generator_c -lstd_msgs__rosidl_typesupport_c

all:$(TARGET)

$(TARGET):init_nif.o total_nif.o
	$(CC) -O3 $(SOFLAGS) $(LDFLAGS) -o $(TARGET) init_nif.o total_nif.o $(LIBS)

init_nif.o: init_nif.c total_nif.c
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) total_nif.c init_nif.c  $(LIBS)

.PHONY: clean
clean:
	rm -f *.o