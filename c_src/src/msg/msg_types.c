#include "../../include/msg/msg_types.h"


//以下のマクロで任意の型のtype_support,init,destory関数を生成する
GET_MSG_TYPE_SUPPORT(std_msgs,msg,Int16)
//get_message_type_from_std_msgs_msg_Int16()
CREATE_MSG_INIT(std_msgs,msg,Int16)
//init_std_msgs_msg_int16 ()
CREATE_MSG_DESTROY(std_msgs,msg,Int16)
//destroy_std_msgs_msg_int16
