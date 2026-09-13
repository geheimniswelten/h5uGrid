program TestFpcCompatibility;

{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$SCOPEDENUMS ON}
{$CODEPAGE UTF8}

uses
  Classes, SysUtils, Variants, Rtti, Types, DB,
  h5u.Grid.Compat, h5u.Grid.Types, h5u.Grid.Factory,
  h5u.Grid.Selection, h5u.Grid.Columns, h5u.Grid.Options,
  h5u.Grid.AdjacentGroups, h5u.Grid.Editors, h5u.Grid.Values,
  h5u.Grid.Moving, h5u.Grid.Resizing, h5u.Grid.Navigation,
  h5u.Grid.View, h5u.Grid.Layout, h5u.Grid.RowMetrics,
  h5u.Grid.Data.Core, h5u.Grid.Data.Dataset, h5u.Grid.Data.Memory,
  h5u.Grid.Data.Objects, h5u.Grid.Data.Virtual, h5u.Grid.SampleData;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

type
  TRow = class(TPersistent)
  private
    FId: Integer;
    FText: string;
    FActive: Boolean;
    FPrice: Currency;
    FDate: TDateTime;
    FChild: TRow;
    FUnicode: UnicodeString;
    FVariant: Variant;
  published
    property Id: Integer read FId write FId;
    property Text: string read FText write FText;
    property Active: Boolean read FActive write FActive;
    property Price: Currency read FPrice write FPrice;
    property Date: TDateTime read FDate write FDate;
    property Child: TRow read FChild write FChild;
    property UnicodeText: UnicodeString read FUnicode write FUnicode;
    property VariantValue: Variant read FVariant write FVariant;
    property ReadOnlyText: string read FText;
  end;

  TVirtualEvents = class
    Reads: Integer;
    Changes: Integer;
    Stored: string;
    procedure RowCount(Sender: TObject; var ACount: Int64);
    procedure GetValue(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
    procedure SetValue(Sender: TObject; ARow: Int64; const AField: string; const AValue: TValue; var AHandled: Boolean);
    procedure Changed(Sender: TObject; const AChange: Th5uDataChange);
  end;

procedure TVirtualEvents.RowCount(Sender: TObject; var ACount: Int64);
begin
  ACount := 3;
end;

procedure TVirtualEvents.GetValue(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
begin
  Inc(Reads);
  AValue := Stored;
end;

procedure TVirtualEvents.SetValue(Sender: TObject; ARow: Int64; const AField: string; const AValue: TValue; var AHandled: Boolean);
begin
  Stored := AValue.AsString;
  AHandled := True;
end;

procedure TVirtualEvents.Changed(Sender: TObject; const AChange: Th5uDataChange);
begin
  Inc(Changes);
end;

procedure TestValues;
var
  V: TValue;
  B, CopyBytes: TBytes;
  A: Variant;
  I: Integer;
  S: string;
begin
  S := 'Grüße 東京';
  V := TValue.specialize From<string>(S);
  Check(h5uValueToDisplayText(V) = S, 'UTF-8 display');
  A := Null;
  V := h5uValueFromVariant(A);
  Check(h5uValueToDisplayText(V) = '', 'NULL variant display');
  A := S;
  V := h5uValueFromVariant(A);
  Check(h5uValueToDisplayText(V) = S, 'Variant text display');
  V := TValue.specialize From<Boolean>(True);
  Check(h5uTryValueAsInteger(V, I) and (I = 1), 'FPC boolean to integer');
  B := TBytes.Create(0, 127, 128, 255);
  V := TValue.specialize From<TBytes>(B);
  B := nil;
  CopyBytes := V.specialize AsType<TBytes>;
  V := TValue.Empty;
  Check((Length(CopyBytes) = 4) and (CopyBytes[3] = 255), 'managed TValue byte lifetime');
  Writeln('PASS: FPC UTF-8, variants, booleans and managed TValue data');
end;

procedure TestObjects;
var
  C: Th5uObjectListController;
  R, Child: TRow;
  V: TValue;
begin
  C := Th5uObjectListController.Create(nil);
  R := TRow.Create;
  Child := TRow.Create;
  try
    R.Id := 7;
    R.Text := 'Grüße 東京';
    R.Child := Child;
    C.Add(R);
    C.KeyPropertyName := 'Id';
    Check(C.GetRowKey(0).ToString = '7', 'published row key');
    Check(C.GetValue(0, 'Text').AsString = R.Text, 'published UTF-8 property');
    Check(C.CanEdit(0, 'Child.Text') and not C.CanEdit(0, 'ReadOnlyText'), 'nested and read-only RTTI');
    C.SetValue(0, 'Child.Text', TValue.specialize From<string>('Änderung 東京'));
    Check(Child.Text = 'Änderung 東京', 'nested RTTI write');
    C.SetValue(0, 'UnicodeText', TValue.specialize From<string>('Änderung 東京'));
    Check(R.UnicodeText = UnicodeString('Änderung 東京'), 'UnicodeString RTTI write');
    Check(C.GetValue(0, 'UnicodeText').AsString = 'Änderung 東京', 'UnicodeString RTTI read');
    C.SetValue(0, 'VariantValue', TValue.specialize From<Currency>(12.25));
    Check(C.GetValue(0, 'VariantValue').AsCurrency = 12.25, 'Variant property numeric roundtrip');
    C.SetValue(0, 'VariantValue', TValue.specialize From<string>('Grüße 東京'));
    Check(C.GetValue(0, 'VariantValue').AsString = 'Grüße 東京', 'Variant property Unicode roundtrip');
    C.SetValue(0, 'VariantValue', TValue.Empty);
    Check(C.GetValue(0, 'VariantValue').IsEmpty, 'Variant property NULL roundtrip');
    C.SetValue(0, 'Id', h5uParseEditorValue(Th5uColumnDataType.Integer, '42'));
    C.SetValue(0, 'Active', TValue.specialize From<Boolean>(True));
    C.SetValue(0, 'Price', TValue.specialize From<Currency>(12.25));
    C.SetValue(0, 'Date', TValue.specialize From<TDateTime>(EncodeDate(2026, 9, 11)));
    Check((R.Id = 42) and R.Active and (R.Price = 12.25), 'numeric RTTI write');
    V := C.GetValue(0, 'Date');
    Check(V.TypeInfo = TypeInfo(TDateTime), 'date RTTI identity');
    C.Cache.Mode := Th5uCacheMode.Viewport;
    V := C.GetValue(0, 'Text');
    R.Text := 'neu';
    Check(C.GetValue(0, 'Text').AsString <> R.Text, 'object cache is used');
    C.NotifyObjectChanged(R, 'Text');
    Check(C.GetValue(0, 'Text').AsString = R.Text, 'object cache invalidation');
    Check(C.GetValue(0, 'Missing').IsEmpty, 'missing property');
    R.Child := nil;
    Check(not C.CanEdit(0, 'Child.Text'), 'nil intermediate object');
    Writeln('PASS: FPC published RTTI read/write, nested paths and cache invalidation');
  finally
    C.Free;
    Child.Free;
    R.Free;
  end;
end;

procedure TestDatasets;
var
  D: Th5uSampleClientDataset;
  S: TDataSource;
  C: Th5uDatasetController;
  V: TValue;
  B: TBytes;
  Bookmark: TBookmark;
begin
  D := Th5uSampleClientDataset.Create(nil);
  S := TDataSource.Create(nil);
  C := Th5uDatasetController.Create(nil);
  try
    S.DataSet := D;
    C.DataSource := S;
    C.KeyFieldName := 'ID';
    Check(C.GetRowCount = 25, 'sample dataset row count');
    D.RecNo := 5;
    Bookmark := D.GetBookmark;
    try
      C.PrepareRange(0, 10);
      Check(C.GetRowKey(0).ToString = '1', 'dataset row key');
      V := C.GetValue(0, 'PICTURE');
      B := V.specialize AsType<TBytes>;
      Check((Length(B) > 8) and (B[0] = $89) and (B[1] = $50), 'sample PNG blob');
      Check(D.RecNo = 5, 'dataset read restores position');
    finally
      D.FreeBookmark(Bookmark);
    end;
    C.SetValue(0, 'NAME', TValue.specialize From<string>('Grüße 東京'));
    Check(C.GetValue(0, 'NAME').AsString = 'Grüße 東京', 'wide dataset UTF-8 roundtrip');
    C.SetValue(0, 'QUANTITY', h5uParseEditorValue(Th5uColumnDataType.Integer, '37'));
    C.SetValue(0, 'UNIT_PRICE', h5uParseEditorValue(Th5uColumnDataType.Currency, CurrToStr(19.75)));
    C.SetValue(0, 'ACTIVE', TValue.specialize From<Boolean>(False));
    Check(C.GetValue(0, 'QUANTITY').AsInteger = 37, 'dataset integer write');
    Check(C.GetValue(0, 'UNIT_PRICE').specialize AsType<Currency> = 19.75, 'dataset currency write');
    Check(not C.GetValue(0, 'ACTIVE').AsBoolean, 'dataset boolean write');
    B := TBytes.Create(0, 128, 255);
    C.SetValue(1, 'PICTURE', TValue.specialize From<TBytes>(B));
    V := C.GetValue(1, 'PICTURE');
    B := V.specialize AsType<TBytes>;
    Check((Length(B) = 3) and (B[2] = 255), 'binary dataset write');
    C.SetValue(1, 'PICTURE', TValue.Empty);
    Check(C.GetValue(1, 'PICTURE').IsEmpty, 'NULL dataset write');
    D.IncludeImages := False;
    D.SampleRowCount := 4;
    Check((C.GetRowCount = 4) and C.GetValue(0, 'PICTURE').IsEmpty, 'sample recreation and cache invalidation');
    Writeln('PASS: FPC sample dataset, bookmarks, UTF-8, typed edits, blobs and recreation');
  finally
    C.Free;
    S.Free;
    D.Free;
  end;
end;

procedure TestVirtual;
var
  C: Th5uVirtualController;
  E: TVirtualEvents;
  L: Th5uDataControllerLink;
  V: TValue;
begin
  C := Th5uVirtualController.Create(nil);
  E := TVirtualEvents.Create;
  L := Th5uDataControllerLink.Create;
  try
    E.Stored := 'Grüße';
    C.OnGetRowCount := @E.RowCount;
    C.OnGetValue := @E.GetValue;
    C.OnSetValue := @E.SetValue;
    L.OnChanged := @E.Changed;
    L.Controller := C;
    Check(C.GetRowCount = 3, 'virtual row count callback');
    V := C.GetValue(0, 'name');
    V := C.GetValue(0, 'NAME');
    Check((E.Reads = 1) and (V.AsString = E.Stored), 'case-insensitive virtual cache');
    C.SetValue(0, 'name', TValue.specialize From<string>('neu'));
    Check((C.GetValue(0, 'NAME').AsString = 'neu') and (E.Reads = 2), 'virtual write invalidation');
    C.BeginNewQuery;
    V := C.GetValue(0, 'name');
    Check((E.Reads = 3) and (E.Changes >= 2), 'query cache and change events');
    Writeln('PASS: FPC virtual callbacks, cache and notifications');
  finally
    L.Free;
    E.Free;
    C.Free;
  end;
end;

function MatchFactory(const AContext: Th5uFactoryContext): Boolean;
begin
  Result := AContext.SourceRowIndex = 2;
end;

procedure TestFactoryAndEditors;
var
  F: Th5uFactoryScope;
  C: Th5uFactoryContext;
  Scope: Th5uFactoryCacheScope;
  E: Th5uGridEditorItem;
  Bounds: TRectF;
  P: TPointF;
begin
  F := Th5uFactoryScope.Create(nil);
  try
    F.RegisterClass('test', TPersistent, TStringList, 0, @MatchFactory);
    C := Th5uFactoryContext.Create(nil, nil, nil, 'test', Th5uElementKind.Grid);
    C.SourceRowIndex := 2;
    Check(F.ResolveClass(C, TPersistent, TPersistent, Scope) = TStringList, 'factory predicate match');
    C.SourceRowIndex := 1;
    Check(F.ResolveClass(C, TPersistent, TPersistent, Scope) = TPersistent, 'factory predicate mismatch');
  finally
    F.Free;
  end;
  E := Th5uGridEditorItem.Create(nil);
  try
    Bounds.Left := 10; Bounds.Top := 20; Bounds.Right := 50; Bounds.Bottom := 80;
    Bounds := h5uEditorCheckBounds(Bounds);
    Check((Bounds.Left = 22.5) and (Bounds.Top = 42.5), 'floating checkbox bounds');
    P.X := 23; P.Y := 43;
    Check(E.HitTest(Bounds, P), 'editor hit testing');
    E.SetValue(TValue.specialize From<Double>(1.25));
    Check(E.GetText = FloatToStr(1.25), 'FPC floating-point editor text');
  finally
    E.Free;
  end;
  Writeln('PASS: FPC factory predicates and editor geometry');
end;

begin
  try
    TestValues;
    TestObjects;
    TestDatasets;
    TestVirtual;
    TestFactoryAndEditors;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
