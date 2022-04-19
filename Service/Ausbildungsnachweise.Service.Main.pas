unit Ausbildungsnachweise.Service.Main;

interface

uses
  SysUtils, Classes, Ausbildungsnachweise.Utils, ExtCtrls;

type
  TDtmMain = class(TDataModule)
    TrayIcon1: TTrayIcon;
    procedure DataModuleCreate(Sender: TObject);
  private
    TrainingStartDate: TDateTime;
    OnStart: Boolean;
    Interval: Longint;
    LastStart: Longint;
    procedure Execute;
  public
    { Public-Deklarationen }
  end;

var
  DtmMain: TDtmMain;

implementation

uses
  Forms, Windows, Registry, ProcessCtrl, FileUtils;

{$R *.dfm}

procedure TDtmMain.DataModuleCreate(Sender: TObject);

  procedure GetServiceData(out TrainingStartDate: TDateTime; out IsActive,OnStart: Boolean; out Interval: Integer);
  var
    Registry: TRegistry;
  begin
    Registry:=TRegistry.Create;
    try
      Registry.RootKey:=HKEY_CURRENT_USER;
      try
        Registry.OpenKey('Software\Peripharos\Ausbildungsnachweise',False);
        TrainingStartDate:=Registry.ReadDate('TrainingStartDate');
        IsActive:=Registry.ReadBool('IsActive');
        OnStart:=Registry.ReadBool('OnStart');
        Interval:=Registry.ReadInteger('Interval');
      except
        IsActive:=True;
        OnStart:=True;
        Interval:=1000*60*30;
      end;
    finally
      Registry.Free;
    end;
  end;

var
  I:Longint;
  IsActive: Boolean;
begin
  GetServiceData(TrainingStartDate,IsActive,OnStart,Interval);
  if IsActive then begin
    if OnStart then begin
      Execute;
    end;
    LastStart:=GetTickCount;
    while (not Application.Terminated) do begin
      I:=GetTickCount;
      if (I>=LastStart+Interval)and(Interval>0) then begin
        LastStart:=I;
        Execute;
      end;
      Application.ProcessMessages;
      Sleep(50);
    end;
  end;
end;

procedure TDtmMain.Execute;
var
  Path: string;
  CountNotPrinted,CountNotFinished,CountNotExistend: Integer;
begin
  UnpackData(Path);
  try
    if IsNachweisPending(AppendPath(Path,'Data'),TrainingStartDate,CountNotPrinted,CountNotFinished,CountNotExistend) then begin
      TrayIcon1.Visible:=True;
      TrayIcon1.BalloonHint:='Es müssend noch '+IntToStr(CountNotPrinted)+' Nachweise gedruckt werden, '
                              +IntToStr(CountNotFinished)+' Nachweise sind noch nicht fertig bearbeitet und '
                              +IntToStr(CountNotExistend)+' Nachweise wurden noch nicht angelegt';
      TrayIcon1.ShowBalloonHint;
      Sleep(50);
    end;
  finally
    if (GetProcessID('Ausbildungsnachweise.exe')=0) then
      SaveDataToPacked(True);
  end;
end;

end.
