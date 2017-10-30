#include <cutils/properties.h>


extern int __system_properties_init(void);
void __attribute__((constructor)) at_sys_init(void)
{
	__system_properties_init();
//	printf("__system_properties_init=%d\n",res);
}
