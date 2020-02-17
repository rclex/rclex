CC		:= gcc
LD	:= ld
TARGET  := ../rclex.so
OBJDIR	:= ./obj
ROSDIR := /opt/ros/dashing

SRCDIR	:= ./src
SOURCES := $(shell ls $(SRCDIR)/*.c)
CFLAGS	:= -g -c -fPIC -MMD -MP
#MMD...オブジェクトの依存関係としてdファイルを出力する
SOFLAGS  := -g -shared
# -c でオブジェクトだけ全部作って，-fpic -sharedすることで一つの.soにできる
LINK 	:= -lstdc++
#INCLUDE := -I /usr/lib/erlang/erts-10.6.4/include -I $(ROSDIR)/include
INCLUDE := -I $(ROSDIR)/include
INCLUDE += -I$(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
LDFLAGS	:= -L $(ROSDIR)/lib

MSGLIBS	:= -lrcl -lrmw -lrcutils -lrosidl_generator_c -lrosidl_typesupport_c -lstd_msgs__rosidl_generator_c -lstd_msgs__rosidl_typesupport_c -lrosidl_typesupport_introspection_c  \
						-lfastcdr -lrmw_opensplice_cpp -lrosidl_typesupport_opensplice_cpp -lfastrtps -lrmw_fastrtps_cpp
OBJECTS :=$(subst $(SRCDIR),$(OBJDIR), $(SOURCES:.c=.o))
DEPENDS = $(OBJECTS:.o=.d)

all:$(TARGET)

#$(TARGET): $(OBJECTS) msg_int16_nif.o int16__functions.o int16__type_support.o
#	$(CC) $(SOFLAGS) -o $@ $^ $(LDFLAGS) $(MSGLIBS)

$(TARGET): $(OBJECTS) msg_int16_nif.o msg_string_nif.o
	$(CC) $(SOFLAGS) -o $@ $^ $(LDFLAGS) $(MSGLIBS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@[ -d $(OBJDIR) ]
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ -c $<
	
msg_int16_nif.o: $(SRCDIR)/msg/msg_int16_nif.c 
	$(CC) $(CFLAGS) $(INCLUDE) $< 
msg_string_nif.o: $(SRCDIR)/msg/msg_string_nif.c
	$(CC) $(CFLAGS) $(INCLUDE) $<
#int16__functions.o: /opt/ros/dashing/include/std_msgs/msg/int16__functions.c
#	$(CC) $(CFLAGS) $(INCLUDE) $< 

#int16__type_support.o: /opt/ros/dashing/include/std_msgs/msg/int16__type_support.c
#	$(CC) $(CFLAGS) $(INCLUDE) $< 


.PHONY: all clean
clean:
	rm -f ./*.o ./*.d $(OBJDIR)/*.o $(OBJDIR)/*.d ../rclex.so

-include $(DEPENDS)