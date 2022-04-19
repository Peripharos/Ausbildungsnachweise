program Ausbildungsnachweise;

uses
  Forms,
  Ausbildungsnachweise.Main in 'Ausbildungsnachweise.Main.pas' {FrmMain},
  Ausbildungsnachweise.Utils in 'Ausbildungsnachweise.Utils.pas',
  Ausbildungsnachweise.Add in 'Ausbildungsnachweise.Add.pas' {FrmAdd},
  Ausbildungsnachweise.ShowDocument in 'Ausbildungsnachweise.ShowDocument.pas' {FrmShowDocument},
  Ausbildungsnachweise.WordApplication in 'Ausbildungsnachweise.WordApplication.pas',
  Ausbildungsnachweise.Settings in 'Ausbildungsnachweise.Settings.pas' {FrmSettings},
  Ausbildungsnachweise.Template in 'Ausbildungsnachweise.Template.pas' {FrmTemplate},
  Ausbildungsnachweise.Shadow in 'Ausbildungsnachweise.Shadow.pas' {FrmShadow};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
