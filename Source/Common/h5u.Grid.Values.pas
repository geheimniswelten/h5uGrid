unit h5u.Grid.Values;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Rtti,
    SysUtils,
    TypInfo,
  {$ELSE}
    System.Rtti,
    System.SysUtils,
    System.TypInfo,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

// Value conversion and cell-event precedence shared by all control adapters.
type
  Th5uGetCellValueMethod = function(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): TValue of object;
  Th5uGetViewValueMethod = function(ARow: Int64; const AFieldName: string): TValue of object;
  Th5uGetViewTextMethod = function(ARow: Int64; const AFieldName, ADisplayFormat: string): string of object;

function h5uParseEditorValue(ADataType: Th5uColumnDataType; const AText: string): TValue;
function h5uColumnMode(AColumn: Th5uGridColumn; AController: TObject; const ATreeColumnId, AGroupColumnId, AStyleColumnId, AHintColumnId: string): string;
function h5uColumnModeSymbols(const AMode: string): string;
function h5uCellPermission(AGrid: TObject; AColumn: Th5uGridColumn; ARow: Int64; AAllow: Boolean; AColumnEvent, AGridEvent: Th5uCellPermissionEvent): Boolean;
procedure h5uOverrideCellValue(AGrid: TObject; AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean; AGridEvent: Th5uCellGetValueEvent; var AValue: TValue);
function h5uCellText(AColumn: Th5uGridColumn; ARow: Int64; ADisplay, AHasValueEvent: Boolean; AGetCellValue: Th5uGetCellValueMethod; AGetViewValue: Th5uGetViewValueMethod;
  AGetViewText: Th5uGetViewTextMethod): string;
function h5uPrepareCellValue(AGrid: TObject; AColumn: Th5uGridColumn; ARow: Int64; const AValue: TValue; AValidate: Th5uCellValidateEvent;
  ASetValue: Th5uCellSetValueEvent): TValue;
procedure h5uNotifyCellClick(AGrid: TObject; AColumn: Th5uGridColumn; ARow: Int64; AHeader, AIndicator: Boolean; ACellClick, AHeaderClick, AIndicatorClick: Th5uCellEvent);

implementation

function h5uParseEditorValue(ADataType: Th5uColumnDataType; const AText: string): TValue;
var
  LInteger: Int64;
  LFloat: Double;
  LCurrency: Currency;
  LDateTime: TDateTime;
begin
  case ADataType of
    Th5uColumnDataType.Integer:
      begin
        if not TryStrToInt64(AText, LInteger) then
          raise EConvertError.CreateFmt('"%s" ist keine ganze Zahl.', [AText]);
        Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<Int64>(LInteger);
      end;

    Th5uColumnDataType.Float:
      begin
        if not TryStrToFloat(AText, LFloat) then
          raise EConvertError.CreateFmt('"%s" ist keine Zahl.', [AText]);
        Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<Double>(LFloat);
      end;

    Th5uColumnDataType.Currency:
      begin
        if not TryStrToCurr(AText, LCurrency) then
          raise EConvertError.CreateFmt('"%s" ist kein gültiger Betrag.', [AText]);
        Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<Currency>(LCurrency);
      end;

    Th5uColumnDataType.Time:
      begin
        if not TryStrToTime(AText, LDateTime) then
          raise EConvertError.CreateFmt('"%s" ist keine gültige Uhrzeit.', [AText]);
        Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<TDateTime>(LDateTime);
      end;

    Th5uColumnDataType.Date,
    Th5uColumnDataType.DateTime:
      begin
        if not TryStrToDateTime(AText, LDateTime) then
          raise EConvertError.CreateFmt('"%s" ist kein gültiges Datum.', [AText]);
        Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<TDateTime>(LDateTime);
      end;

    else
      Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>(AText);
  end;
end;

function h5uColumnMode(AColumn: Th5uGridColumn; AController: TObject; const ATreeColumnId, AGroupColumnId, AStyleColumnId, AHintColumnId: string): string;
var
  LKey: string;
  procedure Add(const AToken: string);
  begin
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + AToken;
  end;
begin
  Result := '';
  if not Assigned(AColumn) then
    Exit;
  LKey := '';
  if Assigned(AController) then
    if IsPublishedProp(AController, 'KeyFieldName') then
      LKey := GetStrProp(AController, 'KeyFieldName')
    else if IsPublishedProp(AController, 'KeyPropertyName') then
      LKey := GetStrProp(AController, 'KeyPropertyName');
  if (LKey <> '') and SameText(AColumn.FieldName, LKey) then
    Add('KeyField');
  if (ATreeColumnId <> '') and SameText(AColumn.Id, ATreeColumnId) then
    Add('TreeLevel');
  if (AGroupColumnId <> '') and SameText(AColumn.Id, AGroupColumnId) then
    Add('GroupId');
  if (AStyleColumnId <> '') and SameText(AColumn.Id, AStyleColumnId) then
    Add('StyleKey');
  if (AHintColumnId <> '') and SameText(AColumn.Id, AHintColumnId) then
    Add('ScrollHint');
end;

function h5uColumnModeSymbols(const AMode: string): string;
var
  LMode: string;
begin
  Result := '';
  LMode := ' ' + AMode + ' ';
  if Pos(' KeyField ',   LMode) > 0 then Result := Result + #$26BF;
  if Pos(' TreeLevel ',  LMode) > 0 then Result := Result + #$21B3;
  if Pos(' GroupId ',    LMode) > 0 then Result := Result + #$2261;
  if Pos(' StyleKey ',   LMode) > 0 then Result := Result + #$25C6;
  if Pos(' ScrollHint ', LMode) > 0 then Result := Result + #$2195;
end;

function h5uCellPermission(AGrid: TObject; AColumn: Th5uGridColumn; ARow: Int64; AAllow: Boolean; AColumnEvent, AGridEvent: Th5uCellPermissionEvent): Boolean;
begin
  Result := AAllow;
  if Assigned(AColumnEvent) then
    AColumnEvent(AColumn, AColumn, ARow, Result);
  if Assigned(AGridEvent) then
    AGridEvent(AGrid, AColumn, ARow, Result);
end;

procedure h5uOverrideCellValue(AGrid: TObject; AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean; AGridEvent: Th5uCellGetValueEvent; var AValue: TValue);
begin
  if Assigned(AColumn.OnGetValue) then
    AColumn.OnGetValue(AColumn, AColumn, ARow, AValue, ADisplay)
  else if Assigned(AGridEvent) then
    AGridEvent(AGrid, AColumn, ARow, AValue, ADisplay);
end;

function h5uCellText(AColumn: Th5uGridColumn; ARow: Int64; ADisplay, AHasValueEvent: Boolean; AGetCellValue: Th5uGetCellValueMethod; AGetViewValue: Th5uGetViewValueMethod; AGetViewText: Th5uGetViewTextMethod): string;
begin
  if AHasValueEvent then
  begin
    if ADisplay then
      Result := h5uValueToDisplayText(AGetCellValue(AColumn, ARow, True), AColumn.DisplayFormat)
    else
      Result := h5uValueToDisplayText(AGetCellValue(AColumn, ARow, False));
  end
  else if ADisplay then
    Result := AGetViewText(ARow, AColumn.FieldName, AColumn.DisplayFormat)
  else
    Result := h5uValueToDisplayText(AGetViewValue(ARow, AColumn.FieldName));
end;

function h5uPrepareCellValue(AGrid: TObject; AColumn: Th5uGridColumn; ARow: Int64; const AValue: TValue; AValidate: Th5uCellValidateEvent; ASetValue: Th5uCellSetValueEvent): TValue;
var
  LValue: TValue;
  LValid: Boolean;
  LError: string;
begin
  LValue := AValue;
  LValid := True;
  LError := '';
  if Assigned(AColumn.OnValidate) then
    AColumn.OnValidate(AColumn, AColumn, ARow, LValue, LValid, LError)
  else if Assigned(AValidate) then
    AValidate(AGrid, AColumn, ARow, LValue, LValid, LError);
  if not LValid then
  begin
    if LError = '' then
      LError := 'Invalid cell value';
    raise EConvertError.Create(LError);
  end;
  if Assigned(AColumn.OnSetValue) then
    AColumn.OnSetValue(AColumn, AColumn, ARow, LValue)
  else if Assigned(ASetValue) then
    ASetValue(AGrid, AColumn, ARow, LValue);
  Result := LValue;
end;

procedure h5uNotifyCellClick(AGrid: TObject; AColumn: Th5uGridColumn; ARow: Int64; AHeader, AIndicator: Boolean; ACellClick, AHeaderClick, AIndicatorClick: Th5uCellEvent);
begin
  if AIndicator then
  begin
    if Assigned(AIndicatorClick) then
      AIndicatorClick(AGrid, nil, ARow);
  end
  else
  if Assigned(AColumn) then
    if AHeader then
    begin
      if Assigned(AColumn.OnColumnHeaderClick) then
        AColumn.OnColumnHeaderClick(AColumn, AColumn, -1);
      if Assigned(AHeaderClick) then
        AHeaderClick(AGrid, AColumn, -1);
    end
    else
    begin
      if Assigned(AColumn.OnCellClick) then
        AColumn.OnCellClick(AColumn, AColumn, ARow);
      if Assigned(ACellClick) then
        ACellClick(AGrid, AColumn, ARow);
    end;
end;

end.

