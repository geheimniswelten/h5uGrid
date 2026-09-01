unit Main;

interface

{$SCOPEDENUMS ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}

uses
  System.Classes,
  System.DateUtils,
  System.SysUtils,
  FMX.Controls,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Types,
  h5u.Grid.Data.Objects,
  FMX.h5u.Grid;

type
  TPersonRow = class
  private
    FId: Integer;
    FName: string;
    FDepartment: string;
    FNotes: string;
    FActive: Boolean;
    FPriority: Integer;
    FAmount: Currency;
    FUpdatedAt: TDateTime;
  public
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Department: string read FDepartment write FDepartment;
    property Notes: string read FNotes write FNotes;
    property Active: Boolean read FActive write FActive;
    property Priority: Integer read FPriority write FPriority;
    property Amount: Currency read FAmount write FAmount;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

  TMainForm = class(TForm)
    ToolBar: TToolBar;
    AddButton: TButton;
    CacheCheck: TCheckBox;
    LiveCheck: TCheckBox;
    DarkCheck: TCheckBox;
    Grid: Th5uFmxGrid;
    ObjectController: Th5uObjectListController;
    UpdateTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure OptionChange(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
  private
    FNextId: Integer;
    function AddPerson: TPersonRow;
    procedure ApplyOptions;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  h5u.Grid.Types;

function TMainForm.AddPerson: TPersonRow;
const
  CDepartments: array[0..4] of string = (
    'Fertigung', 'Konstruktion', 'Einkauf', 'QS', 'Vertrieb'
  );
begin
  Inc(FNextId);
  Result := TPersonRow.Create;
  Result.Id := FNextId;
  Result.Name := Format('Objekt %d', [FNextId]);
  Result.Department :=
    CDepartments[FNextId mod Length(CDepartments)];
  Result.Active := (FNextId mod 5) <> 0;
  Result.Priority := FNextId mod 4;
  Result.Amount := 800 + FNextId * 31.45;
  Result.UpdatedAt := IncMinute(Now, -FNextId);
  if (FNextId mod 6) = 0 then
    Result.Notes :=
      'Mehrzeiliger RTTI-Inhalt. Der ObjectListController kann ' +
      'direkt aus der Liste lesen oder Werte optional cachen.'
  else
    Result.Notes := 'Kurzer Objekteintrag.';
  ObjectController.Add(Result);
end;

procedure TMainForm.AddButtonClick(Sender: TObject);
begin
  AddPerson;
end;

procedure TMainForm.ApplyOptions;
begin
  if CacheCheck.IsChecked then
    ObjectController.Cache.Mode := Th5uCacheMode.Viewport
  else
    ObjectController.Cache.Mode := Th5uCacheMode.None;

  UpdateTimer.Enabled := LiveCheck.IsChecked;

  if DarkCheck.IsChecked then
    Grid.Theme := Th5uGridTheme.Dark
  else
    Grid.Theme := Th5uGridTheme.ApplicationStyle;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  ObjectController.OwnsObjects := True;
  ObjectController.BeginUpdate;
  try
    for I := 1 to 80 do
      AddPerson;
  finally
    ObjectController.EndUpdate;
  end;
  ApplyOptions;
end;

procedure TMainForm.OptionChange(Sender: TObject);
begin
  ApplyOptions;
end;

procedure TMainForm.UpdateTimerTimer(Sender: TObject);
var
  LIndex: Integer;
  LPerson: TPersonRow;
begin
  if ObjectController.Count = 0 then
    Exit;
  LIndex := Random(ObjectController.Count);
  LPerson := TPersonRow(ObjectController.Item(LIndex));
  LPerson.Amount := LPerson.Amount + 7.5;
  LPerson.Priority := (LPerson.Priority + 1) mod 4;
  LPerson.UpdatedAt := Now;
  ObjectController.NotifyObjectChanged(LPerson);
end;

end.
