library HTMLTag;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

uses
  SysUtils,
  Classes,
  Types,
  Windows,
  Messages,
  U_Npp_HTMLTag in '..\U_Npp_HTMLTag.pas',
  L_VersionInfoW in '..\common\L_VersionInfoW.pas',
  L_SpecialFolders in '..\common\L_SpecialFolders.pas',
  RegExpr in '..\common\RegExpr.pas',
  NppSimpleObjects in '..\LibNppPlugin\NppSimpleObjects.pas',
  NppPluginInterface in '..\LibNppPlugin\NppPluginInterface.pas',
  nppplugin in '..\lib\nppplugin.pas',
  SciSupport in '..\lib\SciSupport.pas';

{$R *.res}

{$Include '..\lib\NppPluginInclude.pas'}

begin
  { First, assign the procedure to the DLLProc variable }
  DllProc := @DLLEntryPoint;
  { Now invoke the procedure to reflect that the DLL is attaching to the process }
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
