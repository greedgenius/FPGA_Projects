// RS-232 example
// Compiles with Microsoft Visual C++ 5.0/6.0
// (c) fpga4fun.com KNJN LLC - 2003, 2004, 2005, 2006

#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <time.h>

HANDLE hCom;

void OpenCom()
{
	DCB dcb;
	COMMTIMEOUTS ct;

	hCom = CreateFile("\\\\.\\COM6", GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if(hCom==INVALID_HANDLE_VALUE) {printf("invalid");system("pause");exit(1);}
	if(!SetupComm(hCom, 4096, 4096)) exit(1);

	if(!GetCommState(hCom, &dcb)) exit(1);
	dcb.BaudRate = 115200;
	((DWORD*)(&dcb))[2] = 0x1001;  // set port properties for TXDI + no flow-control
	dcb.ByteSize = 8;
	dcb.Parity = NOPARITY;
	dcb.StopBits = 2;
	if(!SetCommState(hCom, &dcb)) exit(1);

	// set the timeouts to 0
	ct.ReadIntervalTimeout = MAXDWORD;
	ct.ReadTotalTimeoutMultiplier = 0;
	ct.ReadTotalTimeoutConstant = 0;
	ct.WriteTotalTimeoutMultiplier = 0;
	ct.WriteTotalTimeoutConstant = 0;
	if(!SetCommTimeouts(hCom, &ct)) exit(1);
}

void CloseCom()
{
	CloseHandle(hCom);
}

DWORD WriteCom(char* buf, int len)
{
	DWORD nSend;
	if(!WriteFile(hCom, buf, len, &nSend, NULL)) exit(1);

	return nSend;
}

void WriteComChar(char b)
{
	WriteCom(&b, 1);
}

int ReadCom(char *buf, int len)
{
	DWORD nRec;
	if(!ReadFile(hCom, buf, len, &nRec, NULL)) exit(1);

	return (int)nRec;
}

char ReadComChar()
{
	DWORD nRec;
	char c;
	if(!ReadFile(hCom, &c, 1, &nRec, NULL)) exit(1);

	return nRec ? c : 0;
}

int main()
{
	unsigned char byte1,byte2,byte3;
	int digi_val=5;
    //char s[256];
	//int len;
	int i;
	int j=0;
	char s_num_csv[20];
	char file_addr[300];
	OpenCom();
    while(1){
    j++;
    itoa(j,s_num_csv,10);
    strcpy(file_addr,s_num_csv);
    strcat(file_addr,".csv");
	FILE *fw = fopen(file_addr,"a");
	printf("%s",file_addr);
	for(i=0;i<1000;i++){


	// sending data

	//WriteCom("ABCDE", 5);
	//Sleep(1);
	int p;
    for (p=0;p<1;p++) {
	WriteComChar(0x41);}//WriteComChar(0x42);		WriteComChar(0x43);
    Sleep(50);
	// receiving data
	//len = ReadCom(s, sizeof(s)-1);	s[len] = 0;	printf("%s\n", s);
    for (p=0;p<1;p++) {
    byte1=ReadComChar();
	byte2=ReadComChar();
	byte3=ReadComChar();
	//printf("%d\t",(int)lsb);
	digi_val=(int)byte1*256*256+(int)byte2*256+(int)byte3;
	//if (digi_val!=16705) printf("\n%d\n", digi_val);
	fprintf(fw,"%d\n",digi_val);}
    //printf("%lf\n",digi_val*3.314/4096.0);

    }
    fclose(fw);
    }
	CloseCom();
	printf("\nPress a key to exit");	getch();
	return 0;
}
