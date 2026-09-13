unit h5u.Grid.Compat;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ELSE DELPHI}
  // none
{$ENDIF}

interface

{$IFDEF FPC}

uses
  Rtti, SysUtils, TypInfo, Variants;

type
  // Framework-neutral storage types. The core has no LCL/widgetset dependency.
  TColor = LongInt;
  TAlphaColor = LongWord;
  TMouseButton = (mbLeft, mbRight, mbMiddle, mbExtra1, mbExtra2);
  TFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);
  TFontStyles = set of TFontStyle;

  TColorRec = record
  const
    SysDefault = TColor($20000000);
    Lightgray = TColor($D3D3D3);
  end;

const
  vkPrior = $21;
  vkNext = $22;
  vkEnd = $23;
  vkHome = $24;
  vkLeft = $25;
  vkUp = $26;
  vkRight = $27;
  vkDown = $28;
  vkF2 = $71;

type
  // FPC 3.2.2 has TValue.From/IsType, but lacks Delphi's AsType/AsVariant.
  Th5uValueHelper = record helper for TValue
    generic function AsType<T>: T;
    function AsVariant: Variant;
  end;

// FPC 3.2.2 cannot construct a TValue with tkVariant. Normalize scalar variants.
function h5uValueFromVariant(const AValue: Variant): TValue;
function h5uValueAsText(const AValue: TValue): string;
function h5uGetPropertyValue(AObject: TObject; AProperty: TRttiProperty): TValue;
procedure h5uSetPropertyValue(AObject: TObject; AProperty: TRttiProperty; const AValue: TValue);

{$ELSE DELPHI}

// none

{$ENDIF}

implementation

{$IFDEF FPC}

function h5uValueAsText(const AValue: TValue): string;
var
  LBytes: RawByteString;
begin
  case AValue.Kind of
    tkFloat:
      Result := FloatToStr(AValue.AsExtended);
    tkWString, tkUString:
      Result := UTF8Encode(AValue.AsUnicodeString);
    tkAString, tkSString:
    begin
      LBytes := AValue.AsString;
      // ObjFPC string values from RTTI/generic literals can lose their codepage tag.
      // Common follows Lazarus' UTF-8 string convention, without changing global RTL settings.
      if ((StringCodePage(LBytes) = 0) or (StringCodePage(LBytes) = $FFFF)) then
        SetCodePage(LBytes, CP_UTF8, False);
      Result := UTF8Encode(UnicodeString(LBytes));
    end;
    else
      Result := AValue.ToString;
  end;
end;

function h5uGetPropertyValue(AObject: TObject; AProperty: TRttiProperty): TValue;
var
  LPropInfo: PPropInfo;
  LText: string;
  LVariant: Variant;
begin
  LPropInfo := GetPropInfo(AObject, AProperty.Name);
  case LPropInfo^.PropType^.Kind of
    tkWString, tkUString:
    begin
      LText := UTF8Encode(GetUnicodeStrProp(AObject, LPropInfo));
      Result := TValue.specialize From<string>(LText);
    end;
    tkVariant:
    begin
      LVariant := GetVariantProp(AObject, LPropInfo);
      Result := h5uValueFromVariant(LVariant);
    end;
    else
      Result := AProperty.GetValue(AObject);
  end;
end;

procedure h5uSetPropertyValue(AObject: TObject; AProperty: TRttiProperty; const AValue: TValue);
var
  LPropInfo: PPropInfo;
begin
  LPropInfo := GetPropInfo(AObject, AProperty.Name);
  case LPropInfo^.PropType^.Kind of
    tkSString, tkAString: SetStrProp(AObject, LPropInfo, h5uValueAsText(AValue));
    tkWString, tkUString: SetUnicodeStrProp(AObject, LPropInfo, UTF8Decode(h5uValueAsText(AValue)));
    tkVariant: SetVariantProp(AObject, LPropInfo, AValue.AsVariant);
    else AProperty.SetValue(AObject, AValue);
  end;
end;

function h5uValueFromVariant(const AValue: Variant): TValue;
var
  LType: TVarType;
begin
  if VarIsEmpty(AValue) or VarIsNull(AValue) then
    Exit(TValue.Empty);
  LType := VarType(AValue) and varTypeMask;
  if VarIsArray(AValue) then
    raise EVariantTypeCastError.Create('Variant arrays are not supported as grid cell values.');
  case LType of
    varBoolean: Result := TValue.specialize From<Boolean>(Boolean(AValue));
    varShortInt, varByte, varSmallint, varWord, varInteger: Result := TValue.specialize From<Integer>(Integer(AValue));
    varLongWord, varInt64: Result := TValue.specialize From<Int64>(Int64(AValue));
    varQWord: Result := TValue.specialize From<QWord>(QWord(AValue));
    varSingle, varDouble: Result := TValue.specialize From<Double>(Double(AValue));
    varCurrency: Result := TValue.specialize From<Currency>(Currency(AValue));
    varDate: Result := TValue.specialize From<TDateTime>(TDateTime(AValue));
    varString: Result := TValue.specialize From<string>(string(AValue));
    varOleStr, varUString: Result := TValue.specialize From<string>(UTF8Encode(UnicodeString(AValue)));
    else raise EVariantTypeCastError.Create('Unsupported Variant type for a grid cell value.');
  end;
end;

generic function Th5uValueHelper.AsType<T>: T;
begin
  Result := Default(T);
  if not IsType(System.TypeInfo(T)) then
    raise EInvalidCast.Create('TValue type does not match the requested type.');
  ExtractRawData(@Result);
end;

function Th5uValueHelper.AsVariant: Variant;
begin
  Result := Null;
  if IsEmpty then
    Exit;
  case Kind of
    tkVariant:
      ExtractRawData(@Result);
    tkBool:
      Result := AsBoolean;
    tkInteger, tkInt64, tkEnumeration:
      Result := AsOrdinal;
    tkQWord:
      Result := AsUInt64;
    tkFloat:
      if TypeInfo = System.TypeInfo(TDateTime) then
        Result := VarFromDateTime(AsExtended)
      else if TypeData^.FloatType = ftCurr then
        Result := AsCurrency
      else
        Result := Double(AsExtended);
    tkSString, tkAString, tkWString, tkUString:
      Result := UTF8Decode(h5uValueAsText(Self));
    else
      raise EInvalidCast.Create('TValue cannot be represented by a scalar Variant.');
  end;
end;

{$ELSE DELPHI}

// none

{$ENDIF}

end.
