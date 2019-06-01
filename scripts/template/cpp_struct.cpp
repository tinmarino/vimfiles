#ifdef __cplusplus
#include <string>
#endif

#ifndef __cplusplus
typedef
#endif
struct MyStruct
{
	int		num_arg;
#ifndef __cplusplus
	char*	arg_0;
#else
	std::string	arg_0;
#endif

}
#ifndef __cplusplus
MyStruct
#endif
;
