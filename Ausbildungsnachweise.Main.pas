unit Ausbildungsnachweise.Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, Buttons, Ausbildungsnachweise.Utils, Contnrs, ImgList,
  Ausbildungsnachweise.ShowDocument, ToolWin, ComCtrls, ActnList, Registry, GIFImg;

const
  WM_GETREGISTRYDATA = WM_USER+1;
  WM_UNPACKDATA = WM_USER+2;
  WM_INITNACHWEISE = WM_USER+3;
  NachweisHeight = 25;

type
  TNachweis = class;
  TNachweisList = class;
  TPaintNachweis = procedure(const Nachweis: TNachweis) of object;

  TFrmMain = class(TForm)
    PnlClient: TPanel;
    PnlLeft: TScrollBox;
    PnlAdd: TPanel;
    BtnAdd: TSpeedButton;
    PopupMenu: TPopupMenu;
    PMIOpen: TMenuItem;
    PMIPrint: TMenuItem;
    Image: TImage;
    PnlTop: TPanel;
    WordImage: TImageList;
    ActionList: TActionList;
    ActEdit: TAction;
    ActSaveAt: TAction;
    ActNextStep: TAction;
    ActPrint: TAction;
    ImageList: TImageList;
    Speicherunter1: TMenuItem;
    Anzeigen1: TMenuItem;
    ActionList1: TActionList;
    ToolBar: TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ActSettings: TAction;
    PnlTopLeft: TPanel;
    PnlTopRight: TPanel;
    ToolBarSettings: TToolBar;
    ToolButton1: TToolButton;
    ChooseDirectory: TFileOpenDialog;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure ImageDblClick(Sender: TObject);
    procedure ImageMouseLeave(Sender: TObject);
    procedure ActEditExecute(Sender: TObject);
    procedure ActNextStepExecute(Sender: TObject);
    procedure ActSaveAtExecute(Sender: TObject);
    procedure ActPrintExecute(Sender: TObject);
    procedure ActSettingsExecute(Sender: TObject);
    procedure ActUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    NachweisList: TNachweisList;
    UserName: string;
    TrainingStartDate: TDateTime;
    TrainingEndDate: TDateTime;
    ShowDocument: TFrmShowDocument;
    LastKlickedNachweis: Integer;
    ImageDblKlick: Boolean;
    Editing: Boolean;
    FLoading: Boolean;
    procedure WMGetRegistryData(var Message: TMessage); message WM_GETREGISTRYDATA;
    procedure WMUnpackData(var Message: TMessage); message WM_UNPACKDATA;
    procedure WMInitNachweise(var Message: TMessage); message WM_INITNACHWEISE;
    procedure OnMove(var Msg: TWMMove); message WM_MOVE;
    procedure PaintNachweiseList;
    procedure PaintNachweis(const Nachweis: TNachweis); overload;
    procedure PaintNachweis(const Nachweis: TNachweis; Canvas: TCanvas; WordImage: TIcon); overload;
    procedure SetEditFocus;
    procedure SetLoading(const Value: Boolean);
    procedure OnThreadFinished;
    procedure UpdateLoader;
  public
    property Loading: Boolean read FLoading write SetLoading;
  end;

  TNachweis = class(Tobject)
  private
    FName: string;
    FState: TState;
    FTop: Integer;
    FPath: string;
    FTemplate: string;
    FHover: Boolean;
    FActive: Boolean;
    FShiftActive: Boolean;
    FPaintNachweis: TPaintNachweis;
    procedure SetState(const Value: TState);
    procedure SetActive(const Value: Boolean);
    procedure SetHover(const Value: Boolean);
  public
    constructor Create(const aName: string; const aState: TState; const aTop: Integer; const aPath: string);
    property Name: string read FName;
    property State: TState read FState write SetState;
    property Template: string read FTemplate;
    property Top: Integer read FTop;
    property Path: string read FPath;
    property Hover: Boolean read FHover write SetHover;
    property Active: Boolean read FActive write SetActive;
    property ShiftActive: Boolean read FShiftActive write FShiftActive;
    property PaintNachweis: TPaintNachweis read FPaintNachweis write FPaintNachweis;
  end;

  TNachweisList = class(TObjectList)
  private
    function Get(Index: Integer): TNachweis;
  public
    function Add(aNachweis: TNachweis): Integer;
    property Items[Index: Integer]: TNachweis read Get; default;
  end;

var
  FrmMain: TFrmMain;
  Path: string;

implementation

uses
  FileUtils, Ausbildungsnachweise.Add, Ausbildungsnachweise.Settings,
  Ausbildungsnachweise.Shadow;

{$R *.dfm}

{ TFrmMain }

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  NachweisList:=TNachweisList.Create;
  LastKlickedNachweis:=-1;
  Loading:=False;
  PostMessage(Handle,WM_GETREGISTRYDATA,0,0);
  PostMessage(Handle,WM_UNPACKDATA,0,0);
  PostMessage(Handle,WM_INITNACHWEISE,0,0);
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=not Loading;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  NachweisList.Free;
  SaveDataToPacked(True);
end;

procedure TFrmMain.WMGetRegistryData(var Message: TMessage);
var
  Registry: TRegistry;
begin
  Registry:=TRegistry.Create;
  try
    Registry.RootKey:=HKEY_CURRENT_USER;
    try
      Registry.OpenKey('Software\Peripharos\Ausbildungsnachweise',False);
      UserName:=Registry.ReadString('UserName');
      TrainingStartDate:=Registry.ReadDate('TrainingStartDate');
      TrainingEndDate:=Registry.ReadDate('TrainingEndDate');
    except
      UserName:='Auzubildender';
      TrainingStartDate:=MinDateTime;
      TrainingEndDate:=MaxDateTime;
    end;
  finally
    Registry.Free;
  end;
end;

procedure TFrmMain.WMUnpackData(var Message: TMessage);
begin
  UnpackData(Path);
end;

procedure TFrmMain.WMInitNachweise(var Message: TMessage);
var
  Nachweise: TStringList;
  I: Integer;
  Nachweis: TNachweis;
begin
  Nachweise:=TStringList.Create;
  try
    EnsureDirectory(AppendPath(Path,'Data'));
    DirectoryScan(AppendPath(Path,'Data'),Nachweise,DirScanParams([dsoNoSubFolders,dsoVerifyFolders]));
    for I:=0 to Nachweise.Count-1 do begin
      if (ExtractFilePart(Nachweise[I]) <> 'Vorlagen') and (ExtractFilePart(Nachweise[I]) <> 'Resources') then begin
        Nachweis:=TNachweis.Create(GetNachweisName(Nachweise[I]),GetNachweisState(Nachweise[I]),I*NachweisHeight,Nachweise[I]);
        Nachweis.PaintNachweis:=PaintNachweis;
        NachweisList.Add(Nachweis);
      end;
    end;
  finally
    Nachweise.Free;
  end;
  Image.Free;
  Image:=TImage.Create(Self);
  Image.Parent:=PnlLeft;
  Image.Align:=alTop;
  Image.Width:=196;
  Image.Height:=NachweisList.Count*NachweisHeight;
  Image.OnMouseMove:=ImageMouseMove;
  Image.ONMouseDown:=ImageMouseDown;
  Image.OnMouseLeave:=ImageMouseLeave;
  Image.OnDblClick:=ImageDblClick;
  PaintNachweiseList;
  ShowDocument:=TFrmShowDocument.Create(nil);
  ShowDocument.Parent:=PnlClient;
  ShowDocument.SetEditFocus:=SetEditFocus;
  if (ShowDocument.Width <= PnlClient.Width) and (ShowDocument.Height <= PnlClient.Height) then begin
    ShowDocument.Show;
    ShowDocument.Left:=(PnlClient.Width-ShowDocument.Width) div 2;
    ShowDocument.Top:=(PnlClient.Height-ShowDocument.Height) div 2;
  end else begin
    ShowDocument.Hide;
  end;
end;

procedure TFrmMain.FormResize(Sender: TObject);
begin
  if Assigned(ShowDocument) then begin
    if (ShowDocument.Width <= PnlClient.Width) and (ShowDocument.Height <= PnlClient.Height) then begin
      ShowDocument.Show;
      ShowDocument.Left:=(PnlClient.Width-ShowDocument.Width) div 2;
      ShowDocument.Top:=(PnlClient.Height-ShowDocument.Height) div 2;
    end else begin
      ShowDocument.Hide;
    end;
  end;
  UpdateLoader;
end;

procedure TFrmMain.OnMove(var Msg: TWMMove);
begin
  inherited;
  UpdateLoader;
end;

procedure TFrmMain.PaintNachweiseList;
var
  I: Integer;
  Icon: TIcon;
begin
   Icon:=TIcon.Create;
  WordImage.GetIcon(0,Icon);
  for I:=0 to NachweisList.Count-1 do
    PaintNachweis(NachweisList[I],Image.Canvas,Icon);
end;

procedure TFrmMain.PaintNachweis(const Nachweis: TNachweis);
var
  Icon: TIcon;
  I: Integer;
begin
  Icon:=TIcon.Create;
  WordImage.GetIcon(0,Icon);
  PaintNachweis(Nachweis,Image.Canvas,Icon);
end;

procedure TFrmMain.PaintNachweis(const Nachweis: TNachweis; Canvas: TCanvas; WordImage: TIcon);  // Hover Variable
begin
  Canvas.Brush.Style:=bsSolid;
  Canvas.Brush.Color:=clWhite;
  Canvas.Pen.Color:=clWhite;
  if Nachweis.Hover then begin
    Canvas.Brush.Color:=$00FFF3E5;
    Canvas.Pen.Color:=$00FFF3E5;
  end;
  if Nachweis.Active then begin
    Canvas.Brush.Color:=$00FFE8CC;
    Canvas.Pen.Color:=$00FFD199;
  end;
  Canvas.Font.Size:=10;
  Canvas.Font.Color:=clBlack;
  Canvas.Rectangle(0,Nachweis.Top,Image.Width,Nachweis.Top+NachweisHeight);
  Canvas.Draw(2,Nachweis.Top+2,WordImage);
  Canvas.TextOut(30,Nachweis.Top+4,Nachweis.Name);
  Canvas.Font.Size:=8;
  case Nachweis.State of
    stInWork: begin
      Canvas.Font.Color:=clRed;
      Canvas.TextOut(140,Nachweis.Top+6,'In Arbeit');
    end;
    stFinished: begin
      Canvas.Font.Color:=$004FE9F7;
      Canvas.TextOut(140,Nachweis.Top+6,'Ausgefüllt');
    end;
    stPrinted: begin
      Canvas.Font.Color:=clGreen;
      Canvas.TextOut(140,Nachweis.Top+6,'Gedruckt');
    end;
  end;
end;

procedure TFrmMain.BtnAddClick(Sender: TObject);
begin
  if TFrmAdd.Execute(AppendPath(Path,'Data'),TrainingStartDate,TrainingEndDate) then begin
    NachweisList.Clear;
    PostMessage(Handle,WM_INITNACHWEISE,0,0);
  end;
end;

procedure TFrmMain.ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
  I: Integer;
begin
  for I:=0 to NachweisList.Count-1 do
    NachweisList[I].Hover:=False;
  Index:=Y div NachweisHeight;
    NachweisList[Index].Hover:=True;
end;

procedure TFrmMain.ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
  ShiftIndex: Integer;
  I: Integer;
  ShiftActiveExist: Boolean;
begin
  if ImageDblKlick then begin
    ImageDblKlick:=False;
    Exit;
  end;
  Editing:=False;
  Index:=Y div NachweisHeight;
  ShiftIndex:=0;
  ShiftActiveExist:=False;
  if Button = mbLeft then begin
    if not(ssShift in Shift) and not(ssCtrl in Shift) then begin
      for I:=0 to NachweisList.Count-1 do begin
        NachweisList[I].Active:=False;
        NachweisList[I].ShiftActive:=False;
      end;
      NachweisList[Index].Active:=True;
      NachweisList[Index].ShiftActive:=True;
    end;
    if  (ssShift in Shift) and not(ssCtrl in Shift) then begin
      for I:=0 to NachweisList.Count-1 do begin
        if not NachweisList[I].ShiftActive then
          NachweisList[I].Active:=False
        else
          ShiftIndex:=I;
      end;
      if Index > ShiftIndex then begin
        Index:=Index+ShiftIndex;
        ShiftIndex:=Index-ShiftIndex;
        Index:=Index-ShiftIndex;
      end;
      for I:=Index to ShiftIndex do
        NachweisList[I].Active:=True;
    end;
    if  not(ssShift in Shift) and (ssCtrl in Shift) then begin
      for I:=0 to NachweisList.Count-1 do
        if NachweisList[I].ShiftActive then
          ShiftActiveExist:=True;
      NachweisList[Index].Active:=True;
      NachweisList[Index].ShiftActive:=not ShiftActiveExist;
    end;
    if  (ssShift in Shift) and (ssCtrl in Shift) then begin
      for I:=0 to NachweisList.Count-1 do
        if NachweisList[I].ShiftActive then
          ShiftIndex:=I;
      if Index > ShiftIndex then begin
        Index:=Index+ShiftIndex;
        ShiftIndex:=Index-ShiftIndex;
        Index:=Index-ShiftIndex;
      end;
      for I:=Index to ShiftIndex do
        NachweisList[I].Active:=True;
    end;
    ShowDocument.Fill(NachweisList[Index].Path,False,UserName);
  end;
  if Button = mbRight then begin
    if not NachweisList[Index].Active then begin
      for I:=0 to NachweisList.Count-1 do begin
        NachweisList[I].Active:=False;
        NachweisList[I].ShiftActive:=False;
      end;
      NachweisList[Index].Active:=True;
      NachweisList[Index].ShiftActive:=True;
    end;
  end;

  LastKlickedNachweis:=Index;
end;

procedure TFrmMain.ImageMouseLeave(Sender: TObject);
var
  I: Integer;
begin
  for I:=0 to NachweisList.Count-1 do
    NachweisList[I].Hover:=False;
end;

procedure TFrmMain.ImageDblClick(Sender: TObject);
begin
  ImageDblKlick:=True;
  SetEditFocus;
end;

procedure TFrmMain.SetEditFocus;
var
  I: Integer;
begin
  Editing:=True;
  for I:=0 to NachweisList.Count-1 do begin
    NachweisList[I].Active:=False;
    NachweisList[I].ShiftActive:=False;
  end;
  NachweisList[LastKlickedNachweis].Active:=True;
  NachweisList[LastKlickedNachweis].ShiftActive:=True;
  ShowDocument.Fill(NachweisList[LastKlickedNachweis].Path,True,UserName);
end;

procedure TFrmMain.ActEditExecute(Sender: TObject);
begin
  SetEditFocus;
end;

procedure TFrmMain.ActUpdate(Sender: TObject);
var
  I: Integer;
  NumberActive,NumberNotPrinted: Integer;
begin
  NumberActive:=0;
  NumberNotPrinted:=0;
  for I:=0 to NachweisList.Count-1 do begin
    if NachweisList[I].Active then begin
      Inc(NumberActive);
      if NachweisList[I].State<>stPrinted then
        Inc(NumberNotPrinted);
    end;
  end;
  ActEdit.Enabled:=(NumberActive=1) and not Editing;
  ActNextStep.Enabled:=(NumberActive>=1) and (NumberNotPrinted>=1);
  ActSaveAt.Enabled:=NumberActive>=1;
  ActPrint.Enabled:=NumberActive>=1;
end;

procedure TFrmMain.ActNextStepExecute(Sender: TObject);
var
  I: Integer;
begin
  for I:=0 to NachweisList.Count-1 do begin
    if NachweisList[I].Active then begin
      NachweisList[I].State:=NextNachweisState(NachweisList[I].Path);
    end;
  end;
  SaveDataToPacked;
end;

procedure TFrmMain.ActSaveAtExecute(Sender: TObject);
var
  PathList: TStringList;
  I: Integer;
begin
  ChooseDirectory.DefaultFolder:='C:\';
  if ChooseDirectory.Execute then begin
    Loading:=True;
    PathList:=TStringList.Create;
    try
      for I:=0 to NachweisList.Count-1 do begin
        if NachweisList[I].Active then begin
          PathList.Add(NachweisList[I].Path);
        end;
      end;
      SaveNachweisAtThreaded(PathList,UserName,ChooseDirectory.FileName,False,OnThreadFinished);
    finally
      PathList.Free;
    end;
  end;
end;

procedure TFrmMain.ActPrintExecute(Sender: TObject);
var
  PathList: TStringList;
  I: Integer;
begin
  Loading:=True;
  PathList:=TStringList.Create;
  try
    for I:=0 to NachweisList.Count-1 do begin
      if NachweisList[I].Active then begin
        PathList.Add(NachweisList[I].Path);
      end;
    end;
    PrintNachweisThreaded(PathList,UserName,OnThreadFinished);
  finally
    PathList.Free;
  end;
end;

procedure TFrmMain.ActSettingsExecute(Sender: TObject);
begin
  if TFrmSettings.Execute(AppendPath(Path,'Data'),TrainingStartDate,TrainingEndDate,UserName) then
    PostMessage(Handle,WM_GETREGISTRYDATA,0,0);
end;

procedure TFrmMain.OnThreadFinished;
begin
  Loading:=False;
end;

procedure TFrmMain.SetLoading(const Value: Boolean);
begin
  FLoading:=Value;
  if Value then begin
    FrmShadow:=TFrmShadow.Create(Self);
  end else begin
    FreeAndNil(FrmShadow);
  end;
  UpdateLoader;  
end;

procedure TFrmMain.UpdateLoader;
var
  pnt: TPoint;
  rgn, rgnCtrl: HRGN;
  i: Integer;
begin
  if not Assigned(FrmShadow) then Exit;
  FrmShadow.Show;
  FrmShadow.PopupParent:=Self;
  pnt:=ClientToScreen(Point(0, 0));
  FrmShadow.SetBounds(pnt.X, pnt.Y, ClientWidth, ClientHeight);
  rgn:=CreateRectRgn(0, 0, FrmShadow.Width, FrmShadow.Height);
  for i:=0 to ControlCount - 1 do
    if Controls[i].Tag = 1 then
    begin
      if not (Controls[i] is TWinControl) then Continue;
      with Controls[i] do
        rgnCtrl := CreateRectRgn(Left, Top, Left+Width, Top+Height);
      CombineRgn(rgn, rgn, rgnCtrl, RGN_DIFF);
      DeleteObject(rgnCtrl);
    end;
    SetWindowRgn(FrmShadow.Handle, rgn, true);
    DeleteObject(rgn);
end;

{ TNachweis }

constructor TNachweis.Create(const aName: string; const aState: TState; const aTop: Integer;
  const aPath: string);
begin
  FName:=aName;
  FState:=aState;
  FTop:=aTop;
  FPath:=aPath;
end;

procedure TNachweis.SetHover(const Value: Boolean);
begin
  if Value<>FHover and not Active and Assigned(PaintNachweis) then begin
    FHover:=Value;
    PaintNachweis(Self);
  end;
end;

procedure TNachweis.SetState(const Value: TState);
begin
  FState:=Value;
  if Assigned(PaintNachweis) then
    PaintNachweis(Self);
end;

procedure TNachweis.SetActive(const Value: Boolean);
begin
  if Value<>FActive and Assigned(PaintNachweis) then begin
    FActive:=Value;
    PaintNachweis(Self);
  end;
end;

{ TNachweisList }

function TNachweisList.Add(aNachweis: TNachweis): Integer;
begin
  Result:=inherited Add(TObject(aNachweis));
end;

function TNachweisList.Get(Index: Integer): TNachweis;
begin
  Result:=TNachweis(inherited Get(Index));
end;

end.
