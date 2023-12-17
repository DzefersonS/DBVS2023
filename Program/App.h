#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

const int DEBUG_MODE = 1;

void waitForLogin();
void doMainMenuLoop();
void repaintStartMenu();
void PerformCreateMenuLoop();
void PerformUpdateMenuLoop();
void PerformDeleteMenuLoop();
int linux_getch();
int linux_kbhit();
void printError();

int linux_getch() {
    struct termios oldt, newt;
    int ch;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    ch = getchar();
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    return ch;
}

int linux_kbhit() {
    struct termios oldt, newt;
    int ch, oldf;

    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

    ch = getchar();

    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    fcntl(STDIN_FILENO, F_SETFL, oldf);

    if (ch != EOF) {
        ungetc(ch, stdin);
        return 1;
    }

    return 0;
}

void printError()
{
	if(DEBUG_MODE)
	{
		fprintf(stderr, "==== sqlca ====\n");
		fprintf(stderr, "sqlcode: %ld\n", sqlca.sqlcode);
		fprintf(stderr, "sqlerrm.sqlerrml: %d\n", sqlca.sqlerrm.sqlerrml);
		fprintf(stderr, "sqlerrm.sqlerrmc: %s\n", sqlca.sqlerrm.sqlerrmc);
		fprintf(stderr, "sqlerrd: %ld %ld %ld %ld %ld %ld\n", sqlca.sqlerrd[0],sqlca.sqlerrd[1],sqlca.sqlerrd[2],
															sqlca.sqlerrd[3],sqlca.sqlerrd[4],sqlca.sqlerrd[5]);
		fprintf(stderr, "sqlwarn: %d %d %d %d %d %d %d %d\n", sqlca.sqlwarn[0], sqlca.sqlwarn[1], sqlca.sqlwarn[2],
															sqlca.sqlwarn[3], sqlca.sqlwarn[4], sqlca.sqlwarn[5],
															sqlca.sqlwarn[6], sqlca.sqlwarn[7]);
		fprintf(stderr, "sqlstate: %5s\n", sqlca.sqlstate);
		fprintf(stderr, "===============\n");
		exit(-1);
	}
}