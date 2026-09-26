unit LclObjectDemoMain;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

{$SCOPEDENUMS ON}


uses
  Classes,
  DateUtils,
  SysUtils,
  Controls,
  ExtCtrls,
  Forms,
  StdCtrls,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.Objects,
  Lcl.h5u.Grid;

type
  TPersonRow = class(TPersistent)
  private
    FId: Integer;
    FName: string;
    FDepartment: string;
    FNotes: string;
    FActive: Boolean;
    FPriority: Integer;
    FAmount: Currency;
    FUpdatedAt: TDateTime;
  published
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Department: string read FDepartment write FDepartment;
    property Notes: string read FNotes write FNotes;
    property Active: Boolean read FActive write FActive;
    property Priority: Integer read FPriority write FPriority;
    property Amount: Currency read FAmount write FAmount;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

  TLclObjectDemoForm = class(TForm)
    TopPanel: TPanel;
    AddButton: TButton;
    CacheCheck: TCheckBox;
    LiveCheck: TCheckBox;
    DarkCheck: TCheckBox;
    InfoLabel: TLabel;
    UpdateTimer: TTimer;
    ObjectController: Th5uObjectListController;
    Grid: Th5uLclGrid;
    procedure FormCreate(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure CacheCheckClick(Sender: TObject);
    procedure DarkCheckClick(Sender: TObject);
    procedure LiveCheckClick(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
  private
    FNextId: Integer;
    function AddPerson: TPersonRow;
  end;

var
  LclObjectDemoForm: TLclObjectDemoForm;

implementation

{$R *.lfm}

uses
  Rtti,
  h5u.Grid.Types;

function TLclObjectDemoForm.AddPerson: TPersonRow;
const
  CDepartments: array[0..4] of string = ('Fertigung', 'Konstruktion', 'Einkauf', 'QS', 'Vertrieb');
begin
  Inc(FNextId);
  Result := TPersonRow.Create;
  Result.Id := FNextId;
  Result.Name := Format('Mitarbeiter %d', [FNextId]);
  Result.Department := CDepartments[FNextId mod Length(CDepartments)];
  Result.Active := (FNextId mod 5) <> 0;
  Result.Priority := FNextId mod 4;
  Result.Amount := 1250 + FNextId * 42.75;
  Result.UpdatedAt := IncMinute(Now, -FNextId * 3);
  if (FNextId mod 6) = 0 then
    Result.Notes := 'Dieser Eintrag demonstriert einen längeren Text aus einer normalen Objektliste. '
      + 'Der Controller greift per RTTI auf published Properties zu; der Wertcache ist optional.'
  else
    Result.Notes := 'Kurzer RTTI-Listeneintrag.';
  ObjectController.Add(Result);
end;

procedure TLclObjectDemoForm.AddButtonClick(Sender: TObject);
begin
  AddPerson;
end;

procedure TLclObjectDemoForm.CacheCheckClick(Sender: TObject);
begin
  if CacheCheck.Checked then
    ObjectController.Cache.Mode := Th5uCacheMode.Viewport
  else
    ObjectController.Cache.Mode := Th5uCacheMode.None;
end;

procedure TLclObjectDemoForm.DarkCheckClick(Sender: TObject);
begin
  if DarkCheck.Checked then
    Grid.Theme := Th5uGridTheme.Dark
  else
    Grid.Theme := Th5uGridTheme.ApplicationStyle;
end;

procedure TLclObjectDemoForm.FormCreate(Sender: TObject);
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
end;

procedure TLclObjectDemoForm.LiveCheckClick(Sender: TObject);
begin
  UpdateTimer.Enabled := LiveCheck.Checked;
end;

procedure TLclObjectDemoForm.UpdateTimerTimer(Sender: TObject);
var
  LIndex: Integer;
  LPerson: TPersonRow;
begin
  if ObjectController.Count = 0 then
    Exit;
  LIndex := Random(ObjectController.Count);
  LPerson := TPersonRow(ObjectController.Item(LIndex));
  LPerson.Amount := LPerson.Amount + 12.5;
  LPerson.Priority := (LPerson.Priority + 1) mod 4;
  LPerson.UpdatedAt := Now;
  ObjectController.NotifyObjectChanged(LPerson);
end;

end.
