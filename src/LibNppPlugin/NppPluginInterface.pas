unit NppPluginInterface;

interface
  uses
    Windows, SciSupport;

  type
{$IFNDEF NPP_ANSI}
    nppString = WideString;
    nppChar   = WChar;
    nppPChar  = PWChar;
{$ELSE}
    nppString = AnsiString;
    nppChar   = AnsiChar;
    nppPChar  = PAnsiChar;
{$ENDIF}

{ ----------------------------------- Notepad++ types -------------------------------------------- }
    RNppData = packed record
      nppHandle: hWnd;
      nppScintillaMainHandle: hWnd;
      nppScintillaSecondHandle: hWnd;
    end;
    PNPPData = ^RNppData;

    TFuncGetName = function(): nppPChar; cdecl;
    PFuncGetName = ^TFuncGetName;

    TFuncSetInfo = procedure(NppData: RNppData); cdecl;
    PFuncSetInfo = ^TFuncSetInfo;

    TFuncPluginCmd = procedure(); cdecl;
    PFuncPluginCmd = ^TFuncPluginCmd;

    TBeNotified = procedure(SCNotification: PScNotification); cdecl;
    PBeNotified = ^TBeNotified;

    TMessageProc = function(Message: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; cdecl;
    PMessageProc = ^TMessageProc;

    RShortcutKey = packed record
      isCtrl: boolean;
      isAlt: boolean;
      isShift: boolean;
      key: UChar;
    end;
    PShortcutKey = ^RShortcutKey;

    RFuncItem = packed record
      itemName: array[0..63] of nppChar;
      pFunc: TFuncPluginCmd;
      cmdID: integer;
      init2Check: LongBool;
      pShKey: PShortcutKey;
    end;
    PFuncItem = ^RFuncItem;

    TFuncGetFuncsArray = function(var count: integer): PFuncItem; cdecl;
    PFuncGetFuncsArray = ^TFuncGetFuncsArray;

    RSessionInfo = record
      sessionFilePathName: nppString;
      nbFile: integer;
      files: array of nppString;
    end;

    RToolbarIcon = record
      hToolbarBmp: HBITMAP;
      hToolbarIcon: HICON;
    end;

    (*
    // You should implement (or define an empty function body) those functions which are called by Notepad++ plugin manager
    procedure setInfo(ANppData: RNppData); cdecl;
    function  getName(): PChar; cdecl;
    function  getFuncsArray(var ACount: integer): PFuncItem; cdecl;
    procedure beNotified(ASCNotification: PSCNotification); cdecl;
    function  messageProc(AMessage: UINT; AWParam: WPARAM; ALParam: LPARAM): LRESULT;
    *)

implementation

end.

