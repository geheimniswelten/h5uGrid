unit h5u.Grid.SampleData;

interface

uses
  System.Classes,
  System.SysUtils,
  System.NetEncoding,
  Data.DB,
  Datasnap.DBClient;

type
  Th5uSampleClientDataSet = class(TClientDataSet)
  private
    FAutoCreateSampleData: Boolean;
    FIncludeImages: Boolean;
    FSampleRowCount: Integer;
    FUpdatingSampleData: Boolean;
    procedure SetAutoCreateSampleData(const AValue: Boolean);
    procedure SetIncludeImages(const AValue: Boolean);
    procedure SetSampleRowCount(const AValue: Integer);
    procedure BuildFieldDefs;
    procedure AppendSampleRows;
    procedure WriteSampleImage(AField: TField; AIndex: Integer);
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RecreateSampleData;
    procedure EnsureSampleData;
  published
    property AutoCreateSampleData: Boolean read FAutoCreateSampleData write SetAutoCreateSampleData default True;
    property IncludeImages: Boolean read FIncludeImages write SetIncludeImages default True;
    property SampleRowCount: Integer read FSampleRowCount write SetSampleRowCount default 25;
  end;

implementation

const
  // Valid 1 x 1 PNG. Keeping the image data here makes the demo completely
  // self-contained and independent of VCL/FMX graphics classes.
  cSamplePngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk' +
    'YAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

{ Th5uSampleClientDataSet }

constructor Th5uSampleClientDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoCreateSampleData := True;
  FIncludeImages := True;
  FSampleRowCount := 25;
  LogChanges := False;

  // This also makes a newly dropped component immediately useful in the
  // designer. Loaded calls EnsureSampleData again after DFM streaming.
  EnsureSampleData;
end;

procedure Th5uSampleClientDataSet.Loaded;
begin
  inherited Loaded;
  EnsureSampleData;
end;

procedure Th5uSampleClientDataSet.SetAutoCreateSampleData(const AValue: Boolean);
begin
  if FAutoCreateSampleData = AValue then
    Exit;

  FAutoCreateSampleData := AValue;
  if FAutoCreateSampleData then
    EnsureSampleData;
end;

procedure Th5uSampleClientDataSet.SetIncludeImages(const AValue: Boolean);
begin
  if FIncludeImages = AValue then
    Exit;

  FIncludeImages := AValue;
  if FAutoCreateSampleData then
    RecreateSampleData;
end;

procedure Th5uSampleClientDataSet.SetSampleRowCount(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then
    LValue := 1
  else if LValue > 1000 then
    LValue := 1000;

  if FSampleRowCount = LValue then
    Exit;

  FSampleRowCount := LValue;
  if FAutoCreateSampleData then
    RecreateSampleData;
end;

procedure Th5uSampleClientDataSet.BuildFieldDefs;
begin
  FieldDefs.Clear;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'ID';
    DataType := ftInteger;
    Required := True;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'TREE_LEVEL';
    DataType := ftInteger;
    Required := True;
  end;

  // Used by the adjacent-group-folding demos. Equal values are deliberately
  // repeated in separate, non-adjacent runs to demonstrate that every
  // contiguous run has its own fold state.
  with FieldDefs.AddFieldDef do
  begin
    Name := 'FOLD_GROUP';
    DataType := ftInteger;
    Required := True;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'NAME';
    DataType := ftWideString;
    Size := 80;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'CATEGORY';
    DataType := ftWideString;
    Size := 40;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'DESCRIPTION';
    DataType := ftWideMemo;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'QUANTITY';
    DataType := ftInteger;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'UNIT_PRICE';
    DataType := ftCurrency;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'ACTIVE';
    DataType := ftBoolean;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'PRIORITY';
    DataType := ftInteger;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'UPDATED_AT';
    DataType := ftDateTime;
  end;

  with FieldDefs.AddFieldDef do
  begin
    Name := 'PICTURE';
    DataType := ftBlob;
  end;
end;

procedure Th5uSampleClientDataSet.WriteSampleImage(AField: TField; AIndex: Integer);
var
  LBytes: TBytes;
  LStream: TBytesStream;
begin
  if not FIncludeImages or not Assigned(AField) or not (AField is TBlobField) then
    Exit;

  // Only some rows contain a picture. This also tests NULL BLOB handling.
  if (AIndex mod 4) <> 1 then
    Exit;

  LBytes := TNetEncoding.Base64.DecodeStringToBytes(cSamplePngBase64);
  LStream := TBytesStream.Create(LBytes);
  try
    TBlobField(AField).LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

procedure Th5uSampleClientDataSet.AppendSampleRows;
const
  cCategories: array[0..3] of string = (
    'Mechanik',
    'Elektronik',
    'Montage',
    'Prüfung'
  );
var
  I: Integer;
  LDescription: string;
  LTreeLevel: Integer;

  function TreeLevelForRow(const AIndex: Integer): Integer;
  begin
    // Repeating preorder hierarchy:
    // root, child, grandchild, grandchild, child, grandchild,
    // grandchild, child. The following root closes the branch.
    case (AIndex - 1) mod 8 of
      0:
        Result := 0;
      1, 4, 7:
        Result := 1;
    else
      Result := 2;
    end;
  end;

  function FoldGroupForRow(const AIndex: Integer): Integer;
  begin
    // 1,1,1 | 2 | 3,3 | 1,1,1 | 4
    // The second run with ID 1 is intentionally independent from the first.
    case (AIndex - 1) mod 10 of
      0, 1, 2:
        Result := 1;
      3:
        Result := 2;
      4, 5:
        Result := 3;
      6, 7, 8:
        Result := 1;
    else
      Result := 4;
    end;
  end;
begin
  DisableControls;
  try
    for I := 1 to FSampleRowCount do
    begin
      Append;
      FieldByName('ID').AsInteger := I;
      LTreeLevel := TreeLevelForRow(I);
      FieldByName('TREE_LEVEL').AsInteger := LTreeLevel;
      FieldByName('FOLD_GROUP').AsInteger := FoldGroupForRow(I);
      case LTreeLevel of
        0:
          FieldByName('NAME').AsString := Format(
            'Baugruppe %.2d',
            [((I - 1) div 8) + 1]
          );
        1:
          FieldByName('NAME').AsString := Format(
            '  Untergruppe / Teil %.3d',
            [I]
          );
      else
        FieldByName('NAME').AsString := Format(
          '    Bauteil %.3d',
          [I]
        );
      end;
      FieldByName('CATEGORY').AsString := cCategories[(I - 1) mod Length(cCategories)];

      LDescription :=
        Format('Dies ist Datensatz %d. Der Text demonstriert automatische ' +
          'Zeilenhöhe, Umbruch und ein konfigurierbares Höhenlimit.', [I]);
      if (I mod 5) = 0 then
        LDescription := LDescription + sLineBreak +
          'Jede fünfte Zeile enthält bewusst eine zweite Zeile und wird ' +
          'zusätzlich über eine periodische Style-Regel hervorgehoben.';

      FieldByName('DESCRIPTION').AsString := LDescription;
      FieldByName('QUANTITY').AsInteger := 1 + ((I * 7) mod 43);
      FieldByName('UNIT_PRICE').AsType<Currency> := 12.50 + (I * 3.75);
      FieldByName('ACTIVE').AsBoolean := (I mod 4) <> 0;
      FieldByName('PRIORITY').AsInteger := I mod 4;
      FieldByName('UPDATED_AT').AsDateTime := Now - (FSampleRowCount - I) / 24;
      WriteSampleImage(FieldByName('PICTURE'), I);
      Post;
    end;
    First;
  finally
    EnableControls;
  end;
end;

procedure Th5uSampleClientDataSet.RecreateSampleData;
begin
  if FUpdatingSampleData then
    Exit;

  FUpdatingSampleData := True;
  try
    if Active then
      Close;

    FieldDefs.Clear;
    BuildFieldDefs;
    CreateDataSet;
    LogChanges := False;
    AppendSampleRows;
  finally
    FUpdatingSampleData := False;
  end;
end;

procedure Th5uSampleClientDataSet.EnsureSampleData;
begin
  if not FAutoCreateSampleData or FUpdatingSampleData then
    Exit;

  if not Active then
    RecreateSampleData
  else if IsEmpty then
    AppendSampleRows;
end;

end.
