#if defined(WIN32)

	/* Include Windows specific headers here.
	*/
	#include <windows.h>

#else

	/* Include Unix specific headers here.
	*/

#endif

#include <stdio.h>
#include "dpcdecl.h"
#include "dmgr.h"
#include "depp.h"

#define OP1ADDR		0x00
#define OP2ADDR		0x01
#define RESADDR		0x00

int main()
{
	HIF deviceHandle;
	int status = fTrue;
	char deviceName[32] = "Basys2";
	unsigned char result;

	//Open a handle to the device
	status = DmgrOpen(&deviceHandle,deviceName);
	if (status)
		printf("Successfully opened a handle to %s\n", deviceName);
	else
	{
		status = DmgrGetLastError();
		printf("Error code: %d\n", status);
	}

	//Enable the default port (Port 0) on the device
	status = DeppEnable(deviceHandle);
	if (status)
		printf("Successfully enabled Port 0\n");
	else
	{
		status = DmgrGetLastError();
		printf("Error code: %d\n", status);
	}

	//Do some math
		if(!DeppPutReg(deviceHandle, OP1ADDR, 0x00, fFalse)) {
		printf("DeppPutReg failed\n");
	}
	DeppPutReg(deviceHandle, OP2ADDR, 0x00, fFalse);
	DeppGetReg(deviceHandle, RESADDR, &result, fFalse);

	printf("0x00 + 0x00 = 0x%02X\n", result);

	DeppPutReg(deviceHandle, OP1ADDR, 0x01, fFalse);
	DeppPutReg(deviceHandle, OP2ADDR, 0x00, fFalse);
	DeppGetReg(deviceHandle, RESADDR, &result, fFalse);

	printf("0x01 + 0x00 = 0x%02X\n", result);

	DeppPutReg(deviceHandle, OP1ADDR, 0x01, fFalse);
	DeppPutReg(deviceHandle, OP2ADDR, 0x01, fFalse);
	DeppGetReg(deviceHandle, RESADDR, &result, fFalse);

	printf("0x01 + 0x01 = 0x%02X\n", result);

	DeppPutReg(deviceHandle, OP1ADDR, 0xA5, fFalse);
	DeppPutReg(deviceHandle, OP2ADDR, 0x5A, fFalse);
	DeppGetReg(deviceHandle, RESADDR, &result, fFalse);

	printf("0xA5 + 0x5A = 0x%02X\n", result);

	DeppPutReg(deviceHandle, OP1ADDR, 0xFF, fFalse);
	DeppPutReg(deviceHandle, OP2ADDR, 0x01, fFalse);
	DeppGetReg(deviceHandle, RESADDR, &result, fFalse);

	printf("0xFF + 0x01 = 0x%02X\n", result);

	//Disable the active port on the device
	status = DeppDisable(deviceHandle);
	if (status)
		printf("Successfully disabled DEPP port\n");
	else
	{
		status = DmgrGetLastError();
		printf("Error code: %d\n", status);
	}

	//Close our handle to the device
	status = DmgrClose(deviceHandle);
	if (status)
		printf("Successfully closed device handle\n");
	else
	{
		status = DmgrGetLastError();
		printf("Error code: %d\n", status);
	}


}
