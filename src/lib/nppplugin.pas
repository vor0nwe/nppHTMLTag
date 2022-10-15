{
    This file is part of DBGP Plugin for Notepad++
    Copyright (C) 2007  Damjan Zobo Cvetko

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit nppplugin;

{$IFDEF FPC}{$mode delphiunicode}{$ENDIF}

interface

uses
  Windows,Messages,SciSupport,SysUtils;

{$MINENUMSIZE 4}

{$I 'SciApi.inc'}

const
  FuncItemNameLen=64;
  MaxFuncs = 11;

  { Most of this defs are outdated... But there is no consistant N++ doc... }
  NPPMSG = (WM_USER + 1000);
  NPPM_GETCURRENTSCINTILLA = (NPPMSG + 4);          // lParam indicates the current Scintilla view : 0 is the main Scintilla view; 1 is the second Scintilla view.
  NPPM_GETCURRENTLANGTYPE = (NPPMSG + 5);           // lParam indicates the language type of current Scintilla view document: please see the enum LangType for all possible values.
  NPPM_SETCURRENTLANGTYPE = (NPPMSG + 6);           // lParam is used to set the language type of current Scintilla view document (see above)
  NPPM_GETNBOPENFILES = (NPPMSG + 7);               // returns the number of files; depending on lParam: ALL_OPEN_FILES; PRIMARY_VIEW or SECONDARY_VIEW
    ALL_OPEN_FILES = 0;
    PRIMARY_VIEW = 1;
    SECOND_VIEW = 2;
  NPPM_GETOPENFILENAMES = (NPPMSG + 8);
  WM_CANCEL_SCINTILLAKEY = (NPPMSG + 9);
  WM_BIND_SCINTILLAKEY = (NPPMSG + 10);
  WM_SCINTILLAKEY_MODIFIED = (NPPMSG + 11);
  NPPM_MODELESSDIALOG = (NPPMSG + 12);
    MODELESSDIALOGADD = 0;
    MODELESSDIALOGREMOVE = 1;

  NPPM_GETNBSESSIONFILES = (NPPMSG + 13);
  NPPM_GETSESSIONFILES = (NPPMSG + 14);
  NPPM_SAVESESSION = (NPPMSG + 15);
  NPPM_SAVECURRENTSESSION  =(NPPMSG + 16);  // see TSessionInfo
  NPPM_GETOPENFILENAMESPRIMARY = (NPPMSG + 17);
  NPPM_GETOPENFILENAMESSECOND = (NPPMSG + 18);
  WM_GETPARENTOF = (NPPMSG + 19);
  NPPM_CREATESCINTILLAHANDLE = (NPPMSG + 20);
  NPPM_DESTROYSCINTILLAHANDLE = (NPPMSG + 21);
  NPPM_GETNBUSERLANG = (NPPMSG + 22);
  NPPM_GETCURRENTDOCINDEX = (NPPMSG + 23);
    MAIN_VIEW = 0;
    SUB_VIEW = 1;

  NPPM_SETSTATUSBAR = (NPPMSG + 24);
    STATUSBAR_DOC_TYPE = 0;
    STATUSBAR_DOC_SIZE = 1;
    STATUSBAR_CUR_POS = 2;
    STATUSBAR_EOF_FORMAT = 3;
    STATUSBAR_UNICODE_TYPE = 4;
    STATUSBAR_TYPING_MODE = 5;

  NPPM_GETMENUHANDLE = (NPPMSG + 25);
    NPPPLUGINMENU = 0;

  NPPM_ENCODESCI = (NPPMSG + 26);
  //ascii file to unicode
  //int WM_ENCODE_SCI(MAIN_VIEW/SUB_VIEW, 0)
  //return new unicodeMode

  NPPM_DECODESCI = (NPPMSG + 27);
  //unicode file to ascii
  //int WM_DECODE_SCI(MAIN_VIEW/SUB_VIEW, 0)
  //return old unicodeMode

  NPPM_ACTIVATEDOC = (NPPMSG + 28);
  //void WM_ACTIVATE_DOC(int index2Activate, int view)

  NPPM_LAUNCHFINDINFILESDLG = (NPPMSG + 29);
  //void WM_LAUNCH_FINDINFILESDLG(char * dir2Search, char * filtre)

  NPPM_DMMSHOW = (NPPMSG + 30);
  NPPM_DMMHIDE	= (NPPMSG + 31);
  NPPM_DMMUPDATEDISPINFO = (NPPMSG + 32);
  //void WM_DMM_xxx(0, tTbData->hClient)

  NPPM_DMMREGASDCKDLG = (NPPMSG + 33);
  //void WM_DMM_REGASDCKDLG(0, &tTbData)

  NPPM_LOADSESSION = (NPPMSG + 34);
  //void WM_LOADSESSION(0, const char* file name)
  NPPM_DMMVIEWOTHERTAB = (NPPMSG + 35);
  //void WM_DMM_VIEWOTHERTAB(0, tTbData->hClient)
  NPPM_RELOADFILE = (NPPMSG + 36);
  //BOOL WM_RELOADFILE(BOOL withAlert, char *filePathName2Reload)
  NPPM_SWITCHTOFILE = (NPPMSG + 37);
  //BOOL WM_SWITCHTOFILE(0, char *filePathName2switch)
  NPPM_SAVECURRENTFILE = (NPPMSG + 38);
  //BOOL WM_SWITCHTOFILE(0, 0)
  NPPM_SAVEALLFILES	= (NPPMSG + 39);
  //BOOL WM_SAVEALLFILES(0, 0)
  NPPM_SETMENUITEMCHECK	= (NPPMSG + 40);
  //void WM_PIMENU_CHECK(UINT	funcItem[X]._cmdID, TRUE/FALSE)
  NPPM_ADDTOOLBARICON = (NPPMSG + 41); // see TToolbarIcons
  //void WM_ADDTOOLBARICON(UINT funcItem[X]._cmdID, toolbarIcons icon)
  NPPM_GETWINDOWSVERSION = (NPPMSG + 42);
  //winVer WM_GETWINDOWSVERSION(0, 0)
  NPPM_DMMGETPLUGINHWNDBYNAME = (NPPMSG + 43);
  //HWND WM_DMM_GETPLUGINHWNDBYNAME(const char *windowName, const char *moduleName)
  // if moduleName is NULL, then return value is NULL
  // if windowName is NULL, then the first found window handle which matches with the moduleName will be returned
  NPPM_MAKECURRENTBUFFERDIRTY = (NPPMSG + 44);
  //BOOL NPPM_MAKECURRENTBUFFERDIRTY(0, 0)
  NPPM_GETENABLETHEMETEXTUREFUNC = (NPPMSG + 45);
  //BOOL NPPM_GETENABLETHEMETEXTUREFUNC(0, 0)
  NPPM_GETPLUGINSCONFIGDIR = (NPPMSG + 46);
  //void NPPM_GETPLUGINSCONFIGDIR(int strLen, char *str)

  // new
  NPPM_MSGTOPLUGIN = (NPPMSG + 47); // see TCommunicationInfo
	//BOOL NPPM_MSGTOPLUGIN(TCHAR *destModuleName, CommunicationInfo *info)
	// return value is TRUE when the message arrive to the destination plugins.
	// if destModule or info is NULL, then return value is FALSE
//		struct CommunicationInfo {
//			long internalMsg;
//			const TCHAR * srcModuleName;
//			void * info; // defined by plugin
//		};

	NPPM_MENUCOMMAND = (NPPMSG + 48);
	//void NPPM_MENUCOMMAND(0, int cmdID)
	// uncomment //#include "menuCmdID.h"
	// in the beginning of this file then use the command symbols defined in "menuCmdID.h" file
	// to access all the Notepad++ menu command items

	NPPM_TRIGGERTABBARCONTEXTMENU = (NPPMSG + 49);
	//void NPPM_TRIGGERTABBARCONTEXTMENU(int view, int index2Activate)

	NPPM_GETNPPVERSION = (NPPMSG + 50);
	// int NPPM_GETNPPVERSION(0, 0)
	// return version
	// ex : v4.6
	// HIWORD(version) == 4
	// LOWORD(version) == 6

	NPPM_HIDETABBAR = (NPPMSG + 51);
	// BOOL NPPM_HIDETABBAR(0, BOOL hideOrNot)
	// if hideOrNot is set as TRUE then tab bar will be hidden
	// otherwise it'll be shown.
	// return value : the old status value

	NPPM_ISTABBARHIDE = (NPPMSG + 52);
	// BOOL NPPM_ISTABBARHIDE(0, 0)
	// returned value : TRUE if tab bar is hidden, otherwise FALSE

	NPPM_CHECKDOCSTATUS = (NPPMSG + 53);
	// VOID NPPM_CHECKDOCSTATUS(BOOL, 0)

	NPPM_ENABLECHECKDOCOPT = (NPPMSG + 54);
	// VOID NPPM_ENABLECHECKDOCOPT(OPT, 0)
		// where OPT is :
		CHECKDOCOPT_NONE = 0;
		CHECKDOCOPT_UPDATESILENTLY = 1;
		CHECKDOCOPT_UPDATEGO2END = 2;

	NPPM_GETCHECKDOCOPT = (NPPMSG + 55);
	// INT NPPM_GETCHECKDOCOPT(0, 0)
	NPPM_SETCHECKDOCOPT = (NPPMSG + 56);
	// INT NPPM_SETCHECKDOCOPT(OPT, 0)

	NPPM_GETPOSFROMBUFFERID = (NPPMSG + 57);
	// INT NPPM_GETPOSFROMBUFFERID(INT bufferID, 0)
	// Return VIEW|INDEX from a buffer ID. -1 if the bufferID non existing
	//
	// VIEW takes 2 highest bits and INDEX (0 based) takes the rest (30 bits)
	// Here's the values for the view :
	//  MAIN_VIEW 0
	//  SUB_VIEW  1

	NPPM_GETFULLPATHFROMBUFFERID = (NPPMSG + 58);
	// INT NPPM_GETFULLPATHFROMBUFFERID(INT bufferID, CHAR *fullFilePath)
	// Get full path file name from a bufferID.
	// Return -1 if the bufferID non existing, otherwise the number of TCHAR copied/to copy
	// User should call it with fullFilePath be NULL to get the number of TCHAR (not including the nul character),
	// allocate fullFilePath with the return values + 1, then call it again to get  full path file name

	NPPM_GETBUFFERIDFROMPOS = (NPPMSG + 59);
	//wParam: Position of document
	//lParam: View to use, 0 = Main, 1 = Secondary
	//Returns 0 if invalid

	NPPM_GETCURRENTBUFFERID = (NPPMSG + 60);
	//Returns active Buffer

	NPPM_RELOADBUFFERID = (NPPMSG + 61);
	//Reloads Buffer
	//wParam: Buffer to reload
	//lParam: 0 if no alert, else alert

	NPPM_SETFILENAME = (NPPMSG + 63);
	//wParam: BufferID to rename
	//lParam: name to set (TCHAR*)
	//Buffer must have been previously unnamed (eg "new 1" document types)

	NPPM_GETBUFFERLANGTYPE = (NPPMSG + 64);
	//wParam: BufferID to get LangType from
	//lParam: 0
	//Returns as int, see LangType. -1 on error

	NPPM_SETBUFFERLANGTYPE = (NPPMSG + 65);
	//wParam: BufferID to set LangType of
	//lParam: LangType
	//Returns TRUE on success, FALSE otherwise
	//use int, see LangType for possible values
	//L_USER and L_EXTERNAL are not supported

	NPPM_GETBUFFERENCODING = (NPPMSG + 66);
	//wParam: BufferID to get encoding from
	//lParam: 0
	//returns as int, see UniMode. -1 on error

	NPPM_SETBUFFERENCODING = (NPPMSG + 67);
	//wParam: BufferID to set encoding of
	//lParam: format
	//Returns TRUE on success, FALSE otherwise
	//use int, see UniMode
	//Can only be done on new, unedited files

	NPPM_GETBUFFERFORMAT = (NPPMSG + 68);
	//wParam: BufferID to get format from
	//lParam: 0
	//returns as int, see formatType. -1 on error

	NPPM_SETBUFFERFORMAT = (NPPMSG + 69);
	//wParam: BufferID to set format of
	//lParam: format
	//Returns TRUE on success, FALSE otherwise
	//use int, see formatType

	NPPM_DOOPEN = (NPPMSG + 77);
	// BOOL NPPM_DOOPEN(0, const TCHAR *fullPathName2Open)
	// fullPathName2Open indicates the full file path name to be opened.
	// The return value is TRUE (1) if the operation is successful, otherwise FALSE (0).

  // http://sourceforge.net/p/notepad-plus/discussion/482781/thread/c430f474
  NPPM_GETLANGUAGENAME = (NPPMSG + 83);
   // INT NPPM_GETLANGUAGENAME(int langType, TCHAR *langName)
   // Get programing language name from the given language type (LangType)
   // Return value is the number of copied character / number of character to copy (\0 is not included)
   // You should call this function 2 times - the first time you pass langName as NULL to get the number of characters to copy.
       // You allocate a buffer of the length of (the number of characters + 1) then call NPPM_GETLANGUAGENAME function the 2nd time
   // by passing allocated buffer as argument langName

  NPPM_GETLANGUAGEDESC = (NPPMSG + 84);
   // INT NPPM_GETLANGUAGEDESC(int langType, TCHAR *langDesc)
   // Get programing language short description from the given language type (LangType)
   // Return value is the number of copied character / number of character to copy (\0 is not included)
   // You should call this function 2 times - the first time you pass langDesc as NULL to get the number of characters to copy.
       // You allocate a buffer of the length of (the number of characters + 1) then call NPPM_GETLANGUAGEDESC function the 2nd time
   // by passing allocated buffer as argument langDesc



  // Notification code
  NPPN_FIRST = 1000;
  NPPN_READY = (NPPN_FIRST + 1);
  // To notify plugins that all the procedures of launchment of notepad++ are done.
  //scnNotification->nmhdr.code = NPPN_READY;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_TB_MODIFICATION = (NPPN_FIRST + 2);
  // To notify plugins that toolbar icons can be registered
  //scnNotification->nmhdr.code = NPPN_TB_MODIFICATION;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_FILEBEFORECLOSE = (NPPN_FIRST + 3);
  // To notify plugins that the current file is about to be closed
  //scnNotification->nmhdr.code = NPPN_FILEBEFORECLOSE;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_FILEOPENED = (NPPN_FIRST + 4);
  // To notify plugins that the current file is just opened
  //scnNotification->nmhdr.code = NPPN_FILEOPENED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_FILECLOSED = (NPPN_FIRST + 5);
  // To notify plugins that the current file is just closed
  //scnNotification->nmhdr.code = NPPN_FILECLOSED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_FILEBEFOREOPEN = (NPPN_FIRST + 6);
  // To notify plugins that the current file is about to be opened
  //scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_FILEBEFORESAVE = (NPPN_FIRST + 7);
  // To notify plugins that the current file is about to be saved
  //scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_FILESAVED = (NPPN_FIRST + 8);
  // To notify plugins that the current file is just saved
  //scnNotification->nmhdr.code = NPPN_FILECLOSED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_SHUTDOWN = (NPPN_FIRST + 9);
  // To notify plugins that Notepad++ is about to be shutdowned.
  //scnNotification->nmhdr.code = NPPN_SHUTDOWN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_BUFFERACTIVATED = (NPPN_FIRST + 10);
  // To notify plugins that a buffer was activated (put to foreground).
  //scnNotification->nmhdr.code = NPPN_BUFFERACTIVATED;
 	//scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = activatedBufferID;


  RUNCOMMAND_USER    = (WM_USER + 3000);
    VAR_NOT_RECOGNIZED = 0;
    FULL_CURRENT_PATH = 1;
    CURRENT_DIRECTORY = 2;
    FILE_NAME = 3;
    NAME_PART = 4;
    EXT_PART = 5;
    CURRENT_WORD = 6;
    NPP_DIRECTORY = 7;
  NPPM_GETFULLCURRENTPATH = (RUNCOMMAND_USER + FULL_CURRENT_PATH);
  NPPM_GETCURRENTDIRECTORY = (RUNCOMMAND_USER + CURRENT_DIRECTORY);
  NPPM_GETFILENAME = (RUNCOMMAND_USER + FILE_NAME);
  NPPM_GETNAMEPART = (RUNCOMMAND_USER + NAME_PART);
  NPPM_GETEXTPART = (RUNCOMMAND_USER + EXT_PART);
  NPPM_GETCURRENTWORD = (RUNCOMMAND_USER + CURRENT_WORD);
  NPPM_GETNPPDIRECTORY = (RUNCOMMAND_USER + NPP_DIRECTORY);

  MACRO_USER    = (WM_USER + 4000);
  WM_ISCURRENTMACRORECORDED = (MACRO_USER + 01);
  WM_MACRODLGRUNMACRO       = (MACRO_USER + 02);


{ Humm.. is tis npp specific? }
  SCINTILLA_USER = (WM_USER + 2000);
{
#define WM_DOCK_USERDEFINE_DLG      (SCINTILLA_USER + 1)
#define WM_UNDOCK_USERDEFINE_DLG    (SCINTILLA_USER + 2)
#define WM_CLOSE_USERDEFINE_DLG		(SCINTILLA_USER + 3)
#define WM_REMOVE_USERLANG		    (SCINTILLA_USER + 4)
#define WM_RENAME_USERLANG			(SCINTILLA_USER + 5)
#define WM_REPLACEALL_INOPENEDDOC	(SCINTILLA_USER + 6)
#define WM_FINDALL_INOPENEDDOC  	(SCINTILLA_USER + 7)
}
  WM_DOOPEN = (SCINTILLA_USER + 8);
{
#define WM_FINDINFILES			  	(SCINTILLA_USER + 9)
}

{ docking.h }
//   defines for docking manager
  CONT_LEFT = 0;
  CONT_RIGHT = 1;
  CONT_TOP = 2;
  CONT_BOTTOM = 3;
  DOCKCONT_MAX = 4;

// mask params for plugins of internal dialogs
  DWS_ICONTAB = 1; // Icon for tabs are available
  DWS_ICONBAR = 2; // Icon for icon bar are available (currently not supported)
  DWS_ADDINFO = 4; // Additional information are in use

// default docking values for first call of plugin
  DWS_DF_CONT_LEFT = CONT_LEFT shl 28;	        // default docking on left
  DWS_DF_CONT_RIGHT = CONT_RIGHT shl 28;	// default docking on right
  DWS_DF_CONT_TOP = CONT_TOP shl 28;	        // default docking on top
  DWS_DF_CONT_BOTTOM = CONT_BOTTOM shl 28;	// default docking on bottom
  DWS_DF_FLOATING = $80000000;			// default state is floating

{ dockingResource.h }
  DMN_FIRST = 1050;
  DMN_CLOSE = (DMN_FIRST + 1); //nmhdr.code = DWORD(DMN_CLOSE, 0)); //nmhdr.hwndFrom = hwndNpp; //nmhdr.idFrom = ctrlIdNpp;
  DMN_DOCK = (DMN_FIRST + 2);
  DMN_FLOAT = (DMN_FIRST + 3); //nmhdr.code = DWORD(DMN_XXX, int newContainer);	//nmhdr.hwndFrom = hwndNpp; //nmhdr.idFrom = ctrlIdNpp;


type
{$IFDEF NPPUNICODE}
  nppString = UnicodeString;
  nppChar = WChar;
  nppPChar = PWChar;
{$ELSE}
  nppString = AnsiString;
  nppChar = AnsiChar;
  nppPChar = PAnsiChar;
{$ENDIF}

  LangType = (L_TXT = 0, L_PHP , L_C, L_CPP, L_CS, L_OBJC, L_JAVA, L_RC,
    L_HTML, L_XML, L_MAKEFILE, L_PASCAL, L_BATCH, L_INI, L_NFO, L_USER,
    L_ASP, L_SQL, L_VB, L_JS, L_CSS, L_PERL, L_PYTHON, L_LUA,
    L_TEX, L_FORTRAN, L_BASH, L_FLASH, L_NSIS, L_TCL, L_LISP, L_SCHEME,
    L_ASM, L_DIFF, L_PROPS, L_PS, L_RUBY, L_SMALLTALK, L_VHDL, L_KIX, L_AU3,
    L_CAML, L_ADA, L_VERILOG, L_MATLAB, L_HASKELL, L_INNO, L_SEARCHRESULT, L_CMAKE,
    L_YAML, L_COBOL, L_GUI4CLI, L_D, L_POWERSHELL, L_R, L_JSP,
    // The end of enumated language type, so it should be always at the end
    L_END
  );

  TSessionInfo = record
    SessionFilePathName: nppString;
    NumFiles: Integer;
    Files: array of nppString;
  end;

  TToolbarIcons = record
    ToolbarBmp: HBITMAP;
    ToolbarIcon: HICON;
  end;

  TCommunicationInfo = record
    internalMsg: NativeUInt;
    srcModuleName: nppPChar;
    info: Pointer;
  end;

  TNppData = packed record
    nppHandle: HWND;
    nppScintillaMainHandle: HWND;
    nppScintillaSecondHandle: HWND;
  end;
  PNPPData = ^TNppData;

  TShortcutKey = packed record
    IsCtrl: Boolean;
    IsAlt: Boolean;
    IsShift: Boolean;
    Key: AnsiChar;
  end;
  PShortcutKey = ^TShortcutKey;

  PFUNCPLUGINCMD = procedure; cdecl;

  _TFuncItem = packed record
    ItemName: Array[0..FuncItemNameLen-1] of nppChar;
    Func: PFUNCPLUGINCMD;
    CmdID: Integer;
    Checked: LongBool;
    ShortcutKey: PShortcutKey;
  end;
  PFuncItem = ^_TFuncItem;

  TToolbarData = record
    ClientHandle: HWND;
    Title: nppPChar;
    DlgId: Integer;
    Mask: Cardinal;
    IconTab: HICON; // still dont know how to use this...
    AdditionalInfo: nppPChar;
    FloatRect: TRect;  // internal
    PrevContainer: Cardinal; // internal
    ModuleName:nppPChar; // name of module GetModuleFileName(0...)
  end;

  TNppPlugin = class(TObject)
  private
    FuncArray: array of _TFuncItem;
    FClosingBufferID: THandle;
    FConfigDir: string;
  protected
    PluginName: nppString;
    function SupportsBigFiles: Boolean;
    function HasV5Apis: Boolean;
    function HasFullRangeApis: Boolean;
    function GetApiLevel: TSciApiLevel;
    function GetNppVersion: Cardinal;
    function GetPluginsConfigDir: string;
    function AddFuncSeparator: Integer;
    function AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD): Integer; overload;
    function AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD; ShortcutKey: PShortcutKey): Integer; overload;
    function MakeShortcutKey(const Ctrl, Alt, Shift: Boolean; const AKey: AnsiChar): PShortcutKey;
  public
    NppData: TNppData;
    constructor Create;
    destructor Destroy; override;
    function CmdIdFromDlgId(DlgId: Integer): Integer;

    // needed for DLL export.. wrappers are in the main dll file.
    procedure SetInfo(NppData: TNppData); virtual;
    function GetName: nppPChar;
    function GetFuncsArray(var FuncsCount: Integer): Pointer;
    procedure BeNotified(sn: PSCNotification);
    procedure MessageProc(var Msg: TMessage); virtual;

    // hooks
    procedure DoNppnToolbarModification; virtual;
    procedure DoNppnShutdown; virtual;
    procedure DoNppnBufferActivated(const BufferID: THandle); virtual;
    procedure DoNppnFileClosed(const BufferID: THandle); virtual;
    procedure DoUpdateUI(const hwnd: HWND; const updated: Integer); virtual;
    procedure DoModified(const hwnd: HWND; const modificationType: Integer); virtual;

    // df
    function DoOpen(filename: String): boolean; overload;
    function DoOpen(filename: String; Line: Sci_Position): boolean; overload;
    procedure GetFileLine(var filename: String; var Line: Sci_Position);
    function GetWord: string;

    // helpers
    property ConfigDir: string  read GetPluginsConfigDir;
  end;


implementation

{ TNppPlugin }

constructor TNppPlugin.Create;
begin
  inherited;
end;

destructor TNppPlugin.Destroy;
var i: Integer;
begin
  for i:=0 to Length(self.FuncArray)-1 do
  begin
    if (self.FuncArray[i].ShortcutKey <> nil) then
    begin
      Dispose(self.FuncArray[i].ShortcutKey);
    end;
  end;
  inherited;
end;

function TNppPlugin.AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD): Integer;
var
  i: Integer;
begin
  i := Length(self.FuncArray);
  SetLength(self.FuncArray, i + 1);
  StrPLCopy(self.FuncArray[i].ItemName, Name, 1000);
  self.FuncArray[i].Func := Func;
  self.FuncArray[i].ShortcutKey := nil;
  Result := i;
end;

function TNppPlugin.AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD;
  ShortcutKey: PShortcutKey): Integer;
var
  i: Integer;
begin
  i := self.AddFuncItem(Name, Func);
  self.FuncArray[i].ShortcutKey := ShortcutKey;
  Result := i;
end;

function TNppPlugin.MakeShortcutKey(const Ctrl, Alt, Shift: Boolean; const AKey: AnsiChar): PShortcutKey;
begin
  Result := New(PShortcutKey);
  with Result^ do
  begin
    IsCtrl := Ctrl;
    IsAlt := Alt;
    IsShift := Shift;
    Key := AKey;
  end;
end;

function TNppPlugin.AddFuncSeparator: Integer;
begin
  Result := AddFuncItem('-', nil);
end;

procedure TNppPlugin.GetFileLine(var filename: String; var Line: Sci_Position);
var
  s: String;
  r: Sci_Position;
begin
  s := '';
  SetLength(s, 300);
  SendMessage(self.NppData.NppHandle, NPPM_GETFULLCURRENTPATH,0, LPARAM(PChar(s)));
  SetLength(s, StrLen(PChar(s)));
  filename := s;

  r := SendMessage(self.NppData.nppScintillaMainHandle, SCI_GETCURRENTPOS, 0, 0);
  Line := SendMessage(self.NppData.nppScintillaSecondHandle, SCI_LINEFROMPOSITION, r, 0);
end;

function TNppPlugin.GetFuncsArray(var FuncsCount: Integer): Pointer;
begin
  FuncsCount := Length(self.FuncArray);
  Result := self.FuncArray;
end;

function TNppPlugin.GetName: nppPChar;
begin
  Result := nppPChar(self.PluginName);
end;

function TNppPlugin.GetPluginsConfigDir: string;
begin
  if Length(FConfigDir) = 0 then begin
    SetLength(FConfigDir, 1001);
    SendMessage(self.NppData.NppHandle, NPPM_GETPLUGINSCONFIGDIR, 1000, LPARAM(PChar(FConfigDir)));
    SetString(FConfigDir, PChar(FConfigDir), StrLen(PChar(FConfigDir)));
  end;
  Result := FConfigDir;
end;

procedure TNppPlugin.BeNotified(sn: PSCNotification);
begin
  try
    if HWND(sn^.nmhdr.hwndFrom) = self.NppData.NppHandle then begin
      case sn.nmhdr.code of
        NPPN_TB_MODIFICATION: begin
          self.DoNppnToolbarModification;
        end;
        NPPN_SHUTDOWN: begin
          self.DoNppnShutdown;
        end;
        NPPN_BUFFERACTIVATED: begin
          self.DoNppnBufferActivated(sn.nmhdr.idFrom);
        end;
        NPPN_FILEBEFORECLOSE: begin
          FClosingBufferID := SendMessage(HWND(sn.nmhdr.hwndFrom), NPPM_GETCURRENTBUFFERID, 0, 0);
        end;
        NPPN_FILECLOSED: begin
          self.DoNppnFileClosed(FClosingBufferID);
        end;
      end;
    end else begin
      case sn.nmhdr.code of
        SCN_MODIFIED: begin
          Self.DoModified(HWND(sn.nmhdr.hwndFrom), sn.modificationType);
        end;
        SCN_UPDATEUI: begin
          self.DoUpdateUI(HWND(sn.nmhdr.hwndFrom), sn.updated);
        end;
      end;
    end;
  except
    on E: Exception do begin
      OutputDebugString(PWideChar(WideFormat('%s> %s: "%s"', [PluginName, E.ClassName, E.Message])));
    end;
  end;
end;

{$REGION 'Overrides'}
procedure TNppPlugin.MessageProc(var Msg: TMessage);
begin
  Dispatch(Msg);
end;

procedure TNppPlugin.SetInfo(NppData: TNppData);
begin
  self.NppData := NppData;
end;

procedure TNppPlugin.DoNppnShutdown;
begin
  // override these
end;

procedure TNppPlugin.DoNppnToolbarModification;
begin
  // override these
end;

procedure TNppPlugin.DoNppnBufferActivated(const BufferID: THandle);
begin
  // override these
end;

procedure TNppPlugin.DoNppnFileClosed(const BufferID: THandle);
begin
  // override these
end;

procedure TNppPlugin.DoModified(const hwnd: HWND; const modificationType: Integer);
begin
  // override these
end;

procedure TNppPlugin.DoUpdateUI(const hwnd: HWND; const updated: Integer);
begin
  // override these
end;
{$ENDREGION}

function TNppPlugin.GetWord: string;
var
  s: string;
begin
  s := '';
  SetLength(s, 800);
  SendMessage(self.NppData.NppHandle, NPPM_GETCURRENTWORD, 0, LPARAM(PChar(s)));
  Result := s;
end;

function TNppPlugin.DoOpen(filename: String): Boolean;
var
  r: Integer;
  s: string;
begin
  // ask if we are not already opened
  s := '';
  SetLength(s, 500);
  r := SendMessage(self.NppData.NppHandle, NPPM_GETFULLCURRENTPATH, 0,
    LPARAM(PChar(s)));
  SetString(s, PChar(s), StrLen(PChar(s)));
  Result := true;
  if (s = filename) then
    exit;
  r := SendMessage(self.NppData.NppHandle, WM_DOOPEN, 0,
    LPARAM(PChar(filename)));
  Result := (r = 0);
end;

function TNppPlugin.DoOpen(filename: String; Line: Sci_Position): Boolean;
var
  r: Boolean;
begin
  r := self.DoOpen(filename);
  if (r) then
    SendMessage(self.NppData.nppScintillaMainHandle, SCI_GOTOLINE, Line, 0);
  Result := r;
end;

function TNppPlugin.CmdIdFromDlgId(DlgId: Integer): Integer;
begin
  Result := self.FuncArray[DlgId].CmdId;
end;

function TNppPlugin.GetApiLevel: TSciApiLevel;
begin
  if (not self.HasV5Apis) then
    Result := sciApi_LT_5
  else if (not self.HasFullRangeApis) then
    Result := sciApi_GTE_515
  else
    Result := sciApi_GTE_523;
end;

function TNppPlugin.GetNppVersion: Cardinal;
var
  NppVersion: Cardinal;
begin
  NppVersion := SendMessage(self.NppData.NppHandle, NPPM_GETNPPVERSION, 0, 0);
  // retrieve the zero-padded version, if available
  // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/ef609c896f209ecffd8130c3e3327ca8a8157e72
  if ((HIWORD(NppVersion) > 8) or
      ((HIWORD(NppVersion) = 8) and
        (((LOWORD(NppVersion) >= 41) and (not (LOWORD(NppVersion) in [191, 192, 193]))) or
          (LOWORD(NppVersion) in [5, 6, 7, 8, 9])))) then
    NppVersion := SendMessage(self.NppData.NppHandle, NPPM_GETNPPVERSION, 1, 0);

  Result := NppVersion;
end;

function TNppPlugin.SupportsBigFiles: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
      // 8.3 => 8,3 *not* 8,30
      ((LOWORD(NppVersion) in [3, 4]) or
       // Also check for N++ versions 8.1.9.1, 8.1.9.2 and 8.1.9.3
       ((LOWORD(NppVersion) > 21) and (not (LOWORD(NppVersion) in [191, 192, 193])))));
end;

function TNppPlugin.HasV5Apis: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
        ((LOWORD(NppVersion) >= 4) and
           (not (LOWORD(NppVersion) in [11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 31, 32, 33, 191, 192, 193]))));
end;

function TNppPlugin.HasFullRangeApis: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
       ((LOWORD(NppVersion) >= 43) and (not (LOWORD(NppVersion) in [191, 192, 193]))));
end;

end.
