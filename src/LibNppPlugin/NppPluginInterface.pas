unit NppPluginInterface;

interface
  uses
    Windows, nppplugin;

  type
    TFuncGetName = function(): nppPChar; cdecl;
    PFuncGetName = ^TFuncGetName;

    TFuncSetInfo = procedure(NppData: TNppData); cdecl;
    PFuncSetInfo = ^TFuncSetInfo;

    TMessageProc = function(Message: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; cdecl;
    PMessageProc = ^TMessageProc;

    TFuncGetFuncsArray = function(var count: integer): PFuncItem; cdecl;
    PFuncGetFuncsArray = ^TFuncGetFuncsArray;

implementation

end.

