program LCDOutput;

{$mode objfpc}{$H+}

{ Example - LCD Output using WaveShare SpotPear 3.2" driver                    }
{                                                                              }
{  This example shows use of embedded hardware by demonstrating LCD console    }
{  functions available in Ultibo and how to use them to manipulate text on the }
{  screen. Uses the ConsoleDeviceFindByDescription() function to find the LCD. }
{                                                                              }
{  To compile the example select Run, Compile (or Run, Build) from the menu.   }
{                                                                              }
{  Once compiled copy the kernel7.img file to an SD card along with the        }
{  firmware files and use it to boot your Raspberry Pi.                        }
{                                                                              }
{  Raspberry Pi 2B version                                                     }
{   What's the difference? See Project, Project Options, Config and Target.    }

{Declare some units used by this example.}
uses
  GlobalConst,
  GlobalTypes,
  Devices,
  Platform,
  Threads,
  Console,
  Framebuffer,
  PiTFT32,
  BCM2836,
  BCM2709,
  SysUtils,
  GlobalConfig,
  Logging,
  Filesystem,
  RaspberryPi2,
  FATFS,
  MMC,
  HTTP,
  WebStatus;

var
 RowCount:LongWord;
 ColumnCount:LongWord;
 CurrentX:LongWord;
 CurrentY:LongWord;
 Handle1:TWindowHandle;
 Handle2:TWindowHandle;

 HTTPListener:THTTPListener;


begin
 HTTPListener:=THTTPListener.Create;
 HTTPListener.Active:=True;

 WebStatusRegister(HTTPListener,'','',True);

 LoggingDeviceSetTarget(LoggingDeviceFindByType(LOGGING_TYPE_FILE),'c:\ultibo.log');
 //The next line normally isn't required but FileSysLoggingStart currently has
 // a bug that causes it to fail if no target is specified on the command line
 LoggingDeviceStart(LoggingDeviceFindByType(LOGGING_TYPE_FILE));
 LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_FILE));

 PiTFT32Init();

 LoggingOutput('TFT driver initialized');

 {Let's create a console window again but this time on the left side of the screen}
 Handle1:=ConsoleWindowCreate(ConsoleDeviceFindByDevice(DeviceFindByDescription('WaveShare SpotPear 3.2" LCD')),
   CONSOLE_POSITION_LEFT,True);

 {To prove that worked let's output some text on the console window}
 ConsoleWindowWriteLn(Handle1,'Welcome to LCD Screen Output');

 {So that things happen in a time frame we can see, let's wait about 3 seconds}
 ThreadSleep(3 * 1000);

 {Now let's get the current position of the console cursor into a couple of variables}
 ConsoleWindowGetXY(Handle1,CurrentX,CurrentY);

 {And we'll display those values on the screen}
 ConsoleWindowWriteLn(Handle1,'CurrentX= ' + IntToStr(CurrentX));
 ConsoleWindowWriteLn(Handle1,'CurrentY= ' + IntToStr(CurrentY));

 {Wait another 3 seconds so we can see that}
 ThreadSleep(3 * 1000);

 {Let's find out how big our console window is}
 ColumnCount:=ConsoleWindowGetCols(Handle1);
 RowCount:=ConsoleWindowGetRows(Handle1);

 {And print that on the screen as well}
 ConsoleWindowWriteLn(Handle1,'ColumnCount= ' + IntToStr(ColumnCount) + ' RowCount= ' + IntToStr(RowCount));

 {Wait 3 seconds again so we can see that}
 ThreadSleep(3 * 1000);

 {Now let's create another console window on the right side of the screen, notice
  that we use a different variable for the handle so we can still access the first
  console window.}
 Handle2:=ConsoleWindowCreate(ConsoleDeviceFindByDevice(DeviceFindByDescription('WaveShare SpotPear 3.2" LCD')),
   CONSOLE_POSITION_RIGHT,True);

 {Update our original console}
 ConsoleWindowWriteLn(Handle1,'Printing some colored text on the new console');

 {Using some more of the console function we can print to the screen using
  ConsoleWindowWriteLnEx() which allows us to control the color of the text
  and background as well as where to output the text}
 CurrentX:=ConsoleWindowGetX(Handle2);
 CurrentY:=ConsoleWindowGetY(Handle2);
 ConsoleWindowWriteLnEx(Handle2,'This is some text in red',CurrentX,CurrentY,COLOR_RED,
   ConsoleWindowGetBackcolor(Handle2));

 {ConsoleWindowWriteLnEx() doesn't update the position of X and Y for us, we
  need to move the to the next row so we can write the next line underneath}
 Inc(CurrentY);
 Inc(CurrentY);
 ConsoleWindowSetY(Handle2,CurrentY);
 ConsoleWindowWriteLnEx(Handle2,'This is some text in green',CurrentX,CurrentY,
   COLOR_GREEN,ConsoleWindowGetBackcolor(Handle2));

 {And one more time in yellow}
 Inc(CurrentY);
 Inc(CurrentY);
 ConsoleWindowSetY(Handle2,CurrentY);
 ConsoleWindowWriteLnEx(Handle2,'This is some text in yellow',CurrentX,CurrentY,
   COLOR_YELLOW,ConsoleWindowGetBackcolor(Handle2));

 {Wait a few more seconds so we can see that}
 ThreadSleep(3000);

 {Update our original console}
 ConsoleWindowWriteLn(Handle1,'Printing some text at the bottom of the new console');

 {Wait about some text at the bottom of the screen instead, we'll use ConsoleWindowWriteEx()
  instead so it doesn't scroll the screen up}
 ConsoleWindowWriteEx(Handle2,'This text should be in the last row of the screen',CurrentX,
   ConsoleWindowGetMaxY(Handle2),ConsoleWindowGetForecolor(Handle2),ConsoleWindowGetBackcolor(Handle2));

 {Wait a bit more}
 ThreadSleep(3000);

 {Update our original console}
 ConsoleWindowWriteLn(Handle1,'Clearing the new console');

 {Finally how about we clear the console window to get rid of all of that}
 ConsoleWindowClear(Handle2);

 {And say goodbye}
 ConsoleWindowWriteLn(Handle1,'All done, thanks for watching');

 LoggingOutput('End of program');

 {We're not doing a loop this time so we better halt this thread before it exits}
 ThreadHalt(0);
end.

