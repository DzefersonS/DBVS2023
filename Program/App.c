/* Processed by ecpg (15.5 (Debian 15.5-0+deb12u1)) */
/* These include files are added by the preprocessor */
#include <ecpglib.h>
#include <ecpgerrno.h>
#include <sqlca.h>
/* End of automatic include section */

#line 1 "App.pgc"
#include "App.h"

/* exec sql begin declare section */
 
 
 
 
 

#line 4 "App.pgc"
 int result ;
 
#line 5 "App.pgc"
 char sql_user [ 100 ] ;
 
#line 6 "App.pgc"
 char sql_password [ 100 ] ;
 
#line 7 "App.pgc"
 char function_params [ 20 ] [ 999 ] ;
 
#line 8 "App.pgc"
 int function_int_params [ 10 ] ;
/* exec sql end declare section */
#line 9 "App.pgc"


int main()
{
	waitForLogin();
	doMainMenuLoop();
	
  	{ ECPGdisconnect(__LINE__, "CURRENT");}
#line 16 "App.pgc"

  	return 0;
}

void waitForLogin()
{
    struct termios oldt, newt;

    //Retrieve default settings
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;

    //Disable echo flag
    newt.c_lflag &= ~(ECHO);

	for(;;)
	{
		printf("Enter username: ");
		scanf("%99s", sql_user);

		//Hide input
		tcsetattr(STDIN_FILENO, TCSANOW, &newt);

		printf("Enter password: ");
		scanf("%99s", sql_password);

		{ ECPGconnect(__LINE__, 0, "studentu@pgsql3.mif" , sql_user , sql_password , NULL, 0); }
#line 42 "App.pgc"

		
		if(SQLCODE == 0)
		{
			memset(sql_password, 0, sizeof(sql_password));
			//Re-enable input
			tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
			break;
		}
		else
		{
			printf("Failed to connect with SQLCODE %ld. Try again.\n", SQLCODE);
			//Re-enable input
			tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
		}
	}
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
					repaintCreateMenuLoop();
					break;
				case '2':
					repaintViewMenuLoop();
					break;
				case '3':
					repaintUpdateMenuLoop();
					break;
				case '4':
					redrawDeleteMenuLoop();
					break;
				case '0':
					return;
			}

			repaintStartMenu();
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

void repaintCreateMenuLoop()
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
					addNewPassenger();
					break;
				case '2':
					addNewEmployee();
					break;
				case '3':
					addNewPilot();
					break;
				case '4':
					addNewFlight();
					break;
				case '5':
					addNewAirplane();
					break;
				case '6':
					addNewAirport();
					break;
				case '7':
					addNewRoute();
					break;
				case '8':
					purchaseTicket();
					break;
				case '0':
					return;
				default:
					continue;
			}
			
			repaintCreateMenu();
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

void readPersonData()
{
	printf("Enter person id: ");
	scanf("%99s", function_params[0]);

	printf("Enter person first name: ");
	scanf("%99s", function_params[1]);

	printf("Enter person last name: ");
	scanf("%99s", function_params[2]);
	
	printf("Enter person date of birth: ");
	scanf("%99s", function_params[3]);

	printf("Enter person phone number: ");
	scanf("%99s", function_params[4]);
	
	printf("Enter person email: ");
	scanf("%99s", function_params[5]);
}

void readPassengerData()
{
	readPersonData();

	printf("Enter passenger balance: ");
	scanf("%d", &function_int_params[0]);
}

void readEmployeeData()
{
	readPersonData();

	printf("Enter employee position: ");
	scanf("%99s", function_params[6]);

	printf("Enter employee date of hire: ");
	scanf("%99s", function_params[7]);
}

void readPilotData()
{
	readEmployeeData();

	printf("Enter pilot license number: ");
	scanf("%99s", function_params[8]);

	printf("Enter pilot license issue date: ");
	scanf("%99s", function_params[9]);

	printf("Enter pilot license expiration date: ");
	scanf("%99s", function_params[10]);
}

void addNewPassenger()
{
	readPassengerData();

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select register_passenger ( $1  , $2  , $3  , $4  , $5  , $6  , $7  )", 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[1]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[2]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[3]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[4]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[5]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 223 "App.pgc"

	verifyOperationSuccess();
}

void addNewEmployee()
{
	readEmployeeData();

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select register_employee ( $1  , $2  , $3  , $4  , $5  , $6  , $7  , $8  )", 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[1]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[2]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[3]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[4]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[5]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[6]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[7]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 231 "App.pgc"

	verifyOperationSuccess();
}

void addNewPilot()
{
	readPilotData();

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select register_pilot ( $1  , $2  , $3  , $4  , $5  , $6  , $7  , $8  , $9  , $10  , $11  )", 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[1]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[2]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[3]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[4]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[5]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[6]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[7]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[8]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[9]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[10]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 239 "App.pgc"

	verifyOperationSuccess();
}

void addNewFlight()
{
	printf("Enter departure time: ");
	scanf("%99s", function_params[0]);
	
	printf("Enter arrival time: ");
	scanf("%99s", function_params[1]);
	
	printf("Enter route ID: ");
	scanf("%d", &function_int_params[0]);

	printf("Enter airplane ID: ");
	scanf("%d", &function_int_params[1]);

	printf("Enter pilot ID: ");
	scanf("%99s", &function_params[2]);

	printf("Enter copilot ID: ");
	scanf("%99s", &function_params[3]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select create_flight ( $1  , $2  , $3  , $4  , $5  , $6  )", 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[1]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[1]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[2]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[3]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 263 "App.pgc"

	verifyOperationSuccess();
}

void addNewAirplane()
{
	printf("Enter seat count: ");
	scanf("%d", &function_int_params[0]);
	
	printf("Enter ticket price: ");
	scanf("%d", &function_int_params[1]);

	printf("Enter registration number: ");
	scanf("%99s", function_params[0]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select add_airplane ( $1  , $2  , $3  )", 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[1]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 278 "App.pgc"

	verifyOperationSuccess();
}

void addNewAirport()
{
	printf("Enter airport name: ");
	scanf("%99s", function_params[0]);

	printf("Enter city name: ");
	scanf("%99s", function_params[1]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select add_airport ( $1  , $2  )", 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[1]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 290 "App.pgc"

	verifyOperationSuccess();
}

void addNewRoute()
{
	printf("Enter departure airport ID: ");
	scanf("%d", &function_int_params[0]);

	printf("Enter destination airport ID: ");
	scanf("%d", &function_int_params[1]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select create_route ( $1  , $2  )", 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[1]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 302 "App.pgc"

	verifyOperationSuccess();
}

void purchaseTicket()
{
	printf("Enter person ID: ");
	scanf("%99s", function_params[0]);

	printf("Enter ticket ID: ");
	scanf("%d", &function_int_params[0]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select purchase_ticket ( $1  , $2  )", 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 314 "App.pgc"

	verifyOperationSuccess();	
}

void repaintViewMenuLoop()
{
	system("clear");
	printf("Choose an option:\n");
	printf("1 - View all passenger details.\n");
	printf("2 - View all employee details.\n");
	printf("3 - Show banned passengers.\n");
	printf("4 - Show flights that have not yet sold out.\n");

	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '1':
					viewPassengerDetails();
					break;
				case '2':
					break;
				case '3':
					break;
				case '0':
					return;
				default:
					continue;
			}

			repaintViewMenuLoop();
		}
	}
}

void viewPassengerDetails()
{
	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select count ( * ) from Passenger", ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 355 "App.pgc"


	/* declare passengerIndex cursor for select * from PassengerDetails */
#line 358 "App.pgc"

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "declare passengerIndex cursor for select * from PassengerDetails", ECPGt_EOIT, ECPGt_EORT);}
#line 359 "App.pgc"


	centerText("PersonID", 12);
	printf(" |");
	centerText("FirstName", 66);
	printf(" |");
	centerText("LastName", 66);
	printf("|");
	printf("\n");
	for(int i = 0; i < result; ++i)
	{
		{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "fetch passengerIndex", ECPGt_EOIT, 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[1]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[2]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 370 "App.pgc"

		//printf("i = %d, str = %99s\n", i, function_params[1]);
		modifyString(function_params[0], 11);
		printf(" %11s |", function_params[0]);
		modifyString(function_params[1], 64);
		printf(" %64s |", function_params[1]);
		modifyString(function_params[2], 64);
		printf(" %64s |", function_params[2]);

		printf("\n");
	}
	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "close passengerIndex", ECPGt_EOIT, ECPGt_EORT);}
#line 381 "App.pgc"


	verifyOperationSuccess();
}

void repaintUpdateMenuLoop()
{
	system("clear");
	printf("Choose an option:\n");
	printf("1 - Update an airplane\n");
	printf("2 - Update an airport\n");
	printf("3 - Update a route\n");
	printf("0 - Return to main menu\n");

	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '1':
					updateAirplane();
					break;
				case '2':
					updateAirport();
					break;
				case '3':
					updateRoute();
					break;
				case '0':
					return;
				default:
					continue;
			}

			repaintUpdateMenuLoop();
		}
	}
}

void updateAirplane()
{
	printf("Enter airplane ID: ");
	scanf("%d", &function_int_params[0]);

	printf("Enter new seat count: ");
	scanf("%d", &function_int_params[1]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select update_airplane ( $1  , $2  )", 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[1]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 431 "App.pgc"

	verifyOperationSuccess();
}

void updateAirport()
{
	printf("Enter airport ID: ");
	scanf("%d", &function_int_params[0]);

	printf("Enter new airport name: ");
	scanf("%99s", function_params[0]);
	
	printf("Enter new city name: ");
	scanf("%99s", function_params[1]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select update_airport ( $1  , $2  , $3  )", 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(function_params[1]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 446 "App.pgc"

	verifyOperationSuccess();
}

void updateRoute()
{
	printf("Enter route ID: ");
	scanf("%d", &function_int_params[0]);

	printf("Enter new departure airport ID: ");
	scanf("%d", &function_int_params[1]);

	printf("Enter new destination airport ID: ");
	scanf("%d", &function_int_params[2]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select update_route ( $1  , $2  , $3  )", 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[1]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(function_int_params[2]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 461 "App.pgc"

	verifyOperationSuccess();
}

void redrawDeleteMenuLoop()
{
	system("clear");
	printf("Choose an option:\n");
	printf("1 - Ban a passenger\n");
	printf("2 - Cancel a flight\n");
	printf("0 - Return to main menu\n");

	for(;;)
	{
		if(linux_kbhit())
		{
			char keyPressed = linux_getch();

			switch(keyPressed)
			{
				case '1':
					banPassenger();
					break;
				case '2':
					cancelFlight();
					break;
				case '0':
					return;
				default:
					continue;
			}

			redrawDeleteMenuLoop();
		}
	}
}

void banPassenger()
{
	printf("Enter person ID: ");
	scanf("%99s", function_params[0]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select ban_passenger ( $1  )", 
	ECPGt_char,(function_params[0]),(long)999,(long)1,(999)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 503 "App.pgc"

	verifyOperationSuccess();
}

void cancelFlight()
{
	printf("Enter flight ID: ");
	scanf("%d", &function_int_params[0]);

	{ ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select cancel_flight ( $1  )", 
	ECPGt_int,&(function_int_params[0]),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(result),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 512 "App.pgc"

	verifyOperationSuccess();
}

void verifyOperationSuccess()
{
    if(SQLCODE == 0)
	{
		{ ECPGtrans(__LINE__, NULL, "commit");}
#line 520 "App.pgc"

		printf("Operation completed!");
		fflush(stdout);
		sleep(2);
	}
	else
	{
		printf("Failed to complete operation!");
		printError();
	}
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