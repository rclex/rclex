CC		:= gcc
LD	:= ld
TARGET  := ../rclex.so
OBJ		:= ./obj
ROOTDIR := /opt/ros/dashing
RCLDIR	:= ..

SRCDIR	:= ./src
CFLAGS	:= -O3 -c -fPIC
SOFLAGS  := -shared
# -c でオブジェクトだけ全部作って，-fpic -sharedすることで一つの.soにできる
LINK 	:= -lstdc++
INCLUDE := -I /usr/lib/erlang/erts-10.5.6/include -I $(ROOTDIR)/include
LDFLAGS	:= -L $(ROOTDIR)/lib
LIBS 	:= -lrcl -lrmw -lrcutils -lfastrtps
MSGLIBS	:= -lrcl -lrmw -lrcutils -lfastrtps -lrosidl_generator_c -lrosidl_typesupport_c -lstd_msgs__rosidl_generator_c -lstd_msgs__rosidl_typesupport_c

all:$(TARGET)

$(TARGET):init_nif.o node_nif.o publisher_nif.o msg_int16_nif.o total_nif.o int16__functions.o
	$(LD) -O3 $(SOFLAGS) $(LDFLAGS) -o $(TARGET) init_nif.o node_nif.o publisher_nif.o msg_int16_nif.o int16__functions.o total_nif.o $(LIBS)

init_nif.o: $(SRCDIR)/init_nif.c 
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $<  $(LIBS)

node_nif.o: $(SRCDIR)/node_nif.c 
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $<  $(LIBS)

publisher_nif.o: $(SRCDIR)/publisher_nif.c 
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $<  $(LIBS)

msg_int16_nif.o: $(SRCDIR)/msg/msg_int16_nif.c 
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $<  $(MSGLIBS)

int16__functions.o: /opt/ros/dashing/include/std_msgs/msg/int16__functions.c
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $<  $(MSGLIBS)

total_nif.o: $(SRCDIR)/total_nif.c
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $< $(LIBS)
.PHONY: clean
clean:
	rm -f *.o