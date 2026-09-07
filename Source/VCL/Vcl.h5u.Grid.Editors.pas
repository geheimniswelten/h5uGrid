unit Vcl.h5u.Grid.Editors;

interface

uses
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls;

type
  Th5uVclImageEditForm = class(TForm)
  private
    FImage: TImage;
    FButtonPanel: TPanel;
    FLoadButton: TButton;
    FPasteButton: TButton;
    FClearButton: TButton;
    FOkButton: TButton;
    FCancelButton: TButton;
    FBytes: TBytes;
    procedure LoadClick(Sender: TObject);
    procedure PasteClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure UpdatePreview;
    procedure SetBytes(const AValue: TBytes);
  public
    constructor Create(AOwner: TComponent); override;
    class function Execute(AOwner: TComponent; var ABytes: TBytes): Boolean;
  end;

implementation

uses
  Winapi.Windows,
  Vcl.Clipbrd,
  Vcl.Dialogs;

{ Th5uVclImageEditForm }

procedure Th5uVclImageEditForm.ClearClick(Sender: TObject);
begin
  FBytes := nil;
  FImage.Picture.Assign(nil);
end;

constructor Th5uVclImageEditForm.Create(AOwner: TComponent);
begin
  inherited;
  Caption := 'Bild bearbeiten';
  BorderStyle := bsSizeable;
  Position := poOwnerFormCenter;
  ClientWidth := 680;
  ClientHeight := 480;

  FButtonPanel := TPanel.Create(Self);
  FButtonPanel.Parent := Self;
  FButtonPanel.Align := alBottom;
  FButtonPanel.Height := 44;
  FButtonPanel.BevelOuter := bvNone;

  FLoadButton := TButton.Create(Self);
  FLoadButton.Parent := FButtonPanel;
  FLoadButton.SetBounds(8, 9, 90, 27);
  FLoadButton.Caption := 'Laden ...';
  FLoadButton.OnClick := LoadClick;

  FPasteButton := TButton.Create(Self);
  FPasteButton.Parent := FButtonPanel;
  FPasteButton.SetBounds(104, 9, 100, 27);
  FPasteButton.Caption := 'Einfügen';
  FPasteButton.OnClick := PasteClick;

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := FButtonPanel;
  FClearButton.SetBounds(210, 9, 90, 27);
  FClearButton.Caption := 'Löschen';
  FClearButton.OnClick := ClearClick;

  FCancelButton := TButton.Create(Self);
  FCancelButton.Parent := FButtonPanel;
  FCancelButton.SetBounds(574, 9, 90, 27);
  FCancelButton.Anchors := [akTop, akRight];
  FCancelButton.Caption := 'Abbrechen';
  FCancelButton.ModalResult := mrCancel;

  FOkButton := TButton.Create(Self);
  FOkButton.Parent := FButtonPanel;
  FOkButton.SetBounds(478, 9, 90, 27);
  FOkButton.Anchors := [akTop, akRight];
  FOkButton.Caption := 'OK';
  FOkButton.Default := True;
  FOkButton.ModalResult := mrOk;

  FImage := TImage.Create(Self);
  FImage.Parent := Self;
  FImage.Align := alClient;
  FImage.Center := True;
  FImage.Proportional := True;
  FImage.Stretch := True;
end;

class function Th5uVclImageEditForm.Execute(AOwner: TComponent; var ABytes: TBytes): Boolean;
var
  LForm: Th5uVclImageEditForm;
begin
  LForm := Th5uVclImageEditForm.Create(AOwner);
  try
    LForm.SetBytes(ABytes);
    Result := LForm.ShowModal = mrOk;
    if Result then
      ABytes := Copy(LForm.FBytes);
  finally
    LForm.Free;
  end;
end;

procedure Th5uVclImageEditForm.LoadClick(Sender: TObject);
var
  LDialog: TOpenDialog;
  LStream: TFileStream;
begin
  LDialog := TOpenDialog.Create(Self);
  try
    LDialog.Filter := 'Bilder|*.png;*.jpg;*.jpeg;*.bmp;*.gif;*.ico|' + 'Alle Dateien|*.*';
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

procedure Th5uVclImageEditForm.PasteClick(Sender: TObject);
var
  LBitmap: Vcl.Graphics.TBitmap;
  LStream: TMemoryStream;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  LBitmap := Vcl.Graphics.TBitmap.Create;
  LStream := TMemoryStream.Create;
  try
    LBitmap.Assign(Clipboard);
    LBitmap.SaveToStream(LStream);
    SetLength(FBytes, LStream.Size);
    if LStream.Size > 0 then
    begin
      LStream.Position := 0;
      LStream.ReadBuffer(FBytes[0], LStream.Size);
    end;
  finally
    LStream.Free;
    LBitmap.Free;
  end;
  UpdatePreview;
end;

procedure Th5uVclImageEditForm.SetBytes(const AValue: TBytes);
begin
  FBytes := Copy(AValue);
  UpdatePreview;
end;

procedure Th5uVclImageEditForm.UpdatePreview;
var
  LStream: TBytesStream;
begin
  FImage.Picture.Assign(nil);
  if Length(FBytes) = 0 then
    Exit;

  LStream := TBytesStream.Create(FBytes);
  try
    try
      FImage.Picture.LoadFromStream(LStream);
    except
      FImage.Picture.Assign(nil);
    end;
  finally
    LStream.Free;
  end;
end;

end.
