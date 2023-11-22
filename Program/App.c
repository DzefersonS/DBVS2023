/* Processed by ecpg (15.5 (Debian 15.5-0+deb12u1)) */
/* These include files are added by the preprocessor */
#include <ecpglib.h>
#include <ecpgerrno.h>
#include <sqlca.h>
/* End of automatic include section */

#line 1 "App.pgc"
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

/* exec sql begin declare section */
  
    
  

#line 9 "App.pgc"
 int result ;
 
#line 10 "App.pgc"
 char sql_user [ 100 ] = "gaza8879" ;
 
#line 11 "App.pgc"
 char sql_password [ 100 ] ;
/* exec sql end declare section */
#line 12 "App.pgc"


void WaitForAuthentication();
void PerformMainLoop();
void RepaintStartingMenuText();
void PerformCreateMenuLoop();
void PerformUpdateMenuLoop();
void PerformDeleteMenuLoop();
int linux_getch();
int linux_kbhit();

int main()
{
	WaitForAuthentication();
	PerformMainLoop();
	
  	{ ECPGdisconnect(__LINE__, "CURRENT");}
#line 28 "App.pgc"

  	return 0 ;
}

void WaitForAuthentication()
{
    struct termios oldt, newt;
    char password[100];

    // Get old settings
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;

    // Disable echo
    newt.c_lflag &= ~(ECHO);

    // Set new settings
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

	for(;;)
	{
		printf("Enter password: ");
		scanf("%99s", password);

		strncpy(sql_password, password, sizeof(sql_password));
		sql_password[sizeof(sql_password) - 1] = "\0";

		{ ECPGconnect(__LINE__, 0, "studentu@pgsql3.mif" , sql_user , sql_password , NULL, 0); }
#line 55 "App.pgc"

		
		if(SQLCODE == 0)
		{
			system("clear");
			printf("Successfully connected with SQLCODE %ld!\n", SQLCODE);
			memset(password, 0, sizeof(password));
			memset(sql_password, 0, sizeof(sql_password));
			break;
		}
		else
		{
			printf("Failed to connect with SQLCODE %ld. Try again.\n", SQLCODE);
		}
	}

    // Restore old settings
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
}

void PerformMainLoop()
{
	RepaintStartingMenuText();
	
	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '1':
					PerformCreateMenuLoop();
					RepaintStartingMenuText();
					break;
				case '2':
					RepaintStartingMenuText();
					break;
				case '3':
					PerformUpdateMenuLoop();
					RepaintStartingMenuText();
					break;
				case '4':
					PerformDeleteMenuLoop();
					RepaintStartingMenuText();
					break;
				case '0':
					return;
			}
		}
	}
}

void RepaintStartingMenuText()
{
	system("clear");
	printf("Welcome to the airport management system! What would you like to do today?\n");
	printf("1 - Add new entry to the database\n");
	printf("2 - Select entries from the database\n");
	printf("3 - Update existing entries in the database\n");
	printf("4 - Delete an entry from the database\n");
	printf("0 - Exit the application\n");
}

void PerformCreateMenuLoop()
{
	system("clear");
	printf("Choose an option:\n");
	printf("1 - Add a new passenger\n");
	printf("2 - Add a new employee\n");
	printf("3 - Add a new pilot\n");
	printf("4 - Add a new flight\n");
	printf("5 - Add a new airplane\n");
	printf("6 - Add a new airport\n");
	printf("7 - Add a new route\n");
	printf("8 - Purchase tickets\n");
	printf("0 - Return to main menu\n");

	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '0':
					return;
				default:
					continue;
			}
		}
	}
}

void PerformUpdateMenuLoop()
{
	system("clear");
	printf("Choose an option:\n");
	printf("1 - Update a person\n");
	printf("2 - Update a passenger\n");
	printf("3 - Update an employee\n");
	printf("4 - Update a pilot\n");
	printf("5 - Update a flight\n");
	printf("6 - Update an airplane\n");
	printf("7 - Update an airport\n");
	printf("8 - Update a route\n");
	printf("0 - Return to main menu\n");

	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '0':
					return;
				default:
					continue;
			}
		}
	}
}

void PerformDeleteMenuLoop()
{
	system("clear");
	printf("Choose an option:\n");
	printf("1 - Ban a passenger\n");
	printf("2 - Fire an employee\n");
	printf("3 - Cancel a flight\n");
	printf("4 - Remove an airplane\n");
	printf("5 - Remove an airport\n");
	printf("6 - Remove a route\n");
	printf("0 - Return to main menu\n");

	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '0':
					return;
				default:
					continue;
			}
		}
	}
}

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