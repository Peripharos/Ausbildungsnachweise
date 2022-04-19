unit Ausbildungsnachweise.ShowDocument;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TSetEditFocus = procedure of object;

  TFrmShowDocument = class(TForm)
    LblCaption: TLabel;
    LblYearStatic: TLabel;
    LblYear: TLabel;
    LblYearOfTrainingStatic: TLabel;
    LblYearOfTraining: TLabel;
    LblWeekStatic: TLabel;
    LblWeek: TLabel;
    LblFromStatic: TLabel;
    LblFrom: TLabel;
    LblToStatic: TLabel;
    LblTo: TLabel;
    PnlBorder: TPanel;
    PnlMain: TPanel;
    LblActivity: TLabel;
    LblTime: TLabel;
    LblDay: TLabel;
    PnlMoBorder: TPanel;
    PnlMo: TPanel;
    LblMoDate: TLabel;
    LblMoDay: TLabel;
    EdtMoTa1: TEdit;
    EdtMoTa2: TEdit;
    EdtMoTa3: TEdit;
    EdtMoTa4: TEdit;
    EdtMoSt1: TEdit;
    EdtMoSt2: TEdit;
    EdtMoSt3: TEdit;
    EdtMoSt4: TEdit;
    EdtMoTa5: TEdit;
    EdtMoSt5: TEdit;
    PnlDi: TPanel;
    LblDiDate: TLabel;
    LblDiDay: TLabel;
    EdtDiTa1: TEdit;
    EdtDiTa2: TEdit;
    EdtDiTa3: TEdit;
    EdtDiTa4: TEdit;
    EdtDiSt1: TEdit;
    EdtDiSt2: TEdit;
    EdtDiSt3: TEdit;
    EdtDiSt4: TEdit;
    EdtDiTa5: TEdit;
    EdtDiSt5: TEdit;
    PnlMi: TPanel;
    LblMiDate: TLabel;
    LblMiDay: TLabel;
    EdtMiTa1: TEdit;
    EdtMiTa2: TEdit;
    EdtMiTa3: TEdit;
    EdtMiTa4: TEdit;
    EdtMiSt1: TEdit;
    EdtMiSt2: TEdit;
    EdtMiSt3: TEdit;
    EdtMiSt4: TEdit;
    EdtMiTa5: TEdit;
    EdtMiSt5: TEdit;
    PnlDo: TPanel;
    LblDoDate: TLabel;
    LblDoDay: TLabel;
    EdtDoTa1: TEdit;
    EdtDoTa2: TEdit;
    EdtDoTa3: TEdit;
    EdtDoTa4: TEdit;
    EdtDoSt1: TEdit;
    EdtDoSt2: TEdit;
    EdtDoSt3: TEdit;
    EdtDoSt4: TEdit;
    EdtDoTa5: TEdit;
    EdtDoSt5: TEdit;
    PnlFr: TPanel;
    LblFrDate: TLabel;
    LblFrDay: TLabel;
    EdtFrTa1: TEdit;
    EdtFrTa2: TEdit;
    EdtFrTa3: TEdit;
    EdtFrTa4: TEdit;
    EdtFrSt1: TEdit;
    EdtFrSt2: TEdit;
    EdtFrSt3: TEdit;
    EdtFrSt4: TEdit;
    EdtFrTa5: TEdit;
    EdtFrSt5: TEdit;
    Panel1: TPanel;
    Shp1: TShape;
    LblFirstPersonTitle: TLabel;
    LblFirstPersonSign: TLabel;
    LblFirstPersonName: TLabel;
    Shp2: TShape;
    LblSecondPersonName: TLabel;
    LblSecondPersonSign: TLabel;
    LblSecondPersonTitle: TLabel;
    LblThirdPersonName: TLabel;
    LblThirdPersonSign: TLabel;
    LblThirdPersonTitle: TLabel;
    procedure EdtChange(Sender: TObject);
    procedure EdtKeyPress(Sender: TObject; var Key: Char);
  private
    Filling: Boolean;
    Path: string;
    FSetEditFocus: TSetEditFocus;
  public
    procedure Fill(const aPath: string; const Edit: Boolean; const UserName: string);
    property SetEditFocus: TSetEditFocus read FSetEditFocus write FSetEditFocus;
  end;

var
  FrmShowDocument: TFrmShowDocument;

implementation

uses
  Ausbildungsnachweise.Utils, DateUtils, StrUtils;

{$R *.dfm}

{ TFrmShowDocument }

procedure TFrmShowDocument.EdtChange(Sender: TObject);
begin
  if not Filling then begin
    if AnsiStartsText('EdtMo',TEdit(Sender).Name) then begin
      SaveNachweisDayData(Path,DayMonday,EdtMoTa1.Text,EdtMoTa2.Text,EdtMoTa3.Text,EdtMoTa4.Text,EdtMoTa5.Text,
                                         EdtMoSt1.Text,EdtMoSt2.Text,EdtMoSt3.Text,EdtMoSt4.Text,EdtMoSt5.Text);
    end;
    if AnsiStartsText('EdtDi',TEdit(Sender).Name) then begin
      SaveNachweisDayData(Path,DayTuesday,EdtDiTa1.Text,EdtDiTa2.Text,EdtDiTa3.Text,EdtDiTa4.Text,EdtDiTa5.Text,
                                          EdtDiSt1.Text,EdtDiSt2.Text,EdtDiSt3.Text,EdtDiSt4.Text,EdtDiSt5.Text);
    end;
    if AnsiStartsText('EdtMi',TEdit(Sender).Name) then begin
      SaveNachweisDayData(Path,DayWednesday,EdtMiTa1.Text,EdtMiTa2.Text,EdtMiTa3.Text,EdtMiTa4.Text,EdtMiTa5.Text,
                                            EdtMiSt1.Text,EdtMiSt2.Text,EdtMiSt3.Text,EdtMiSt4.Text,EdtMiSt5.Text);
    end;
    if AnsiStartsText('EdtDo',TEdit(Sender).Name) then begin
      SaveNachweisDayData(Path,DayThursday,EdtDoTa1.Text,EdtDoTa2.Text,EdtDoTa3.Text,EdtDoTa4.Text,EdtDoTa5.Text,
                                           EdtDoSt1.Text,EdtDoSt2.Text,EdtDoSt3.Text,EdtDoSt4.Text,EdtDoSt5.Text);
    end;
    if AnsiStartsText('EdtFr',TEdit(Sender).Name) then begin
      SaveNachweisDayData(Path,DayFriday,EdtFrTa1.Text,EdtFrTa2.Text,EdtFrTa3.Text,EdtFrTa4.Text,EdtFrTa5.Text,
                                         EdtFrSt1.Text,EdtFrSt2.Text,EdtFrSt3.Text,EdtFrSt4.Text,EdtFrSt5.Text);
    end;
    SaveDataToPacked;
  end;
end;

procedure TFrmShowDocument.EdtKeyPress(Sender: TObject; var Key: Char);
begin
  if TEdit(Sender).ReadOnly then
    if (MessageDlg('Du bist momentan nur im Anzeige- und nicht im Bearbeite-Modus.'+#13+#10+'In den Bearbeite-Modus wechseln?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
      if Assigned(SetEditFocus) then
        SetEditFocus
end;

procedure TFrmShowDocument.Fill(const aPath: string; const Edit: Boolean; const UserName: string);
var
  Year,TrainingYear,Week: Word;
  FromDate,ToDate,DayDate: TDateTime;
  Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5: string;
  SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string;
  Dummy: string;
begin
  Filling:=True;
  Path:=aPath;
  GetNachweisDates(Path,Year,TrainingYear,Week,FromDate,ToDate);
  LblYear.Caption:=IntToStr(Year);
  LblYearOfTraining.Caption:=IntToStr(TrainingYear)+'.';
  LblWeek.Caption:=IntToStr(Week);
  LblFrom.Caption:=DateToStr(FromDate);
  LblTo.Caption:=DateToStr(ToDate);
  GetNachweisDayData(Path,DayMonday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  LblMoDate.Caption:=DateToStr(DayDate);
  EdtMoTa1.Text:=Ta1;
  EdtMoTa2.Text:=Ta2;
  EdtMoTa3.Text:=Ta3;
  EdtMoTa4.Text:=Ta4;
  EdtMoTa5.Text:=Ta5;
  EdtMoSt1.Text:=St1;
  EdtMoSt2.Text:=St2;
  EdtMoSt3.Text:=St3;
  EdtMoSt4.Text:=St4;
  EdtMoSt5.Text:=St5;
  GetNachweisDayData(Path,DayTuesday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  LblDiDate.Caption:=DateToStr(DayDate);
  EdtDiTa1.Text:=Ta1;
  EdtDiTa2.Text:=Ta2;
  EdtDiTa3.Text:=Ta3;
  EdtDiTa4.Text:=Ta4;
  EdtDiTa5.Text:=Ta5;
  EdtDiSt1.Text:=St1;
  EdtDiSt2.Text:=St2;
  EdtDiSt3.Text:=St3;
  EdtDiSt4.Text:=St4;
  EdtDiSt5.Text:=St5;
  GetNachweisDayData(Path,DayWednesday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  LblMiDate.Caption:=DateToStr(DayDate);
  EdtMiTa1.Text:=Ta1;
  EdtMiTa2.Text:=Ta2;
  EdtMiTa3.Text:=Ta3;
  EdtMiTa4.Text:=Ta4;
  EdtMiTa5.Text:=Ta5;
  EdtMiSt1.Text:=St1;
  EdtMiSt2.Text:=St2;
  EdtMiSt3.Text:=St3;
  EdtMiSt4.Text:=St4;
  EdtMiSt5.Text:=St5;
  GetNachweisDayData(Path,DayThursday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  LblDoDate.Caption:=DateToStr(DayDate);
  EdtDoTa1.Text:=Ta1;
  EdtDoTa2.Text:=Ta2;
  EdtDoTa3.Text:=Ta3;
  EdtDoTa4.Text:=Ta4;
  EdtDoTa5.Text:=Ta5;
  EdtDoSt1.Text:=St1;
  EdtDoSt2.Text:=St2;
  EdtDoSt3.Text:=St3;
  EdtDoSt4.Text:=St4;
  EdtDoSt5.Text:=St5;
  GetNachweisDayData(Path,DayFriday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  LblFrDate.Caption:=DateToStr(DayDate);
  EdtFrTa1.Text:=Ta1;
  EdtFrTa2.Text:=Ta2;
  EdtFrTa3.Text:=Ta3;
  EdtFrTa4.Text:=Ta4;
  EdtFrTa5.Text:=Ta5;
  EdtFrSt1.Text:=St1;
  EdtFrSt2.Text:=St2;
  EdtFrSt3.Text:=St3;
  EdtFrSt4.Text:=St4;
  EdtFrSt5.Text:=St5;
  GetNachweisTemplateData(FindNachweisTemplate((GetNachweisTemplate(Path))),Dummy,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName);
  LblFirstPersonTitle.Caption:='Auszubildender';
  LblFirstPersonName.Caption:=UserName;
  LblSecondPersonTitle.Caption:=SecondPersonTitle;
  LblSecondPersonName.Caption:=SecondPersonName;
  LblThirdPersonTitle.Caption:=ThirdPersonTitle;
  LblThirdPersonName.Caption:=ThirdPersonName;
  EdtMoTa1.ReadOnly:=not Edit;
  EdtMoTa2.ReadOnly:=not Edit;
  EdtMoTa3.ReadOnly:=not Edit;
  EdtMoTa4.ReadOnly:=not Edit;
  EdtMoTa5.ReadOnly:=not Edit;
  EdtMoSt1.ReadOnly:=not Edit;
  EdtMoSt2.ReadOnly:=not Edit;
  EdtMoSt3.ReadOnly:=not Edit;
  EdtMoSt4.ReadOnly:=not Edit;
  EdtMoSt5.ReadOnly:=not Edit;
  EdtDiTa1.ReadOnly:=not Edit;
  EdtDiTa2.ReadOnly:=not Edit;
  EdtDiTa3.ReadOnly:=not Edit;
  EdtDiTa4.ReadOnly:=not Edit;
  EdtDiTa5.ReadOnly:=not Edit;
  EdtDiSt1.ReadOnly:=not Edit;
  EdtDiSt2.ReadOnly:=not Edit;
  EdtDiSt3.ReadOnly:=not Edit;
  EdtDiSt4.ReadOnly:=not Edit;
  EdtDiSt5.ReadOnly:=not Edit;
  EdtMiTa1.ReadOnly:=not Edit;
  EdtMiTa2.ReadOnly:=not Edit;
  EdtMiTa3.ReadOnly:=not Edit;
  EdtMiTa4.ReadOnly:=not Edit;
  EdtMiTa5.ReadOnly:=not Edit;
  EdtMiSt1.ReadOnly:=not Edit;
  EdtMiSt2.ReadOnly:=not Edit;
  EdtMiSt3.ReadOnly:=not Edit;
  EdtMiSt4.ReadOnly:=not Edit;
  EdtMiSt5.ReadOnly:=not Edit;
  EdtDoTa1.ReadOnly:=not Edit;
  EdtDoTa2.ReadOnly:=not Edit;
  EdtDoTa3.ReadOnly:=not Edit;
  EdtDoTa4.ReadOnly:=not Edit;
  EdtDoTa5.ReadOnly:=not Edit;
  EdtDoSt1.ReadOnly:=not Edit;
  EdtDoSt2.ReadOnly:=not Edit;
  EdtDoSt3.ReadOnly:=not Edit;
  EdtDoSt4.ReadOnly:=not Edit;
  EdtDoSt5.ReadOnly:=not Edit;
  EdtFrTa1.ReadOnly:=not Edit;
  EdtFrTa2.ReadOnly:=not Edit;
  EdtFrTa3.ReadOnly:=not Edit;
  EdtFrTa4.ReadOnly:=not Edit;
  EdtFrTa5.ReadOnly:=not Edit;
  EdtFrSt1.ReadOnly:=not Edit;
  EdtFrSt2.ReadOnly:=not Edit;
  EdtFrSt3.ReadOnly:=not Edit;
  EdtFrSt4.ReadOnly:=not Edit;
  EdtFrSt5.ReadOnly:=not Edit;
  Filling:=False;
end;

end.
