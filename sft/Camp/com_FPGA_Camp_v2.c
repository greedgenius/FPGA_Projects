// RS-232 example
// Compiles with Microsoft Visual C++ 5.0/6.0
// (c) fpga4fun.com KNJN LLC - 2003, 2004, 2005, 2006

// code modified to receive data from FPGA_Camp2_v2. Feng Ming Zhu

#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <time.h>

HANDLE hCom;

void OpenCom()
{
	DCB dcb;
	COMMTIMEOUTS ct;

	hCom = CreateFile("\\\\.\\COM5", GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if(hCom==INVALID_HANDLE_VALUE) {printf("invalid");system("pause");exit(1);}
	if(!SetupComm(hCom, 4096, 4096)) exit(1);

	if(!GetCommState(hCom, &dcb)) exit(1);
	dcb.BaudRate = 19200;
	((DWORD*)(&dcb))[2] = 0x1001;  // set port properties for TXDI + no flow-control
	dcb.ByteSize = 8;
	dcb.Parity = ODDPARITY;
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
	int SysState;
	int PowerData1,PowerData2,PowerData3,PowerData4;
	const int BytePer16milSecond=11;
	int testByte[30];
	int verifyTestByte;
	int dataInOneFile=0;
	int allowedByteInOneFile=10000;
	int getsize;
    unsigned char uartInput[3000], uartInputRemain[30];
	int len,len2;
	int i=-1,j,k=0;
	int n;
	char s_num_csv[20];
	char file_addr[300];

	OpenCom();
	//----------------------------------------identify system status byte
	while (i==-1){
	        Sleep(120);
			len=ReadCom(uartInput, 5*BytePer16milSecond);
			for (j=0;j<BytePer16milSecond;j++)testByte[j]=0xe0;

			for (j=0;j<5;j++){
				for (n=0;n<BytePer16milSecond;n++){
				testByte[n] &= uartInput[j*BytePer16milSecond+n]  ;
				}
			}

			for (j=0;j<BytePer16milSecond;j++) {verifyTestByte |=testByte[j];}

			if ((int)(verifyTestByte & 0xe0)!=(int)0xe0) {printf("Error: Input data format error, no SysStatus Byte found!\n");return 0;}

			for (j=0;j<BytePer16milSecond;j++){	if ((int)(testByte[j] & 0xe0)==(int)0xe0){ i=j+1; break;}}
		}
    Sleep(30);
    ReadCom(uartInput, i);
    /* test code for flow control
    for (j=0;j<100;j++){
    Sleep(16);
    len=ReadCom(uartInput, 5);printf("%d,%d,%d,%d,%d,%d\n",len,uartInput[0],uartInput[1],uartInput[2],uartInput[3],uartInput[4]);
    }return 0;
	*/

	while(1){
		//------------------------------------open csv file to log
		k++;  itoa(k,s_num_csv,10);
		strcpy(file_addr,s_num_csv);
		strcat(file_addr,".csv");
		FILE *fw = fopen(file_addr,"a");
		printf("%s\n",file_addr);
		//------------------------------------Get data
		allowedByteInOneFile=10000*BytePer16milSecond;
		dataInOneFile=0;
		while (dataInOneFile <allowedByteInOneFile){

		if (allowedByteInOneFile-dataInOneFile < sizeof(uartInput)-1)
			getsize=allowedByteInOneFile-dataInOneFile;
		else
			getsize=sizeof(uartInput)-1;

		Sleep(100);
		len = ReadCom(uartInput, getsize);	uartInput[len] = 0;
		dataInOneFile+=len;

		if (len%BytePer16milSecond ==0) {}
		else{
			Sleep(16);
			len2=ReadCom(uartInputRemain,(BytePer16milSecond-len%BytePer16milSecond));
			dataInOneFile+=len2;
			uartInputRemain[BytePer16milSecond-len%BytePer16milSecond]=0;
			}

		if (allowedByteInOneFile<dataInOneFile) printf("Error: too much data in one file!");

		for (i=0;i<len/BytePer16milSecond;i++) {
            PowerData1=256*256*(int)uartInput[i*BytePer16milSecond]  +256*(int)uartInput[i*BytePer16milSecond+1]+(int)uartInput[i*BytePer16milSecond+2];
            PowerData2=256*256*(int)uartInput[i*BytePer16milSecond+3]+256*(int)uartInput[i*BytePer16milSecond+4]+(int)uartInput[i*BytePer16milSecond+5];
            PowerData3=256*    (int)uartInput[i*BytePer16milSecond+6]+    (int)uartInput[i*BytePer16milSecond+7];
			PowerData4=256*    (int)uartInput[i*BytePer16milSecond+8]+    (int)uartInput[i*BytePer16milSecond+9];
            SysState  =        (int)uartInput[i*BytePer16milSecond+10];

            fprintf(fw,"\t%d,\t\t%d,\t\t%d,\t\t%d,\t\t%d\n",PowerData1,PowerData2,PowerData3,PowerData4,SysState);
            printf(    "\t%d,\t\t%d,\t\t%d,\t\t%d,\t\t%d\n",PowerData1,PowerData2,PowerData3,PowerData4,SysState);
		}

		if(len%BytePer16milSecond !=0){
			int tmpData[BytePer16milSecond];
			int m; m=0;
			for (i=0;i<len%BytePer16milSecond;i++){
			tmpData[m++]=uartInput[len-len%BytePer16milSecond+i];}

			for (i=0;i<(BytePer16milSecond-len%BytePer16milSecond);i++){
			tmpData[m++]=uartInputRemain[i];}

			PowerData1=256*256*(int)tmpData[0]+256*(int)tmpData[1]+(int)tmpData[2];
			PowerData2=256*256*(int)tmpData[3]+256*(int)tmpData[4]+(int)tmpData[5];
			PowerData3=256*    (int)tmpData[6]+    (int)tmpData[7];
			PowerData4=256*    (int)tmpData[8]+    (int)tmpData[9];
			SysState  =        (int)tmpData[10];

			fprintf(fw,"\t%d,\t\t%d,\t\t%d,\t\t%d,\t\t%d\n",PowerData1,PowerData2,PowerData3,PowerData4,SysState);
            printf(    "\t%d,\t\t%d,\t\t%d,\t\t%d,\t\t%d\n",PowerData1,PowerData2,PowerData3,PowerData4,SysState);
		}
		}
		fclose(fw);
    }
	CloseCom();
	printf("\nPress a key to exit");	getch();
	return 0;
}

// sending data
//WriteCom("ABCDE", 5);
