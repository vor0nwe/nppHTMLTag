unit L_TaskbarList;

interface

uses
  Windows;

type
  THUMBBUTTON = record
    dwMask: DWORD;
    iId: UINT;
    iBitmap: UINT;
    hIcon: HICON;
    szTip: packed array[0..259] of WCHAR;
    dwFlags: DWORD;
  end;

  TThumbButton = THUMBBUTTON;
  PThumbButton = ^TThumbButton;

const
  THBF_ENABLED        =  $0000;
  THBF_DISABLED       =  $0001;
  THBF_DISMISSONCLICK =  $0002;
  THBF_NOBACKGROUND   =  $0004;
  THBF_HIDDEN         =  $0008;
  THBF_NONINTERACTIVE = $10;

// THUMBBUTTON mask
  THB_BITMAP          =  $0001;
  THB_ICON            =  $0002;
  THB_TOOLTIP         =  $0004;
  THB_FLAGS           =  $0008;
  THBN_CLICKED        =  $1800;


const
  SID_ITaskbarList  = '{56FDF342-FD6D-11D0-958A-006097C9A090}';
  SID_ITaskbarList2 = '{602D4995-B13A-429B-A66E-1935E44F4317}';
  SID_ITaskbarList3 = '{EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}';
  SID_ITaskbarList4 = '{C43DC798-95D1-4BEA-9030-BB99E2983A1A}';

const
  IID_ITaskbarList: TGUID = SID_ITaskbarList;
  IID_ITaskbarList2: TGUID = SID_ITaskbarList2;
  IID_ITaskbarList3: TGUID = SID_ITaskbarList3;
  IID_ITaskbarList4: TGUID = SID_ITaskbarList4;
  CLSID_TaskbarList: TGUID = '{56FDF344-FD6D-11D0-958A-006097C9A090}';

const
  TBPF_NOPROGRESS    = $0;
  TBPF_INDETERMINATE = $1;
  TBPF_NORMAL        = $2;
  TBPF_ERROR         = $4;
  TBPF_PAUSED        = $8;

  TBATF_USEMDITHUMBNAIL   = $1;
  TBATF_USEMDILIVEPREVIEW = $2;

type
  STPFLAG = Integer;

type
   ITaskbarList = interface(IUnknown)
      [SID_ITaskbarList]
      function HrInit: HResult; stdcall;
      function AddTab(hWndOwner: HWND): HResult; stdcall;
      function DeleteTab(hWndOwner: HWND): HResult; stdcall;
      function ActivateTab(hWndOwner: HWND): HResult; stdcall;
      function SetActiveAlt(hWndOwner: HWND): HResult; stdcall;
   end; { ITaskbarList }

  ITaskbarList2 = interface(ITaskbarList)
    [SID_ITaskbarList2]
    function MarkFullscreenWindow(wnd: HWND; fFullscreen: Bool): HResult; stdcall;
  end;

  type
    ITaskbarList3 = interface(ITaskbarList2)
      [SID_ITaskbarList3]
      function SetProgressValue(hwnd: HWND; ullCompleted: ULONGLONG;
        ullTotal: ULONGLONG): HRESULT; stdcall;
      function SetProgressState(hwnd: HWND; tbpFlags: Integer): HRESULT; stdcall;
      function RegisterTab(hwndTab: HWND; hwndMDI: HWND): HRESULT; stdcall;
      function UnregisterTab(hwndTab: HWND): HRESULT; stdcall;
      function SetTabOrder(hwndTab: HWND; hwndInsertBefore: HWND): HRESULT; stdcall;
      function SetTabActive(hwndTab: HWND; hwndMDI: HWND;
        tbatFlags: Integer): HRESULT; stdcall;
      function ThumbBarAddButtons(hwnd: HWND; cButtons: UINT;
        pButton: PThumbButton): HRESULT; stdcall;
      function ThumbBarUpdateButtons(hwnd: HWND; cButtons: UINT;
        pButton: PThumbButton): HRESULT; stdcall;
      function ThumbBarSetImageList(hwnd: HWND; himl: THandle): HRESULT; stdcall;
      function SetOverlayIcon(hwnd: HWND; hIcon: HICON;
        pszDescription: LPCWSTR): HRESULT; stdcall;
      function SetThumbnailTooltip(hwnd: HWND; pszTip: LPCWSTR): HRESULT; stdcall;
      function SetThumbnailClip(hwnd: HWND; var prcClip: TRect): HRESULT; stdcall;
    end;

  ITaskbarList4 = interface(ITaskbarList3)
    [SID_ITaskbarList4]
    function SetTabProperties(hwndTab: HWND; stpFlags: STPFLAG): HResult; stdcall;
  end;

  function CreateTaskbarList(): ITaskbarList;

implementation
uses
  ComObj;

{ ------------------------------------------------------------------------------------------------ }
function CreateTaskbarList(): ITaskbarList;
begin
  Result := CreateComObject(CLSID_TaskbarList) as ITaskbarList;
  Result.HrInit;
end;

end.
