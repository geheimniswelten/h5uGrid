unit Fmx.h5u.Grid.Editors;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types;

type
  Th5uFmxImageEditor = class(TLayout)
  private
    FImage: TImage;
    FToolBar: TLayout;
    FLoadButton: TButton;
    FClearButton: TButton;
    FOkButton: TButton;
    FCancelButton: TButton;
    FBytes: TBytes;
    FOnCommit: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    procedure LoadClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure UpdatePreview;
    procedure SetBytes(const AValue: TBytes);
  public
    constructor Create(AOwner: TComponent); override;
    property Bytes: TBytes read FBytes write SetBytes;
    property OnCommit: TNotifyEvent read FOnCommit write FOnCommit;
    property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
  end;

implementation

{ Th5uFmxImageEditor }

procedure Th5uFmxImageEditor.CancelClick(Sender: TObject);
begin
  if Assigned(FOnCancel) then
    FOnCancel(Self);
end;

procedure Th5uFmxImageEditor.ClearClick(Sender: TObject);
begin
  FBytes := nil;
  FImage.Bitmap.SetSize(0, 0);
end;

constructor Th5uFmxImageEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 420;
  Height := 300;
  ClipChildren := True;

  FToolBar := TLayout.Create(Self);
  FToolBar.Parent := Self;
  FToolBar.Align := TAlignLayout.Bottom;
  FToolBar.Height := 42;

  FLoadButton := TButton.Create(Self);
  FLoadButton.Parent := FToolBar;
  FLoadButton.Position.Point := PointF(6, 6);
  FLoadButton.Size.Size := TSizeF.Create(82, 30);
  FLoadButton.Text := 'Laden ...';
  FLoadButton.OnClick := LoadClick;

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := FToolBar;
  FClearButton.Position.Point := PointF(94, 6);
  FClearButton.Size.Size := TSizeF.Create(82, 30);
  FClearButton.Text := 'Löschen';
  FClearButton.OnClick := ClearClick;

  FOkButton := TButton.Create(Self);
  FOkButton.Parent := FToolBar;
  FOkButton.Align := TAlignLayout.Right;
  FOkButton.Width := 82;
  FOkButton.Margins.Rect := RectF(4, 6, 6, 6);
  FOkButton.Text := 'OK';
  FOkButton.OnClick := OkClick;

  FCancelButton := TButton.Create(Self);
  FCancelButton.Parent := FToolBar;
  FCancelButton.Align := TAlignLayout.Right;
  FCancelButton.Width := 92;
  FCancelButton.Margins.Rect := RectF(4, 6, 0, 6);
  FCancelButton.Text := 'Abbrechen';
  FCancelButton.OnClick := CancelClick;

  FImage := TImage.Create(Self);
  FImage.Parent := Self;
  FImage.Align := TAlignLayout.Client;
  FImage.WrapMode := TImageWrapMode.Fit;
end;

procedure Th5uFmxImageEditor.LoadClick(Sender: TObject);
var
  LDialog: TOpenDialog;
  LStream: TFileStream;
begin
  LDialog := TOpenDialog.Create(Self);
  try
    LDialog.Filter := 'Bilder|*.png;*.jpg;*.jpeg;*.bmp;*.gif|' + 'Alle Dateien|*.*';
    if not LDialog.Execute then
      Exit;

    LStream := TFileStream.Create(LDialog.FileName, fmOpenRead or fmShareDenyWrite);
    try
      SetLength(FBytes, LStream.Size);
      if LStream.Size > 0 then
        LStream.ReadBuffer(FBytes[0], LStream.Size);
    finally
      LStream.Free;
    end;
    UpdatePreview;
  finally
    LDialog.Free;
  end;
end;

procedure Th5uFmxImageEditor.OkClick(Sender: TObject);
begin
  if Assigned(FOnCommit) then
    FOnCommit(Self);
end;

procedure Th5uFmxImageEditor.SetBytes(const AValue: TBytes);
begin
  FBytes := Copy(AValue);
  UpdatePreview;
end;

procedure Th5uFmxImageEditor.UpdatePreview;
var
  LStream: TBytesStream;
begin
  FImage.Bitmap.SetSize(0, 0);
  if Length(FBytes) = 0 then
    Exit;

  LStream := TBytesStream.Create(FBytes);
  try
    try
      FImage.Bitmap.LoadFromStream(LStream);
    except
      FImage.Bitmap.SetSize(0, 0);
    end;
  finally
    LStream.Free;
  end;
end;

end.
