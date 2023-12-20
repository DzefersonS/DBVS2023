#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

const int DEBUG_MODE = 1;
#define bool int
#define true 1
#define false 0

void waitForLogin();
void doMainMenuLoop();
void repaintStartMenu();
void repaintCreateMenuLoop();
void repaintViewMenuLoop(); 
void repaintUpdateMenuLoop();
void redrawDeleteMenuLoop();
int linux_getch();
int linux_kbhit();
void printError();
void verifyOperationSuccess();
void centerText();
void modifyString();

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

void centerText(char *text, int fieldWidth) {
    int padlen = (fieldWidth - strlen(text)) / 2;
    printf("%*s%s%*s", padlen, "", text, padlen, "");
} 


void modifyString(char *str, int newLength) {
    int start = 0;
    while (isspace((unsigned char) str[start])) {
        start++;
    }

    int j = 0;
    for (int i = start; str[i] != '\0'; i++, j++) {
        str[j] = str[i];
    }
    str[j] = '\0';

    int currentLength = strlen(str);
    int spacesToAdd = newLength - currentLength;

    if (spacesToAdd > 0) {
        for (int i = currentLength; i < newLength; i++) {
            str[i] = ' ';
        }
        str[newLength] = '\0';
    } else {
        str[newLength] = '\0';
    }
}