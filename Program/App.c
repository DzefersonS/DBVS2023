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
 char sql_user [ 100 ] = "gaza8879" ;
 
#line 10 "App.pgc"
 char sql_password [ 100 ] ;
 
#line 11 "App.pgc"
 char function_params [ 20 ] [ 100 ] ;
 
#line 12 "App.pgc"
 char dob [ 11 ] ;
 
#line 13 "App.pgc"
 int function_int_params [ 10 ] ;
/* exec sql end declare section */
#line 14 "App.pgc"


void waitForLogin();
void doMainMenuLoop();
void repaintStartMenu();
void PerformCreateMenuLoop();
void PerformUpdateMenuLoop();
void PerformDeleteMenuLoop();
int linux_getch();
int linux_kbhit();

int main()
{
	waitForLogin();
	doMainMenuLoop();
	
  	{ ECPGdisconnect(__LINE__, "CURRENT");}
#line 30 "App.pgc"

  	return 0;
}

void waitForLogin()
{
    struct termios oldt, newt;

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
		scanf("%99s", sql_password);

		{ ECPGconnect(__LINE__, 0, "studentu@pgsql3.mif" , sql_user , sql_password , NULL, 0); }
#line 53 "App.pgc"

		
		if(SQLCODE == 0)
		{
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

void doMainMenuLoop()
{
	repaintStartMenu();
	
	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '1':
					PerformCreateMenuLoop();
					repaintStartMenu();
					break;
				case '2':
					repaintStartMenu();
					break;
				case '3':
					PerformUpdateMenuLoop();
					repaintStartMenu();
					break;
				case '4':
					PerformDeleteMenuLoop();
					repaintStartMenu();
					break;
				case '0':
					return;
			}
		}
	}
}

void repaintStartMenu()
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
	repaintCreateMenu();
	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '1':
					AddNewPassenger();
					repaintCreateMenu();
					break;
				case '0':
					return;
				default:
					continue;
			}
		}
	}
}

void repaintCreateMenu()
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
}

void AddNewPassenger()
{
	system("clear");
	printf("Enter the person's ID: ");
	memset(function_params[0], '\0', sizeof(function_params[0]));
	scanf("%12s", function_params[0]);

	printf("Enter the person's first name: ");
	memset(function_params[1], '\0', sizeof(function_params[1]));
	scanf("%64s", function_params[1]);
	printf("Enter the person's last name: ");
	memset(function_params[2], '\0', sizeof(function_params[2]));
	scanf("%64s", function_params[2]);

	printf("Enter the person's date of birth: ");
	scanf("%11s", dob);

	printf("Enter the person's phone number: ");
	memset(function_params[4], '\0', sizeof(function_params[4]));
	scanf("%16s", function_params[4]);

	printf("Enter the person's email: ");
	memset(function_params[5], '\0', sizeof(function_params[5]));
	scanf("%99s", function_params[5]);

	printf("Enter the person's money balance: ");
	scanf("%d", &function_int_params[0]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select register_person ( $1  , $2  , $3  , $4  , $5  , $6  )", 
	ECPGt_char,(function_params[0]),(long)100,(long)1,(100)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[1]),(long)100,(long)1,(100)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[2]),(long)100,(long)1,(100)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(dob),(long)11,(long)1,(11)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[4]),(long)100,(long)1,(100)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[5]),(long)100,(long)1,(100)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 188 "App.pgc"


	if(SQLCODE != 0)
	{
		for(int i = 0; i < 11; ++i)
		{
			printf("%c", dob[i]);
		}
		printf("Passenger insuccessfully added. SQLCODE = %d", SQLCODE);
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