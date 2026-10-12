uses
  System.Classes, System.SysUtils, System.Rtti, System.Types, System.Math,
  h5u.Grid.Editors, h5u.Grid.Types,
  {$IFDEF TEST_FMX}
  FMX.Forms, FMX.Controls,
  Fmx.h5u.Grid.Editors;
  {$ELSE}
  Vcl.Forms, Vcl.Controls,
  Vcl.h5u.Grid.Editors;
  {$ENDIF}

type
  {$IFDEF TEST_FMX}
  TNativeEditor = Th5uFmxTextEditor;
  {$ELSE}
  TNativeEditor = Th5uVclTextEditor;
  {$ENDIF}

  TEventCounter = class
    Shows, Changes: Integer;
    procedure Shown(Sender: TObject);
    procedure Changed(Sender: TObject);
  end;

procedure TEventCounter.Shown(Sender: TObject);
begin
  Inc(Shows);
end;

procedure TEventCounter.Changed(Sender: TObject);
begin
  Inc(Changes);
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure CheckBounds(AEditor: TNativeEditor; const ABounds: TRectF);
begin
  Check(AEditor.Context.Bounds = ABounds, 'Editor context did not follow the cell bounds');
  {$IFDEF TEST_FMX}
  Check(SameValue(AEditor.Control.Position.X, ABounds.Left), 'Native editor left');
  Check(SameValue(AEditor.Control.Position.Y, ABounds.Top), 'Native editor top');
  Check(SameValue(AEditor.Control.Width, ABounds.Width), 'Native editor width');
  Check(SameValue(AEditor.Control.Height, ABounds.Height), 'Native editor height');
  {$ELSE}
  Check(AEditor.Control.Left = Round(ABounds.Left), 'Native editor left');
  Check(AEditor.Control.Top = Round(ABounds.Top), 'Native editor top');
  Check(AEditor.Control.Width = Round(ABounds.Width), 'Native editor width');
  Check(AEditor.Control.Height = Round(ABounds.Height), 'Native editor height');
  {$ENDIF}
end;

procedure TestEditorBounds;
var
  Form: TForm;
  Editor: TNativeEditor;
  Control: TControl;
  Events: TEventCounter;
  Context: Th5uEditorContext;
  Changes: Integer;
  NewBounds: TRectF;
begin
  Form := TForm.CreateNew(nil);
  Editor := TNativeEditor.Create(nil);
  Events := TEventCounter.Create;
  try
    Context := Default(Th5uEditorContext);
    {$IFDEF TEST_FMX}
    Control := TControl.Create(Form);
    Control.Parent := Form;
    Context.Grid := Control;
    {$ELSE}
    Context.Grid := Form;
    {$ENDIF}
    Context.Bounds := RectF(4, 10, 104, 36);
    Context.Value := TValue.From<string>('original');
    Context.Text := 'original';
    Editor.OnShow := Events.Shown;
    Editor.OnChange := Events.Changed;
    // Build the hidden native control; never activate, show or focus an editor.
    Editor.BeginEdit(Context);
    Control := Editor.Control;
    Check(Assigned(Control), 'Native editor control was not created');
    Editor.SetText('unsaved draft');
    Check(Editor.Modified, 'Draft must be modified before updating geometry');
    Changes := Events.Changes;
    NewBounds := RectF(130, 42, 350, 76);
    Editor.UpdateBounds(NewBounds);
    CheckBounds(Editor, NewBounds);
    Check(Editor.Control = Control, 'Updating geometry replaced the native control');
    Check(Editor.GetText = 'unsaved draft', 'Updating geometry replaced the draft');
    Check(Editor.Modified, 'Updating geometry reset the modification state');
    Check(Events.Shows = 0, 'Updating geometry fired OnShow');
    Check(Events.Changes = Changes, 'Updating geometry fired OnChange');
    Check(not Control.Visible, 'Updating geometry made the control visible');
    Editor.UpdateBounds(TRectF.Empty);
    CheckBounds(Editor, TRectF.Empty);
    Editor.UpdateBounds(NewBounds);
    CheckBounds(Editor, NewBounds);
    Check(Editor.GetText = 'unsaved draft', 'Leaving the viewport lost the draft');
    // Graphic editors can place their own popup outside the edited cell.
    Editor.Mode := Th5uEditorMode.Graphic;
    Editor.UpdateBounds(RectF(1, 2, 3, 4));
    Check(Editor.Context.Bounds = RectF(1, 2, 3, 4), 'Graphic editor context remained stale');
    Check(SameValue(Editor.Control.Width, NewBounds.Width), 'Graphic popup width was changed');
    Check(SameValue(Editor.Control.Height, NewBounds.Height), 'Graphic popup height was changed');
  finally
    Editor.Free;
    Events.Free;
    Form.Free;
  end;
end;

begin
  try
    Application.Initialize;
    TestEditorBounds;
    Writeln('PASS: draft-preserving native editor bounds without activation, Show or focus');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
