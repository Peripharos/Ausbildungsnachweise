program Ausbildungsnachweise.Service;

uses
  Forms,
  Ausbildungsnachweise.Service.Main in 'Ausbildungsnachweise.Service.Main.pas' {DtmMain: TDataModule},
  Ausbildungsnachweise.Utils in '..\Ausbildungsnachweise.Utils.pas',
  Ausbildungsnachweise.WordApplication in '..\Ausbildungsnachweise.WordApplication.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDtmMain, DtmMain);
  Application.Run;
end.
