program TestEditorPackageUnload;

{$APPTYPE CONSOLE}

uses
  // Keep framework runtimes loaded, matching the IDE package-unload environment.
  System.SysUtils, Winapi.Windows, Vcl.Controls, FMX.Controls, h5u.Grid.Types, h5u.Grid.Editors;

function EditorRegistered(APlatform: ThiiEditorPlatform; const AName: string): Boolean;
begin
  try
    Result := h5uEditorClass(APlatform, AName) <> nil;
  except
    on E: EhiiGrid do
      Result := False;
  end;
end;

procedure TestPackage(const AFile: string; APlatform: ThiiEditorPlatform);
const
  CNames: array[0..9] of string = ('TextEditor', 'IntegerEditor', 'FloatEditor', 'CurrencyEditor',
    'DateEditor', 'TimeEditor', 'DateTimeEditor', 'CheckBoxEditor', 'ImageEditor', 'CustomEditor');
var
  Handle: HMODULE;
  Name: string;
  Pass: Integer;
begin
  for Pass := 1 to 2 do
  begin
    Handle := LoadPackage(AFile);
    try
      for Name in CNames do
        if h5uEditorClass(APlatform, Name) = nil then
          raise Exception.Create('Editor not registered after load: ' + Name);
      // Finalization must tolerate already removed entries and preserve replacements.
      h5uUnregisterEditor(APlatform, 'TextEditor');
      h5uRegisterEditor(APlatform, 'CustomEditor', ThiiGridEditorItem);
    finally
      UnloadPackage(Handle);
    end;
    for Name in CNames do
      if Name <> 'CustomEditor' then
        if EditorRegistered(APlatform, Name) then
          raise Exception.Create('Dangling editor class after package unload: ' + Name);
    if h5uEditorClass(APlatform, 'CustomEditor') <> ThiiGridEditorItem then
      raise Exception.Create('Replacement registration removed during unload');
    h5uUnregisterEditor(APlatform, 'CustomEditor');
  end;
  Writeln('PASS: ', AFile, ' editor registration, unload cleanup and reload');
end;

begin
  try
    TestPackage(ExtractFilePath(ParamStr(0)) + 'h5uGridVcl370.bpl', ThiiEditorPlatform.VCL);
    TestPackage(ExtractFilePath(ParamStr(0)) + 'h5uGridFmx370.bpl', ThiiEditorPlatform.FMX);
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
