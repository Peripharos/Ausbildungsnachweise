unit Ausbildungsnachweise.Add;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Contnrs;

type
  TNachweisCreationList = class;

  TFrmAdd = class(TForm)
    PnlTop: TPanel;
    LblFromDate: TLabel;
    LblToDate: TLabel;
    EdtFrom: TComboBox;
    EdtTo: TComboBox;
    BtnAdd: TButton;
    LblTemplate: TLabel;
    EdtTemplates: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
  private
    NachweisCreationList: TNachweisCreationList;
    Path: string;
    TrainingStartDate: TDateTime;
  public
    procedure Init(const aPath: string; const aTrainingStartDate: TDateTime; const
      aTrainingEndDate: TDateTime);
    class function Execute(const aPath: string; const aTrainingStartDate: TDateTime; const
      aTrainingEndDate: TDateTime): Boolean;
  end;

  TNachweisCreationItem = class(TObject)
  private
    FWeek: Word;
    FYear: Word;
  public
    constructor Create(const AWeek, AYear: Word);
    property Week: Word read FWeek;
    property Year: Word read FYear;
  end;

  TNachweisCreationList = class(TObjectList)
  private
    function Get(Index: Integer): TNachweisCreationItem;
  public
    function Add(aNachweisCreationItem: TNachweisCreationItem): Integer;
    property Items[Index: Integer]: TNachweisCreationItem read Get; default;
  end;

var
  FrmAdd: TFrmAdd;

implementation

uses
  Ausbildungsnachweise.Utils, DateUtils, DateUtilsEx, FileUtils;

{$R *.dfm}

{ TFrmAdd }

class function TFrmAdd.Execute(const aPath: string; const aTrainingStartDate, aTrainingEndDate: TDateTime): Boolean;
begin
  Application.CreateForm(TFrmAdd,FrmAdd);
  FrmAdd.Init(aPath,aTrainingStartDate,aTrainingEndDate);
  Result:=FrmAdd.ShowModal=mrOk;
end;

procedure TFrmAdd.FormCreate(Sender: TObject);
begin
  NachweisCreationList:=TNachweisCreationList.Create;
end;

procedure TFrmAdd.FormDestroy(Sender: TObject);
begin
  NachweisCreationList.Free;
end;

procedure TFrmAdd.Init(const aPath: string; const aTrainingStartDate: TDateTime; const
  aTrainingEndDate: TDateTime);
var
  I: Integer;
  Week,Year: Word;
  Templates: TStringList;
  Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string;
begin
  Path:=aPath;
  TrainingStartDate:=aTrainingStartDate;
  for I:=Trunc(NthWeekdayFromDate(aTrainingStartDate,DayMonday,-1)) to Trunc(aTrainingEndDate) do begin
    if DayOfTheWeek(I)=DayMonday then begin
      Week:=WeekOfTheYear(I);
      Year:=YearOf(I);
      if not NachweisExist(aPath,Week,Year) then begin
        NachweisCreationList.Add(TNachweisCreationItem.Create(Week,Year));
        EdtFrom.Items.Add(CreateNachweisName(Week,Year));
        EdtTo.Items.Add(CreateNachweisName(Week,Year));
      end;
    end;
  end;
  Templates:=TStringList.Create;
  try
    EnsureDirectory(AppendPath(Path,'Vorlagen\Templates'));
    DirectoryScan(AppendPath(Path,'Vorlagen\Templates'),Templates,DirScanParams([dsoNoSubFolders,dsoVerifyFolders]));
    for I:=0 to Templates.Count-1 do begin
      GetNachweisTemplateData(Templates[I],Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName);
      EdtTemplates.Items.Add(Name);
    end;
  finally
    Templates.Free;
  end;
  EdtTemplates.ItemIndex:=0;
end;

procedure TFrmAdd.BtnAddClick(Sender: TObject);
var
  I: Integer;
begin
  if EdtFrom.ItemIndex<>-1 then begin
    if EdtTo.ItemIndex<>-1 then begin
      for I:=EdtFrom.ItemIndex to EdtTo.ItemIndex do begin
        CreateNachweis(Path,TrainingStartDate,NachweisCreationList[I].Week,NachweisCreationList[I].Year,EdtTemplates.Text);
      end;
    end else begin
      CreateNachweis(Path,TrainingStartDate,NachweisCreationList[EdtFrom.ItemIndex].Week,NachweisCreationList[EdtFrom.ItemIndex].Year,EdtTemplates.Text);
    end;
  end else begin
    if EdtTo.ItemIndex<>-1 then begin
      CreateNachweis(Path,TrainingStartDate,NachweisCreationList[EdtTo.ItemIndex].Week,NachweisCreationList[EdtTo.ItemIndex].Year,EdtTemplates.Text);
    end;
  end;
  ModalResult:=mrOk;
end;

{ TNachweisCreationItem }

constructor TNachweisCreationItem.Create(const AWeek, AYear: Word);
begin
  FWeek:=AWeek;
  FYear:=AYear;
end;

{ TNachweisCreationList }

function TNachweisCreationList.Add(aNachweisCreationItem:
  TNachweisCreationItem): Integer;
begin
  Result:=inherited Add(TObject(aNachweisCreationItem));
end;

function TNachweisCreationList.Get(Index: Integer): TNachweisCreationItem;
begin
  Result:=TNachweisCreationItem(inherited Get(Index));
end;

end.
