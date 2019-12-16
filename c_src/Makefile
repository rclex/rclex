CC		:= gcc
LD	:= ld
TARGET  := ../rclex.so
OBJDIR	:= ./obj
ROSDIR := /opt/ros/dashing

SRCDIR	:= ./src
SOURCES := $(shell ls $(SRCDIR)/*.c)
CFLAGS	:= -O3 -c -fPIC -MMD -MP	#MMD...オブジェクトの依存関係としてdファイルを出力する
SOFLAGS  := -shared
# -c でオブジェクトだけ全部作って，-fpic -sharedすることで一つの.soにできる
LINK 	:= -lstdc++
INCLUDE := -I /usr/lib/erlang/erts-10.5.6/include -I $(ROSDIR)/include
LDFLAGS	:= -L $(ROSDIR)/lib
LIBS 	:= -lrcl -lrmw -lrcutils -lfastrtps
MSGLIBS	:= -lrcl -lrmw -lrcutils -lfastrtps -lrosidl_generator_c -lrosidl_typesupport_c -lstd_msgs__rosidl_generator_c -lstd_msgs__rosidl_typesupport_c -lrosidl_typesupport_introspection_c
OBJECTS :=$(subst $(SRCDIR),$(OBJDIR), $(SOURCES:.c=.o))
DEPENDS = $(OBJECTS:.o=.d)

all:$(TARGET)

$(TARGET): $(OBJECTS) msg_int16_nif.o int16__functions.o int16__type_support.o
	$(CC) -O3 $(SOFLAGS) -o $@ $^ $(LDFLAGS) $(MSGLIBS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@[ -d $(OBJDIR) ]
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ -c $<

msg_int16_nif.o: $(SRCDIR)/msg/msg_int16_nif.c 
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $<  $(MSGLIBS)

int16__functions.o: /opt/ros/dashing/include/std_msgs/msg/int16__functions.c
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $<  $(MSGLIBS)

int16__type_support.o: /opt/ros/dashing/include/std_msgs/msg/int16__type_support.c
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $<  $(MSGLIBS)


.PHONY: all clean
clean:
	rm -f $(OBJDIR)/*.o $(OBJDIR)/*.d ../rclex.so

-include $(DEPENDS)