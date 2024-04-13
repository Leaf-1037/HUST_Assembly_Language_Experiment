#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <conio.h>
#include <string.h>
#define N 30
#define M 20
#define username "wangbin"
#define password "applegrape"

typedef struct statusInfos {
	char SAMID[9];
	int SDA;
	int SDB;
	int SDC;
	int SF;
} statusInfos;

statusInfos dataArr[N] = { {"00000001", 2540, 1, 1000},
	{"00000002", 2540, 1, 1},
	{"00000003", 2540, 1000, 1},
	{"00000004", 3, 4, 5},
	{"00000005", 4, 5, 6} };
statusInfos LOWF[N], MIDF[N], HIGHF[N];

void copyData(statusInfos *l, statusInfos *r) {
	strcpy((*r).SAMID, (*l).SAMID);
	r->SDA = l->SDA;
	r->SDB = l->SDB;
	r->SDC = l->SDC;
	r->SF = l->SF;
}

int calc_f(int sda, int sdb, int sdc) {
	int F;
	_asm {
		push edx
		mov edx, 0
		mov edx, sda
		sal edx, 2
		add edx, sda
		add edx, sdb
		add edx, 100
		sub edx, sdc
		sar edx, 7
		mov F, edx
		pop edx
	}
	return F;
}

void ptf_MIDF(int num) {
	printf("\n\nMIDF block:\n");
	for (int i = 0; i < num; ++i) {
		printf("   {SAMID = %s, SDA = %d, SDB = %d, SDC = %d, SF = %d}\n",
			MIDF[i].SAMID, MIDF[i].SDA, MIDF[i].SDB, MIDF[i].SDC, MIDF[i].SF);
	}
}

int isKeyCorrect(int num) {
	char str1[M], str2[M];
	printf("\n\nPlease enter your username and password. You have %d time(s).\n\n", 3 - num);
	printf("Username: ");
	scanf("%s", str1);
	printf("Password: ");
	scanf("%s", str2);
	if (strcmp(str1, username) != 0) return 0;
	if (strcmp(str2, password) != 0) return 0;
	return 1;
}

void getInfo(statusInfos *r) {
	statusInfos temp;
	printf("\n\nEnter a new samid information.\n");
	printf(" SAMID(<=8 chars): ");
	scanf("%s", temp.SAMID);
	printf(" SDA: ");
	scanf("%d", &temp.SDA);
	printf(" SDB: ");
	scanf("%d", &temp.SDB);
	printf(" SDC: ");
	scanf("%d", &temp.SDC);
	copyData(&temp, r);
}

int x, y = 1;
int main() {
	int N_C = 5;
	int count = 0, c_1 = 0, c_2 = 0, c_3 = 0;
	*(&x - 1) = 20;
	printf("%d", y);
	char c;
	while (!isKeyCorrect(count)) {
		count += 1;
		if (count == 3) {
			printf("\n\nSorry, you have entered wrong username or password for 3 times.\n");
			printf("We will put an end to this program.");
			return 0;
		}
	}
KEY_R:
	c_1 = c_2 = c_3 = 0;
	for (int i = 0; i < N_C; ++i) {
		dataArr[i].SF = calc_f(dataArr[i].SDA, dataArr[i].SDB, dataArr[i].SDC);
		if (dataArr[i].SF < 100) copyData(dataArr + i, LOWF + (c_1++));
		if (dataArr[i].SF == 100) copyData(dataArr + i, MIDF + (c_2++));
		if (dataArr[i].SF > 100) copyData(dataArr + i, HIGHF + (c_3++));
	}
	ptf_MIDF(c_2);
KEY_M:
	printf("\nPress M to enter next samid info. Press R to re-output MIDF. Press Q to exit.\n\n");
	printf("\n             Press key to continue... ");
	while (!((c = _getch()) == 'm' || c == 'r' || c == 'q'));
	if (c == 'm') {
		getInfo(dataArr);
		goto KEY_M;
	}
	else if (c == 'r') goto KEY_R;
	else if (c == 'q') {
		printf(" Thank you for using!\n");
		return 0;
	}
	return 0;
}