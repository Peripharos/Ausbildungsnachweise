unit Ausbildungsnachweise.Shadow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, GIFImg, pngimage;

type
  TTimerProc = procedure of object;

  TFrmShadow = class(TForm)
    Image: TImage;
    LoaderTimer: TTimer;
    Image2: TImage;
    procedure FormResize(Sender: TObject);
    procedure LoaderTimerTimer(Sender: TObject);
  private
    Img1AtFront: Boolean;
  public
  
  end;

var
  FrmShadow: TFrmShadow;

implementation

uses
  Ausbildungsnachweise.Utils, FileUtils;

{$R *.dfm}

procedure TFrmShadow.FormResize(Sender: TObject);
begin
  Image.Left:=(FrmShadow.Width-Image.Width) div 2;
  Image.Top:=(FrmShadow.Height-Image.Height) div 2;
  Image2.Left:=(FrmShadow.Width-Image2.Width) div 2;
  Image2.Top:=(FrmShadow.Height-Image2.Height) div 2;
end;

procedure TFrmShadow.LoaderTimerTimer(Sender: TObject);
begin
  if Img1AtFront then begin
    Image2.Picture.LoadFromFile(AppendPath(AppendPath(GetEnvironmentVariable('TEMP'),'Peripharos\Asubildungsnachweise\Data'),
                                          'Resources\Spinner\'+IntToStr(LoaderTimer.Tag)+'.png'));
    Image2.BringToFront;
    Img1AtFront:=False;
  end else begin
    Image.Picture.LoadFromFile(AppendPath(AppendPath(GetEnvironmentVariable('TEMP'),'Peripharos\Asubildungsnachweise\Data'),
                                          'Resources\Spinner\'+IntToStr(LoaderTimer.Tag)+'.png'));
    Image.BringToFront;
    Img1AtFront:=True;
  end;
  LoaderTimer.Tag:=LoaderTimer.Tag+1;
  if LoaderTimer.Tag=25 then
    LoaderTimer.Tag:=1;
end;

end.
