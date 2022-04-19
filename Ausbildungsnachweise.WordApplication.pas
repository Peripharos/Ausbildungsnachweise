unit Ausbildungsnachweise.WordApplication;

interface

uses
  Windows, Word2000, Classes, Messages;

type
  TMyWordApplication = class(TWordApplication)
  private
    procedure CloseOpenDocuments;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenDocument(const aFileName: string);
    procedure PrintActiveDocument;
  end;

implementation

uses
  Variants, SysUtils, Forms;

{ TMyWordApplication }

constructor TMyWordApplication.Create(AOwner: TComponent);
begin
  inherited;
  Connect;
end;

destructor TMyWordApplication.Destroy;
begin
  CloseOpenDocuments;
  Disconnect;
  Quit;
  inherited;
end;

procedure TMyWordApplication.OpenDocument(const aFileName: string);

  procedure Reset;
  begin
    Disconnect;
    Connect;
    OpenDocument(aFileName);
  end;

var
  FileName: OleVariant;  
begin
  try
    CloseOpenDocuments;
    FileName:=aFileName;
    Documents.OpenOld(FileName, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
                      EmptyParam, EmptyParam, EmptyParam, EmptyParam);
  except
    Reset;
  end;
end;

procedure TMyWordApplication.PrintActiveDocument;
var
  FileName: OleVariant;
  Background, Append, Range: OleVariant;
begin
  Background:=False;
  Append:=False;
  Range:=wdPrintAllPages;
  ActiveDocument.PrintOut(Background, Append, Range,EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
                          EmptyParam, EmptyParam, EmptyParam, EmptyParam,EmptyParam, EmptyParam, EmptyParam,
                          EmptyParam, EmptyParam, EmptyParam);
end;

procedure TMyWordApplication.CloseOpenDocuments;
var
  I: Integer;
  Index: OleVariant;
begin
  if Documents.Count<>0 then
    Documents.Close(EmptyParam, EmptyParam, EmptyParam);
end;

end.
