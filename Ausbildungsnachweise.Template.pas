unit Ausbildungsnachweise.Template;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TFrmTemplate = class(TForm)
    PnlName: TPanel;
    EdtName: TMemo;
    Shp1: TShape;
    Shp2: TShape;
    LblFirstPersonTitle: TLabel;
    LblFirstPersonSign: TLabel;
    LblFirstPersonName: TLabel;
    LblSecondPersonSign: TLabel;
    LblThirdPersonSign: TLabel;
    EdtSecondPersonTitle: TMemo;
    EdtThirdPersonTitle: TMemo;
    EdtThirdPersonName: TMemo;
    EdtSecondPersonName: TMemo;
    BtnEdit: TButton;
    BtnAbbort: TButton;
    BtnDelete: TButton;
    procedure BtnEditClick(Sender: TObject);
    procedure BtnAbbortClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
  private
    Path: string;
  public
    procedure Init(const aPath,aUserName: string);
    class function Execute(const aPath,aUserName: string): Boolean;
  end;

var
  FrmTemplate: TFrmTemplate;

implementation

uses
  Ausbildungsnachweise.Utils;

{$R *.dfm}

{ TFrmTemplate }

procedure TFrmTemplate.BtnAbbortClick(Sender: TObject);
begin
  ModalResult:=mrAbort;
end;

procedure TFrmTemplate.BtnDeleteClick(Sender: TObject);
begin
  DeleteFile(Path);
  ModalResult:=mrOk;
end;

procedure TFrmTemplate.BtnEditClick(Sender: TObject);
begin
  SaveNachweisTemplateData(Path,EdtName.Text,EdtSecondPersonTitle.Text,EdtSecondPersonName.Text,
                                             EdtThirdPersonTitle.Text,EdtThirdPersonName.Text);
  ModalResult:=mrOk;
end;

class function TFrmTemplate.Execute(const aPath,aUserName: string): Boolean;
begin
  Application.CreateForm(TFrmTemplate,FrmTemplate);
  FrmTemplate.Init(aPath,aUserName);
  Result:=FrmTemplate.ShowModal=mrOk;
end;

procedure TFrmTemplate.Init(const aPath,aUserName: string);
var
  Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string;
begin
  Path:=aPath;
  GetNachweisTemplateData(aPath,Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName);
  LblFirstPersonName.Caption:=aUserName;
  EdtName.Text:=Name;
  EdtSecondPersonTitle.Text:=SecondPersonTitle;
  EdtSecondPersonName.Text:=SecondPersonName;
  EdtThirdPersonTitle.Text:=ThirdPersonTitle;
  EdtThirdPersonName.Text:=ThirdPersonName;
end;

end.
