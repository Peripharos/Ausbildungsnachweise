unit Ausbildungsnachweise.Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Mask, StdCtrls, ExtCtrls, Contnrs, Buttons,
  Ausbildungsnachweise.Template, EditCtrls, NumEdit, ProcessCtrl;

const
  NachweisTemplateHeight = 100;

type
  TNachweisTemplate = class;
  TNachweisTemplateList = class;
  TPaintNachweisTemplate = procedure(const NachweisTemplate: TNachweisTemplate) of object;

  TFrmSettings = class(TForm)
    PnlTop: TPanel;
    PnlSettingsFrame: TPanel;
    LblUserName: TLabel;
    LblTrainingStartDate: TLabel;
    LblTrainingEndDate: TLabel;
    EdtUserName: TEdit;
    EdtTrainingStartDate: TMaskEdit;
    EdtTrainingEndDate: TMaskEdit;
    PnlTemplates: TScrollBox;
    PnlTemplatesFrame: TPanel;
    PnlTemplatesHeading: TPanel;
    BtnAbbort: TButton;
    BtnSave: TButton;
    Image: TImage;
    PnlAdd: TPanel;
    BtnAdd: TSpeedButton;
    PnlMainSettings: TGroupBox;
    PnlServiceSettings: TGroupBox;
    LblIsActive: TLabel;
    LblOnStart: TLabel;
    LblInterval: TLabel;
    EdtIsActive: TImage;
    EdtOnStart: TImage;
    EdtInterval: TComboBox;
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnAbbortClick(Sender: TObject);
    procedure ImageMouseLeave(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImageClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EdtOnStartClick(Sender: TObject);
    procedure EdtIsActiveClick(Sender: TObject);
  private
    Path: string;
    NachweisTemplateList: TNachweisTemplateList;
    FIsActive: Boolean;
    FOnStart: Boolean;
    procedure InitNachweisTemplates;
    procedure SaveToRegistry;
    procedure PaintCheckbox(Canvas: TCanvas; const Width,Height: Integer; const Checked: Boolean);
    procedure PaintNachweisTemplateList;
    procedure PaintNachweisTemplate(const NachweisTemplate: TNachweisTemplate); overload;
    procedure PaintNachweisTemplate(const NachweisTemplate: TNachweisTemplate; Canvas: TCanvas); overload;
    procedure SetIsActive(const Value: Boolean);
    procedure SetOnStart(const Value: Boolean);
  public
    procedure Init(const aPath: string; const aTrainingStartDate: TDateTime; const
      aTrainingEndDate: TDateTime; const aUserName: string);
    class function Execute(const aPath: string; const aTrainingStartDate: TDateTime; const
      aTrainingEndDate: TDateTime; const aUserName: string): Boolean;
    property IsActive: Boolean read FIsActive write SetIsActive;
    Property OnStart: Boolean read FOnStart write SetOnStart;
  end;

  TNachweisTemplate = class(TObject)
  private
    FName: string;
    FSecondPersonTitle: string;
    FSecondPersonName: string;
    FThirdPersonTitle: string;
    FThirdPersonName: string;
    FPath: string;
    FTop: Integer;
    FHover: Boolean;
    FPaintNachweisTemplate: TPaintNachweisTemplate;
    procedure SetHover(const Value: Boolean);
  public
    constructor Create(const aName,aSecondPersonTitle,aSecondPersonName,aThirdPersonTitle,aThirdPersonName,aPath: string; const aTop: Integer);
    property Name: string read FName;
    property SecondPersonTitle: string read FSecondPersonTitle;
    property SecondPersonName: string read FSecondPersonName;
    property ThirdPersonTitle: string read FThirdPersonTitle;
    property ThirdPersonName: string read FThirdPersonName;
    property Path: string read FPath;
    property Top: Integer read FTop;
    property Hover: Boolean read FHover write SetHover;
    property PaintNachweisTemplate: TPaintNachweisTemplate read FPaintNachweisTemplate write FPaintNachweisTemplate;
  end;

  TNachweisTemplateList = class(TObjectList)
  private
    function Get(Index: Integer): TNachweisTemplate;
  public
    function Add(aNachweisTemplate: TNachweisTemplate): Integer;
    property Items[Index: Integer]: TNachweisTemplate read Get; default;
  end;

var
  FrmSettings: TFrmSettings;

implementation

uses
  Registry, FileUtils, Ausbildungsnachweise.Utils, ShellAPI;

{$R *.dfm}

{ TFrmSettings }

class function TFrmSettings.Execute(const aPath: string; const aTrainingStartDate,
  aTrainingEndDate: TDateTime; const aUserName: string): Boolean;
begin
  Application.CreateForm(TFrmSettings,FrmSettings);
  FrmSettings.Init(aPath,aTrainingStartDate,aTrainingEndDate,aUserName);
  Result:=FrmSettings.ShowModal=mrOk;
end;

procedure TFrmSettings.FormCreate(Sender: TObject);
begin
  NachweisTemplateList:=TNachweisTemplateList.Create;
end;

procedure TFrmSettings.FormDestroy(Sender: TObject);
begin
  NachweisTemplateList.Free;
end;

procedure TFrmSettings.Init(const aPath: string; const aTrainingStartDate, aTrainingEndDate: TDateTime;
  const aUserName: string);

  procedure GetServiceData(out IsActive,OnStart: Boolean; out Interval: Integer);
  var
    Registry: TRegistry;
  begin
    Registry:=TRegistry.Create;
    try
      Registry.RootKey:=HKEY_CURRENT_USER;
      try
        Registry.OpenKey('Software\Peripharos\Ausbildungsnachweise',False);
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
    case Interval of
      1000*60*30: Interval:=0;
      1000*60*60: Interval:=1;
      1000*60*60*2: Interval:=2;
      1000*60*60*3: Interval:=3;
      1000*60*60*6: Interval:=4;
      1000*60*60*8: Interval:=5;
      1000*60*60*12: Interval:=6;
      0: Interval:=7;
      else Interval:=0;
    end;
  end;

var
  Interval: Integer;
  VIsActive: Boolean;
  VOnStart: Boolean;
begin
  Path:=aPath;
  EdtUserName.Text:=aUserName;
  EdtTrainingStartDate.Text:=DateToStr(aTrainingStartDate);
  EdtTrainingEndDate.Text:=DateToStr(aTrainingEndDate);
  GetServiceData(VIsActive,VOnStart,Interval);
  IsActive:=VIsActive;
  OnStart:=VOnStart;
  EdtInterval.ItemIndex:=Interval;
  InitNachweisTemplates;
end;

procedure TFrmSettings.InitNachweisTemplates;
var
  Templates: TStringList;
  I: Integer;
  NachweisTemplate: TNachweisTemplate;
  Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string;
begin
  Templates:=TStringList.Create;
  try
    EnsureDirectory(AppendPath(Path,'Vorlagen\Templates'));
    DirectoryScan(AppendPath(Path,'Vorlagen\Templates'),Templates,DirScanParams([dsoNoSubFolders,dsoVerifyFolders]));
    for I:=0 to Templates.Count-1 do begin
      GetNachweisTemplateData(Templates[I],Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName);
      NachweisTemplate:=TNachweisTemplate.Create(Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName,Templates[I],I*NachweisTemplateHeight);
      NachweisTemplate.PaintNachweisTemplate:=PaintNachweisTemplate;
      NachweisTemplateList.Add(NachweisTemplate);
    end;
  finally
    Templates.Free;
  end;
  Image.Free;
  Image:=TImage.Create(Self);
  Image.Parent:=PnlTemplates;
  Image.Align:=alTop;
  Image.Width:=500;
  Image.Height:=NachweisTemplateList.Count*NachweisTemplateHeight;
  Image.OnClick:=ImageClick;
  Image.OnMouseLeave:=ImageMouseLeave;
  Image.OnMouseMove:=ImageMouseMove;
  PaintNachweisTemplateList;
end;

procedure TFrmSettings.SaveToRegistry;
var
  Registry: TRegistry;
  Interval: Integer;
begin
  case EdtInterval.ItemIndex of
    0: Interval:=1000*60*30;
    1: Interval:=1000*60*60;
    2: Interval:=1000*60*60*2;
    3: Interval:=1000*60*60*3;
    4: Interval:=1000*60*60*6;
    5: Interval:=1000*60*60*8;
    6: Interval:=1000*60*60*12;
    7: Interval:=0;
    else Interval:=1000*60*30;
  end;
  Registry:=TRegistry.Create;
  try
    Registry.RootKey:=HKEY_CURRENT_USER;
    Registry.OpenKey('Software\Peripharos\Ausbildungsnachweise',True);
    Registry.WriteString('UserName',EdtUserName.Text);
    Registry.WriteDate('TrainingStartDate',StrToDate(EdtTrainingStartDate.Text));
    Registry.WriteDate('TrainingEndDate',StrToDate(EdtTrainingEndDate.Text));
    Registry.WriteBool('IsActive',IsActive);
    Registry.WriteBool('OnStart',OnStart);
    Registry.WriteInteger('Interval',Interval);
  finally
    Registry.Free;
  end;
end;

procedure TFrmSettings.BtnAbbortClick(Sender: TObject);
begin
  ModalResult:=mrAbort;
end;

procedure TFrmSettings.BtnSaveClick(Sender: TObject);
var
  ProcessID: Cardinal;
begin
  SaveToRegistry;
  ModalResult:=mrOk;
  ProcessID:=GetProcessID('Ausbildungsnachweise.Service.exe');
  if (ProcessID<>0) then
    KillProcess(ProcessID);
  ShellExecute(Application.Handle,'open',PChar(GetservicePath),nil,nil,SW_SHOWNORMAL);
end;

procedure TFrmSettings.ImageClick(Sender: TObject);
var
  I: Integer;
begin
  for I:=0 to NachweisTemplateList.Count-1 do begin
    if NachweisTemplateList[I].Hover then begin
      if TFrmTemplate.Execute(NachweisTemplateList[I].Path,EdtUserName.Text) then begin
        NachweisTemplateList.Clear;
        InitNachweisTemplates;
        Exit;
      end;
    end;
  end;
end;

procedure TFrmSettings.ImageMouseLeave(Sender: TObject);
var
  I: Integer;
begin
  for I:=0 to NachweisTemplateList.Count-1 do
    NachweisTemplateList[I].Hover:=False;
end;

procedure TFrmSettings.ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
  I: Integer;
begin
  for I:=0 to NachweisTemplateList.Count-1 do
    NachweisTemplateList[I].Hover:=False;
  Index:=Y div NachweisTemplateHeight;
    NachweisTemplateList[Index].Hover:=True;
end;

procedure TFrmSettings.BtnAddClick(Sender: TObject);
var
  DestinationPath: string;
  I: Integer;
  HighestNumber: Integer;
begin
  DestinationPath:=AppendPath(Path,'Vorlagen\Templates');
  HighestNumber:=-1;
  for I:=0 to NachweisTemplateList.Count-1 do
    if StrToInt(ExtractFilePart(NachweisTemplateList[I].Path)) > HighestNumber then
      HighestNumber:=StrToInt(ExtractFilePart(NachweisTemplateList[I].Path));
  DestinationPath:=AppendPath(DestinationPath,IntToStr(HighestNumber+1)+'.txt');
  CreateNachweisTemplate(DestinationPath,'Namen hier eintragen','Titel 2. Person','Name 2.Person','Titel 3. Person','Name 3.Person');
  if TFrmTemplate.Execute(DestinationPath,EdtUserName.Text) then begin
    NachweisTemplateList.Clear;
    InitNachweisTemplates;
    Image.Height:=0;
    Image.Height:=NachweisTemplateList.Count*NachweisTemplateHeight;
  end;
end;

procedure TFrmSettings.PaintCheckbox(Canvas: TCanvas; const Width, Height: Integer; const Checked: Boolean);
var
  RememberPen: TPen;
  RemenberBrush: TBrush;
begin
  RememberPen:=Canvas.Pen;
  RemenberBrush:=Canvas.Brush;
  Canvas.Brush.Style:=bsSolid;
  Canvas.Brush.Color:=clWhite;
  Canvas.Pen.Style:=psSolid;
  Canvas.Pen.Color:=clBlack;
  Canvas.Pen.Width:=1;
  Canvas.Rectangle(0,0,Width,Height);
  if Checked then begin
    Canvas.Pen.Width:=2;
    Canvas.MoveTo(3,3);
    Canvas.LineTo(Width-4, Height-4);
    Canvas.MoveTo(Width-4,3);
    Canvas.LineTo(3, Height-4);
  end;
  Canvas.Brush:=RemenberBrush;
  Canvas.Pen:=RememberPen;
end;

procedure TFrmSettings.PaintNachweisTemplateList;
var
  I: Integer;
begin
  for I:=0 to NachweisTemplateList.Count-1 do
    PaintNachweisTemplate(NachweisTemplateList[I]);
end;

procedure TFrmSettings.PaintNachweisTemplate(const NachweisTemplate: TNachweisTemplate);
begin
  PaintNachweisTemplate(NachweisTemplate,Image.Canvas);
end;

procedure TFrmSettings.PaintNachweisTemplate(const NachweisTemplate: TNachweisTemplate; Canvas: TCanvas);
begin
  Canvas.Brush.Style:=bsSolid;
  Canvas.Brush.Color:=clWhite;
  Canvas.Pen.Color:=clBlack;
//  Canvas.Pen.Color:=clWhite;
  if NachweisTemplate.Hover then begin
    Canvas.Brush.Color:=$00FFF3E5;
//    Canvas.Pen.Color:=$00FFF3E5;
  end;
  Canvas.Font.Size:=12;
  Canvas.Font.Color:=clBlack;
  Canvas.Font.Style:=[fsBold];
  Canvas.Rectangle(0,NachweisTemplate.Top,Image.Width,NachweisTemplate.Top+NachweisTemplateHeight);
  Canvas.TextOut(20,NachweisTemplate.Top+2,NachweisTemplate.Name+':');
  Canvas.Font.Style:=[];
  Canvas.Font.Size:=10;
  Canvas.TextOut(10,NachweisTemplate.Top+22,'Auzubildender');
  Canvas.TextOut(10,NachweisTemplate.Top+60,'...........................');
  Canvas.Font.Style:=[fsBold];
  Canvas.TextOut(10,NachweisTemplate.Top+77,EdtUserName.Text);
  Canvas.Font.Style:=[];
  Canvas.Rectangle(169,NachweisTemplate.Top+23,170,NachweisTemplate.Top+NachweisTemplateHeight-3);
  Canvas.TextOut(180,NachweisTemplate.Top+22,NachweisTemplate.SecondPersonTitle);
  Canvas.TextOut(180,NachweisTemplate.Top+60,'..........................');
  Canvas.Font.Style:=[fsBold];
  Canvas.TextOut(180,NachweisTemplate.Top+77,NachweisTemplate.SecondPersonName);
  Canvas.Font.Style:=[];
  Canvas.Rectangle(339,NachweisTemplate.Top+23,340,NachweisTemplate.Top+NachweisTemplateHeight-3);
  Canvas.TextOut(350,NachweisTemplate.Top+22,NachweisTemplate.ThirdPersonTitle);
  Canvas.TextOut(350,NachweisTemplate.Top+60,'..........................');
  Canvas.Font.Style:=[fsBold];
  Canvas.TextOut(350,NachweisTemplate.Top+77,NachweisTemplate.ThirdPersonName);
  Canvas.Font.Style:=[];
end;

procedure TFrmSettings.EdtIsActiveClick(Sender: TObject);
begin
  IsActive:=not IsActive;
end;

procedure TFrmSettings.EdtOnStartClick(Sender: TObject);
begin
  OnStart:=not OnStart;
end;

procedure TFrmSettings.SetIsActive(const Value: Boolean);
begin
  FIsActive:=Value;
  PaintCheckbox(EdtIsActive.Canvas,EdtIsActive.Width,EdtIsActive.Height,Value);
end;

procedure TFrmSettings.SetOnStart(const Value: Boolean);
begin
  FOnStart:=Value;
  PaintCheckbox(EdtOnStart.Canvas,EdtOnStart.Width,EdtOnStart.Height,Value);
end;

{ TNachweisTemplate }

constructor TNachweisTemplate.Create(const aName,aSecondPersonTitle,aSecondPersonName,aThirdPersonTitle,
  aThirdPersonName,aPath: string; const aTop: Integer);
begin
  FName:=AName;
  FSecondPersonTitle:=ASecondPersonTitle;
  FSecondPersonName:=ASecondPersonName;
  FThirdPersonTitle:=AThirdPersonTitle;
  FThirdPersonName:=AThirdPersonName;
  FPath:=APath;
  FTop:=aTop;
end;

procedure TNachweisTemplate.SetHover(const Value: Boolean);
begin
  if Value<>FHover and Assigned(PaintNachweisTemplate) then begin
    FHover:=Value;
    PaintNachweisTemplate(Self);
  end;
end;

{ TNachweisTemplateList }

function TNachweisTemplateList.Add(aNachweisTemplate: TNachweisTemplate): Integer;
begin
  Result:=inherited Add(TObject(aNachweisTemplate));
end;

function TNachweisTemplateList.Get(Index: Integer): TNachweisTemplate;
begin
  Result:=TNachweisTemplate(inherited Get(Index));
end;

end.
