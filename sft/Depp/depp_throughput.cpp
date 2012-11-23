//#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "dpcdecl.h"
#include "depp.h"
#include "dmgr.h"

static HIF hif = hifInvalid;

static void DoPutRegRepeat() {
	BYTE    data[10000];
	int i = 0;
	int start = time(NULL);
	memset(data,0xff,sizeof(data));
	while(time(NULL) - start < 10) {
		if(!DeppPutRegRepeat(hif, 10, data, sizeof(data), fFalse)){
			printf("DeppPutRegRepeat failed.\n");
			exit(3);
		}
		i++;
	}
	printf("Stream to register completed %i bytes!\n",(int)(sizeof(data)*i));
}
int main(int cszArg, char * rgszArg[]) {
	fprintf(stderr,"Opening\n");

	if(!DmgrOpen(&hif, "Basys2")) {  
		printf("DmgrOpen failed (check the device name you provided)\n");
		return 0;
	}
	fprintf(stderr,"Enabling\n");

	if(!DeppEnable(hif)) {
		printf("DeppEnable failed\n");
		return 0;
	}
	fprintf(stderr,"Outputting\n");
	DoPutRegRepeat();

	if( hif != hifInvalid ) {
		DeppDisable(hif);
		DmgrClose(hif);
	}
	return 0;
}
