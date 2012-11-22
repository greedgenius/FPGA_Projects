#if defined(WIN32)
	// Include Windows specific headers here.
	#include <windows.h>
#else
	// Include Unix specific headers here.
#endif

#include <stdio.h>
#include "dpcdecl.h"
#include "dmgr.h"
#include "depp.h"

#define TESTADDR		0x72
#define TESTBYTE		0x143

int main(int argc, char ** argv)
{
	HIF deviceHandle;
	int status = fTrue;
	char deviceName[32] = "Basys2";
	unsigned char result;

	if (DmgrOpen(&deviceHandle,deviceName)) printf("Successfully opened a handle to %s\n", deviceName);
	else printf("Error code: %d\n", DmgrGetLastError());

	if (DeppEnable(deviceHandle)) printf("Successfully enabled Port 0\n");
	else printf("Error code: %d\n", DmgrGetLastError());


	DeppPutReg(deviceHandle, TESTADDR, 0x8A , fFalse);
	DeppGetReg(deviceHandle, TESTADDR, &result  , fFalse);

	printf("put = 0x%02X, get = 0x%02X\n", 0x8A, result);


	
	if (DeppDisable(deviceHandle)) printf("Successfully disabled DEPP port\n");
	else printf("Error code: %d\n", DmgrGetLastError());

	if (DmgrClose(deviceHandle)) printf("Successfully closed device handle\n");
	else printf("Error code: %d\n", DmgrGetLastError());

}
