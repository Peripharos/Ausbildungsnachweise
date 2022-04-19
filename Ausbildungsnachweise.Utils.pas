unit Ausbildungsnachweise.Utils;

interface

uses
  Graphics, Controls, EZCrypt, DateUtils, DateUtilsEx,
  AusbildungsNachweise.WordApplication,Word2000, Classes;
type
  TState = (stInWork, stFinished, stPrinted);

  TOnThreadFinish = procedure of object;

function GetservicePath: string;

function StringIndex(const SwitchString: string; const CaseStrings: array of String; const GroﬂKlein: Boolean = True): Integer;

procedure UnpackData(out DataPath: string);
procedure SaveDataToPacked(const DeleteUnpacked: Boolean = False);

function GetNachweisName(const Path: string): string;
function CreateNachweisName(const Week,Year: Word): string;
function GetNachweisState(const Path: string): TState;
function NextNachweisState(const Path: string): TState;
function GetNachweisTemplate(const Path: string): string;
procedure GetNachweisDates(const Path: string; out Year,TrainingYear,Week: Word; out FromDate,ToDate: TDateTime);
procedure GetNachweisDayData(const Path: string; const DOW: Word; out Date: TDateTime;
                             out Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5: string);
procedure SaveNachweisDayData(const Path: string; const DOW: Word;
                              const Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5: string);
procedure CreateNachweis(const Path: string; const TrainingStartDate: TDateTime; const Week,Year: Word; const Template: string);
function NachweisExist(const Path: string; const Week,Year: Word): Boolean;

function IsNachweisPending(const Path: string; const TrainingStartDate: TDateTime;
                           out CountNotPrinted,CountNotFinished,CountNotExistend: Integer): Boolean;

procedure CreateNachweisTemplate(const Path,Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string);
procedure GetNachweisTemplateData(const Path: string; out Name,SecondPersonTitle,SecondPersonName,
                                                          ThirdPersonTitle,ThirdPersonName: string);
procedure SaveNachweisTemplateData(const Path,Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string);
function FindNachweisTemplate(const aName: string): string;

procedure SaveNachweisAt(PathList: TStringList; const UserName,Destination: string;
                                 const FullPath: Boolean = False);
procedure PrintNachweis(PathList: TStringList; const UserName: string);

procedure SaveNachweisAtThreaded(PathList: TStringList; const UserName,Destination: string;
                                 const FullPath: Boolean = False; OnThredFinished: TOnThreadFinish = nil);
procedure PrintNachweisThreaded(PathList: TStringList; const UserName: string; OnThredFinished: TOnThreadFinish = nil);

type
  TWordThread = class(TThread)
  protected
    procedure Execute; override;
  private
    ChoosenFunction: string;
    PathList: TStringList;
    UserName: string;
    Destination: string;
    FullPath: Boolean;
    FOnThreadFinish: TOnThreadFinish;
    procedure SaveNachweisAt;
    procedure PrintNachweis;
    procedure SyncOnThreadFinish;
  public
    constructor Create(const AChoosenFunction: string; APathList: TStringList; const AUserName: string;
                       const ADestination: string = ''; const AFullPath: Boolean = False);
    property OnThreadFinish: TOnThreadFinish read FOnThreadFinish write FOnThreadFinish;
  end;

  TWordHandler = class(TObject)
  private
    MyWordApplication: TMyWordApplication;
    procedure EditDocument(const Path, UserName: string; Document: _Document);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveNachweisAt(const Path, UserName,Destination: string; const FullPath: Boolean = False);
    procedure PrintNachweis(const Path, UserName: string);
  end;

implementation

uses
  FileUtils, SysUtils, KaZip, Forms, Windows, Variants, Dialogs;


function GetDataFile: string;
begin
//  if ExtractFileName(Application.ExeName)='Ausbildungsnachweise.Service.exe' then begin
//    Result:=AppendPath(StringReplace(ExtractFilePath(Application.ExeName),'\Service','',[rfReplaceAll]),'Data.dat');
//    Exit;
//  end;
//  Result:=AppendPath(ExtractFilePath(Application.ExeName),'Data.dat');
  Result:=AppendPath(GetEnvironmentVariable('USERPROFILE'),'AppData\Local\Peripharos\Data.dat');
end;

function GetTeamplateFile: string;
begin
  if ExtractFileName(Application.ExeName)='Ausbildungsnachweise.Service.exe' then begin
    Result:=AppendPath(StringReplace(ExtractFilePath(Application.ExeName),'\Service','',[rfReplaceAll]),'Template.dat');
    Exit;
  end;
  Result:=AppendPath(ExtractFilePath(Application.ExeName),'Template.dat');
end;

function GetResourcesFile: string;
begin
  if ExtractFileName(Application.ExeName)='Ausbildungsnachweise.Service.exe' then begin
    Result:=AppendPath(StringReplace(ExtractFilePath(Application.ExeName),'\Service','',[rfReplaceAll]),'Resources.dat');
    Exit;
  end;
  Result:=AppendPath(ExtractFilePath(Application.ExeName),'Resources.dat');
end;

function GetDataPath: string;
begin
  Result:=AppendPath(GetEnvironmentVariable('TEMP'),'Peripharos\Asubildungsnachweise');
end;

function GetservicePath: string;
begin
  Result:=AppendPath(ExtractFilePath(Application.ExeName),'Service\Ausbildungsnachweise.Service.exe');
end;

function GetCryptingKey: TWordTriple;
begin
  Result[0]:=17360;
  Result[1]:=23478;
  Result[2]:=45434;
end;

procedure CopyDirectory(const SourceDir,DestDir: string; const Delete: Boolean = False);
var
  Files: TStringList;
  I: Integer;
begin
  Files:=TStringList.Create;
  try
    DirectoryScan(SourceDir,Files,DirScanParams([dsoNoSubFolders]));
    EnsureDirectory(DestDir);
    for I:=0 to Files.Count-1 do
      CopyFile(pchar(Files[I]),pchar(AppendPath(DestDir,ExtractFileName(Files[I]))),False);
  finally
    Files.Free;
  end;
  if Delete then begin
    ClearDirectory(SourceDir);
    RemoveDir(SourceDir);
  end;
end;

function StringIndex(const SwitchString: string; const CaseStrings: array of String; const GroﬂKlein: Boolean = True): Integer;
begin
  if GroﬂKlein then begin
    for Result:=0 to Pred(Length(CaseStrings)) do
      if ANSISameText(SwitchString,CaseStrings[Result]) then
        EXIT;
  end else begin
    for Result:=0 to Pred(Length(CaseStrings)) do
      if ANSISameStr(SwitchString,CaseStrings[Result]) then
        EXIT;
  end;
  Result:=-1;
end;

procedure CreateTxtFile(const FileName,Content: string);
var
  f: TextFile;
begin
  AssignFile(f, FileName);
  Rewrite(f);
  Write(f,Content);
  CloseFile(f);
end;

function GetTrainingYear(const StartDate: TDateTime; const Week,Year: Word): Word;
var
  AYear,AMonth,aDay: Word;
  I: Integer;
begin
  Result:=0;
  DecodeDate(StartDate,AYear,AMonth,aDay);
  for I:=0 to 4 do begin
    if (EncodeDateWeek(Year,Week,DayFriday) < EncodeDate(AYear+I,AMonth,aDay)) then begin
      Result:=I;
      Exit;
    end;
  end;
end;

procedure UnpackData(out DataPath: string);
var
  DataFile: string;
  DestinationPath: string;
  KaZip: TKaZip;
begin
  DataFile:=GetDataFile;
  DataPath:=GetDataPath;
  DestinationPath:=AppendPath(DataPath,ExtractFilePart(DataFile));
  if not DirectoryExists(DestinationPath) then
    EnsureDirectory(DestinationPath);
  if FileExists(DataFile) then begin
    FileDecrypt(DataFile,DataFile,GetCryptingKey);
    try
      KaZip:=TKAZip.Create(nil);
      try
        KaZip.Open(DataFile);
        KaZip.OverwriteAction:=oaOverwrite;
        KaZip.ExtractAll(DestinationPath);
      finally
        KaZip.Free;
      end;
    finally
      FileEncrypt(DataFile,DataFile,GetCryptingKey);
    end;
  end else begin
    if FileExists(GetTeamplateFile) then begin
      if FileExists(GetResourcesFile) then begin
        EnsureDirectory(AppendPath(DestinationPath,'Vorlagen'));
        FileDecrypt(GetTeamplateFile,GetTeamplateFile,GetCryptingKey);
        try
          KaZip:=TKAZip.Create(nil);
          try
            KaZip.Open(GetTeamplateFile);
            KaZip.OverwriteAction:=oaOverwrite;
            KaZip.ExtractAll(AppendPath(DestinationPath,'Vorlagen'));
          finally
            KaZip.Free;
          end;
        finally
          FileEncrypt(GetTeamplateFile,GetTeamplateFile,GetCryptingKey);
        end;
        EnsureDirectory(AppendPath(DestinationPath,'Vorlagen\Templates'));
        CreateNachweisTemplate(AppendPath(DestinationPath,'Vorlagen\Templates\1.txt'),'Standart','Ausbilder','Name:','Sonstige','Name:');
        EnsureDirectory(AppendPath(DestinationPath,'Resources'));
        FileDecrypt(GetResourcesFile,GetResourcesFile,GetCryptingKey);
        try
          KaZip:=TKAZip.Create(nil);
          try
            KaZip.Open(GetResourcesFile);
            KaZip.OverwriteAction:=oaOverwrite;
            KaZip.ExtractAll(AppendPath(DestinationPath,'Resources'));
          finally
            KaZip.Free;
          end;
        finally
          FileEncrypt(GetResourcesFile,GetResourcesFile,GetCryptingKey);
        end;
      end else begin
        Application.Terminate;
        raise Exception.Create('Beim ersten starten muss das Spinner Directory, welches als Resource dient in den selben Ordner wie das Programm liegen');
      end;
    end else begin
      Application.Terminate;
      raise Exception.Create('Beim ersten starten muss das Main.docx Dokument, welches als Vorlage dient in den selben Ordner wie das Programm liegen');
    end;
  end;
end;

procedure SaveDataToPacked(const DeleteUnpacked: Boolean);
var
  DataFile: string;
  DataPath: string;
  RootPath: string;
  KaZip: TKaZip;
  FS: TFileStream;
  Files: TStringList;
  I: Integer;
begin
  DataFile:=GetDataFile;
  DataPath:=GetDataPath;
  EnsureDirectory(ExtractFilePath(DataFile));
  RootPath:=AppendPath(DataPath,ExtractFilePart(DataFile));
  if FileExists(AppendPath(RootPath,'Vorlagen\Main.docx')) then begin
    KaZip:=TKAZip.Create(nil);
    try
      FS:=TFileStream.Create(DataFile, fmOpenReadWrite or FmCreate);
      try
        KaZip.CreateZip(FS);
      finally
        FS.Free;
      end;
      KaZip.Open(DataFile);
      Files:=TStringList.Create;
      try
        DirectoryScan(DataPath,Files,DirScanParams());
        for I:=0 to Files.Count-1 do begin
          if FileExists(Files[I]) then
            KaZip.AddFile(Files[I],Copy(Files[I],Length(RootPath)+2,MaxInt));
        end;
      finally
        Files.Free;
      end;
      KaZip.Close;
    finally
      KaZip.Free;
    end;
    FileEncrypt(DataFile,DataFile,GetCryptingKey);
  end;
  if DeleteUnpacked then begin
    ClearDirectory(DataPath);
    RemoveDir(DataPath);
  end;
end;

function GetNachweisName(const Path: string): string;
var
  Info: TStringList;
begin
  Info:=TStringList.Create;
  try
    Info.LoadFromFile(CombinePaths(Path,'Info.txt'));
    Result:=Info[0];
  finally
    Info.Free;
  end;
end;

function CreateNachweisName(const Week,Year: Word): string;
begin
  Result:='KW'+IntToStr(Week)+'_'+IntToStr(Year)+'.docx';
end;

function GetNachweisState(const Path: string): TState;
var
  Info: TStringList;
begin
  Info:=TStringList.Create;
  try
    Info.LoadFromFile(CombinePaths(Path,'Info.txt'));
    case StringIndex(Info[1],['InWork','Finished','Printed']) of
      0: Result:=stInWork;
      1: Result:=stFinished;
      2: Result:=stPrinted;
    end;
  finally
    Info.Free;
  end;
end;

function NextNachweisState(const Path: string): TState;
var
  Info: TStringList;
begin
  Info:=TStringList.Create;
  try
    Info.LoadFromFile(CombinePaths(Path,'Info.txt'));
    case StringIndex(Info[1],['InWork','Finished','Printed']) of
      0: begin
        Result:=stFinished;
        Info[1]:='Finished';
      end;
      1: begin
        Result:=stPrinted;
        Info[1]:='Printed';
      end;
    end;
    Info.SaveToFile(CombinePaths(Path,'Info.txt'));
  finally
    Info.Free;
  end;
end;

function GetNachweisTemplate(const Path: string): string;
var
  Info: TStringList;
begin
  Info:=TStringList.Create;
  try
    Info.LoadFromFile(CombinePaths(Path,'Info.txt'));
    Result:=Info[2];
  finally
    Info.Free;
  end;
end;

procedure GetNachweisDates(const Path: string; out Year,TrainingYear,Week: Word; out FromDate,ToDate: TDateTime);
var
  Dates: TStringList;
begin
  Dates:=TStringList.Create;
  try
    Dates.LoadFromFile(CombinePaths(Path,'Dates.txt'));
    Year:=StrToInt(Dates[0]);
    TrainingYear:=StrToInt(Dates[1]);
    Week:=StrToInt(Dates[2]);
    FromDate:=StrToDate(Dates[3]);
    ToDate:=StrToDate(Dates[4]);
  finally
    Dates.Free;
  end;
end;

procedure GetNachweisDayData(const Path: string; const DOW: Word; out Date: TDateTime;
                             out Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5: string);
var
  Data: TStringList;
  Split: TStringList;
begin
  Data:=TStringList.Create;
  try
    case Dow of
      DayMonday: Data.LoadFromFile(CombinePaths(Path,'Monday.txt'));
      DayTuesday: Data.LoadFromFile(CombinePaths(Path,'Tuesday.txt'));
      DayWednesday: Data.LoadFromFile(CombinePaths(Path,'Wednesday.txt'));
      DayThursday: Data.LoadFromFile(CombinePaths(Path,'Thursday.txt'));
      DayFriday: Data.LoadFromFile(CombinePaths(Path,'Friday.txt'));
    end;
    Date:=StrToDate(Data[0]);
    Split:=TStringList.Create;
    try
      Split.Delimiter:='|';
      Split.StrictDelimiter:=True;
      Split.DelimitedText:=Data[1];
      Ta1:=Split[0];
      St1:=Split[1];
      Split.DelimitedText:=Data[2];
      Ta2:=Split[0];
      St2:=Split[1];
      Split.DelimitedText:=Data[3];
      Ta3:=Split[0];
      St3:=Split[1];
      Split.DelimitedText:=Data[4];
      Ta4:=Split[0];
      St4:=Split[1];
      Split.DelimitedText:=Data[5];
      Ta5:=Split[0];
      St5:=Split[1];
    finally
      Split.Free;
    end;
  finally
    Data.Free;
  end;
end;

procedure SaveNachweisDayData(const Path: string; const DOW: Word;
                              const Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5: string);
var
  Data: TStringList;
begin
  Data:=TStringList.Create;
  try
    case Dow of
      DayMonday: Data.LoadFromFile(CombinePaths(Path,'Monday.txt'));
      DayTuesday: Data.LoadFromFile(CombinePaths(Path,'Tuesday.txt'));
      DayWednesday: Data.LoadFromFile(CombinePaths(Path,'Wednesday.txt'));
      DayThursday: Data.LoadFromFile(CombinePaths(Path,'Thursday.txt'));
      DayFriday: Data.LoadFromFile(CombinePaths(Path,'Friday.txt'));
    end;
    Data[1]:=Ta1+'|'+St1;
    Data[2]:=Ta2+'|'+St2;
    Data[3]:=Ta3+'|'+St3;
    Data[4]:=Ta4+'|'+St4;
    Data[5]:=Ta5+'|'+St5;
    case Dow of
      DayMonday: Data.SaveToFile(CombinePaths(Path,'Monday.txt'));
      DayTuesday: Data.SaveToFile(CombinePaths(Path,'Tuesday.txt'));
      DayWednesday: Data.SaveToFile(CombinePaths(Path,'Wednesday.txt'));
      DayThursday: Data.SaveToFile(CombinePaths(Path,'Thursday.txt'));
      DayFriday: Data.SaveToFile(CombinePaths(Path,'Friday.txt'));
    end;
  finally
    Data.Free;
  end;
end;

procedure CreateNachweis(const Path: string; const TrainingStartDate: TDateTime; const Week,Year: Word; const Template: string);
var
  NachweisDir: string;
begin
  NachweisDir:=AppendPath(Path,IntToStr(Year)+'_'+IntToStr(Week));
  EnsureDirectory(NachweisDir);
  CreateTxtFile(AppendPath(NachweisDir,'Info.txt'),                              // Allgemeine Infos
                CreateNachweisName(Week,Year)+sLineBreak+                          // Name
                'InWork'+sLineBreak+                                               // Status
                Template);                                                         // Template

  CreateTxtFile(AppendPath(NachweisDir,'Dates.txt'),                             // Datumsangaben
                IntToStr(Year)+sLineBreak+                                         // Jahr
                IntToStr(GetTrainingYear(TrainingStartDate,Week,Year))+sLineBreak+ // Ausbildungsjahr
                IntToStr(Week)+sLineBreak+                                         // KW
                DateToStr(EncodeDateWeek(Year,Week,DayMonday))+sLineBreak+         // Von (Montag)
                DateToStr(EncodeDateWeek(Year,Week,DayFriday)));                   // Bis (Freitag)

  CreateTxtFile(AppendPath(NachweisDir,'Monday.txt'),                            // Tag Daten Montag
                DateToStr(EncodeDateWeek(Year,Week,DayMonday))+sLineBreak+         // Datum
                '|'+sLineBreak+                                                    // Datenfeld 1
                '|'+sLineBreak+                                                    // Datenfeld 2
                '|'+sLineBreak+                                                    // Datenfeld 3
                '|'+sLineBreak+                                                    // Datenfeld 4
                '|');                                                              // Datenfeld 5

  CreateTxtFile(AppendPath(NachweisDir,'Tuesday.txt'),                            // Tag Daten Montag
                DateToStr(EncodeDateWeek(Year,Week,DayTuesday))+sLineBreak+        // Datum
                '|'+sLineBreak+                                                    // Datenfeld 1
                '|'+sLineBreak+                                                    // Datenfeld 2
                '|'+sLineBreak+                                                    // Datenfeld 3
                '|'+sLineBreak+                                                    // Datenfeld 4
                '|');                                                              // Datenfeld 5

  CreateTxtFile(AppendPath(NachweisDir,'Wednesday.txt'),                         // Tag Daten Montag
                DateToStr(EncodeDateWeek(Year,Week,DayWednesday))+sLineBreak+      // Datum
                '|'+sLineBreak+                                                    // Datenfeld 1
                '|'+sLineBreak+                                                    // Datenfeld 2
                '|'+sLineBreak+                                                    // Datenfeld 3
                '|'+sLineBreak+                                                    // Datenfeld 4
                '|');                                                              // Datenfeld 5

  CreateTxtFile(AppendPath(NachweisDir,'Thursday.txt'),                          // Tag Daten Montag
                DateToStr(EncodeDateWeek(Year,Week,DayThursday))+sLineBreak+       // Datum
                '|'+sLineBreak+                                                    // Datenfeld 1
                '|'+sLineBreak+                                                    // Datenfeld 2
                '|'+sLineBreak+                                                    // Datenfeld 3
                '|'+sLineBreak+                                                    // Datenfeld 4
                '|');                                                              // Datenfeld 5

  CreateTxtFile(AppendPath(NachweisDir,'Friday.txt'),                            // Tag Daten Montag
                DateToStr(EncodeDateWeek(Year,Week,DayFriday))+sLineBreak+         // Datum
                '|'+sLineBreak+                                                    // Datenfeld 1
                '|'+sLineBreak+                                                    // Datenfeld 2
                '|'+sLineBreak+                                                    // Datenfeld 3
                '|'+sLineBreak+                                                    // Datenfeld 4
                '|');                                                              // Datenfeld 5

end;

function NachweisExist(const Path: string; const Week,Year: Word): Boolean;
begin
  Result:=DirectoryExists(AppendPath(Path,IntToStr(Year)+'_'+IntToStr(Week)));
end;

function IsNachweisPending(const Path: string; const TrainingStartDate: TDateTime;
                           out CountNotPrinted,CountNotFinished,CountNotExistend: Integer): Boolean;
var
  Week,Year: Word;
  State: TState;
  I: Word;
begin
  CountNotPrinted:=0;
  CountNotFinished:=0;
  CountNotExistend:=0;
  Result:=False;
  Week:=WeekOfTheYear(Today);
  Year:=YearOf(Today);
  for I:=Trunc(NthWeekdayFromDate(TrainingStartDate,DayMonday,-1)) to Trunc(Today) do begin
    if DayOfTheWeek(I)=DayMonday then begin
      Week:=WeekOfTheYear(I);
      Year:=YearOf(I);
      if not NachweisExist(Path,Week,Year) then begin
        Result:=True;
        Inc(CountNotExistend);
      end else begin
        State:=GetNachweisState(AppendPath(Path,IntToStr(Year)+'_'+IntToStr(Week)));
        if State=stInWork then begin
          Result:=True;
          Inc(CountNotFinished);
        end;
        if State=stFinished then begin
          Result:=True;
          Inc(CountNotPrinted);
        end;
      end;
    end;
  end;
end;

procedure CreateNachweisTemplate(const Path,Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string);
begin
  CreateTxtFile(Path,
               Name+sLineBreak+
               SecondPersonTitle+sLineBreak+
               SecondPersonName+sLineBreak+
               ThirdPersonTitle+sLineBreak+
               ThirdPersonName);
end;

procedure GetNachweisTemplateData(const Path: string; out Name,SecondPersonTitle,SecondPersonName,
                                                          ThirdPersonTitle,ThirdPersonName: string);
var
  TemplateData: TStringList;
begin
  TemplateData:=TStringList.Create;
  try
    TemplateData.LoadFromFile(Path);
    Name:=TemplateData[0];
    SecondPersonTitle:=TemplateData[1];
    SecondPersonName:=TemplateData[2];
    ThirdPersonTitle:=TemplateData[3];
    ThirdPersonName:=TemplateData[4];
  finally
    TemplateData.Free;
  end;
end;

procedure SaveNachweisTemplateData(const Path,Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string);
var
  TemplateData: TStringList;
begin
  TemplateData:=TStringList.Create;
  try
    TemplateData.Add(Name);
    TemplateData.Add(SecondPersonTitle);
    TemplateData.Add(SecondPersonName);
    TemplateData.Add(ThirdPersonTitle);
    TemplateData.Add(ThirdPersonName);
    TemplateData.SaveToFile(Path);
  finally
    TemplateData.Free;
  end;
end;

function FindNachweisTemplate(const aName: string): string;
var
  Templates: TStringList;
  DestinationPath: string;
  Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string;
  I: Integer;
begin
  DestinationPath:=AppendPath(GetDataPath,ExtractFilePart(GetDataFile));
  Templates:=TStringList.Create;
  try
    EnsureDirectory(AppendPath(DestinationPath,'Vorlagen\Templates'));
    DirectoryScan(AppendPath(DestinationPath,'Vorlagen\Templates'),Templates,DirScanParams([dsoNoSubFolders,dsoVerifyFolders]));
    for I:=0 to Templates.Count-1 do begin
     GetNachweisTemplateData(Templates[I],Name,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName);
     if Name = aName then begin
       Result:=Templates[I];
       Exit;
     end;
    end;
  finally
    Templates.Free;
  end;
end;

procedure SaveNachweisAt(PathList: TStringList; const UserName,Destination: string; const FullPath: Boolean);
var
  WordHandler: TWordHandler;
  I: Integer;
begin
  WordHandler:=TWordHandler.Create;
  try
    for I:=0 to Pathlist.Count-1 do begin
      WordHandler.SaveNachweisAt(Pathlist[I],UserName,Destination,FullPath);
    end;
  finally
    WordHandler.Free;
  end;
end;

procedure PrintNachweis(PathList: TStringList; const UserName: string);
var
  WordHandler: TWordHandler;
  I: Integer;
begin
  WordHandler:=TWordHandler.Create;
  try
    for I:=0 to Pathlist.Count-1 do begin
      WordHandler.PrintNachweis(Pathlist[I],UserName);
    end;
  finally
    WordHandler.Free;
  end;
end;

procedure SaveNachweisAtThreaded(PathList: TStringList; const UserName,Destination: string; const FullPath: Boolean; OnThredFinished: TOnThreadFinish);
var
  WordThread: TWordThread;
begin
  WordThread:=TWordThread.Create('SaveNachweisAt',PathList,UserName,Destination,FullPath);
  WordThread.OnThreadFinish:=OnThredFinished;
  WordThread.FreeOnTerminate:=True;
  WordThread.Resume;
end;

procedure PrintNachweisThreaded(PathList: TStringList; const UserName: string; OnThredFinished: TOnThreadFinish);
var
  WordThread: TWordThread;
begin
  WordThread:=TWordThread.Create('PrintNachweis',PathList,UserName);
  WordThread.OnThreadFinish:=OnThredFinished;
  WordThread.FreeOnTerminate:=True;
  WordThread.Resume;
end;

{ TWordThread }

constructor TWordThread.Create(const AChoosenFunction: string; APathList: TStringList; const AUserName,
  ADestination: string; const AFullPath: Boolean);
begin
  Inherited Create(true);
  ChoosenFunction:=AChoosenFunction;
  PathList:=TStringList.Create;
  PathList.AddStrings(APathList);
  UserName:=AUserName;
  Destination:=ADestination;
  FullPath:=AFullPath;
end;

procedure TWordThread.Execute;
begin
  inherited;
  if ChoosenFunction='SaveNachweisAt' then
    SaveNachweisAt;
  if ChoosenFunction='PrintNachweis' then
    PrintNachweis;
  Synchronize(SyncOnThreadFinish);  
end;

procedure TWordThread.PrintNachweis;
var
  WordHandler: TWordHandler;
  I: Integer;
begin
  WordHandler:=TWordHandler.Create;
  try
    for I:=0 to Pathlist.Count-1 do begin
      WordHandler.PrintNachweis(Pathlist[I],UserName);
    end;
  finally
    WordHandler.Free;
  end;
end;

procedure TWordThread.SaveNachweisAt;
var
  WordHandler: TWordHandler;
  I: Integer;
begin
  WordHandler:=TWordHandler.Create; 
  try
    for I:=0 to Pathlist.Count-1 do begin
      WordHandler.SaveNachweisAt(Pathlist[I],UserName,Destination,FullPath);
    end;
  finally
    WordHandler.Free;
  end;
end;

procedure TWordThread.SyncOnThreadFinish;
begin
  if Assigned(FOnThreadFinish) then
    FOnThreadFinish;;
end;

{ TWordHandler }

constructor TWordHandler.Create;
var
  RootPath,DataFile,DataPath,WordPath: string;
  Document: _Document;
begin
  MyWordApplication:=TMyWordApplication.Create(nil);
  DataFile:=GetDataFile;
  DataPath:=GetDataPath;
  RootPath:=AppendPath(AppendPath(DataPath,ExtractFilePart(DataFile)),'Vorlagen');
  MyWordApplication.OpenDocument(AppendPath(RootPath,'Main.docx'));
end;

destructor TWordHandler.Destroy;
begin
  MyWordApplication.Free;
  inherited;
end;

procedure TWordHandler.EditDocument(const Path, UserName: string; Document: _Document);
var
  Number: OleVariant;
  Year,TrainingYear,Week: Word;
  FromDate,ToDate,DayDate: TDateTime;
  Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5: string;
  SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName: string;
  Dummy: string;
begin
  GetNachweisDates(Path,Year,TrainingYear,Week,FromDate,ToDate);
  Number:=1;
  Document.Shapes.Item(Number).TextFrame.TextRange.Text:=IntToStr(Year);
  Number:=2;
  Document.Shapes.Item(Number).TextFrame.TextRange.Text:=IntToStr(TrainingYear)+'.';
  Number:=3;
  Document.Shapes.Item(Number).TextFrame.TextRange.Text:=IntToStr(Week);
  Number:=4;
  Document.Shapes.Item(Number).TextFrame.TextRange.Text:=DateToStr(FromDate);
  Number:=5;
  Document.Shapes.Item(Number).TextFrame.TextRange.Text:=DateToStr(ToDate);
  GetNachweisDayData(Path,DayMonday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  Document.Paragraphs.Item(8).Range.Text:=DateToStr(DayDate);
  Document.Paragraphs.Item(10).Range.Text:=Ta1;
  Document.Paragraphs.Item(16).Range.Text:=Ta2;
  Document.Paragraphs.Item(22).Range.Text:=Ta3;
  Document.Paragraphs.Item(28).Range.Text:=Ta4;
  Document.Paragraphs.Item(34).Range.Text:=Ta5;
  Document.Paragraphs.Item(11).Range.Text:=St1;
  Document.Paragraphs.Item(17).Range.Text:=St2;
  Document.Paragraphs.Item(23).Range.Text:=St3;
  Document.Paragraphs.Item(29).Range.Text:=St4;
  Document.Paragraphs.Item(35).Range.Text:=St5;
  GetNachweisDayData(Path,DayTuesday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  Document.Paragraphs.Item(38).Range.Text:=DateToStr(DayDate);
  Document.Paragraphs.Item(40).Range.Text:=Ta1;
  Document.Paragraphs.Item(46).Range.Text:=Ta2;
  Document.Paragraphs.Item(52).Range.Text:=Ta3;
  Document.Paragraphs.Item(58).Range.Text:=Ta4;
  Document.Paragraphs.Item(64).Range.Text:=Ta5;
  Document.Paragraphs.Item(41).Range.Text:=St1;
  Document.Paragraphs.Item(47).Range.Text:=St2;
  Document.Paragraphs.Item(53).Range.Text:=St3;
  Document.Paragraphs.Item(59).Range.Text:=St4;
  Document.Paragraphs.Item(65).Range.Text:=St5;  GetNachweisDayData(Path,DayWednesday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  Document.Paragraphs.Item(68).Range.Text:=DateToStr(DayDate);
  Document.Paragraphs.Item(70).Range.Text:=Ta1;
  Document.Paragraphs.Item(76).Range.Text:=Ta2;
  Document.Paragraphs.Item(82).Range.Text:=Ta3;
  Document.Paragraphs.Item(88).Range.Text:=Ta4;
  Document.Paragraphs.Item(94).Range.Text:=Ta5;
  Document.Paragraphs.Item(71).Range.Text:=St1;
  Document.Paragraphs.Item(77).Range.Text:=St2;
  Document.Paragraphs.Item(83).Range.Text:=St3;
  Document.Paragraphs.Item(89).Range.Text:=St4;
  Document.Paragraphs.Item(95).Range.Text:=St5;  GetNachweisDayData(Path,DayThursday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  Document.Paragraphs.Item(98).Range.Text:=DateToStr(DayDate);
  Document.Paragraphs.Item(100).Range.Text:=Ta1;
  Document.Paragraphs.Item(106).Range.Text:=Ta2;
  Document.Paragraphs.Item(112).Range.Text:=Ta3;
  Document.Paragraphs.Item(118).Range.Text:=Ta4;
  Document.Paragraphs.Item(124).Range.Text:=Ta5;
  Document.Paragraphs.Item(101).Range.Text:=St1;
  Document.Paragraphs.Item(107).Range.Text:=St2;
  Document.Paragraphs.Item(113).Range.Text:=St3;
  Document.Paragraphs.Item(119).Range.Text:=St4;
  Document.Paragraphs.Item(125).Range.Text:=St5;  GetNachweisDayData(Path,DayFriday,DayDate,Ta1,Ta2,Ta3,Ta4,Ta5,St1,St2,St3,St4,St5);
  Document.Paragraphs.Item(128).Range.Text:=DateToStr(DayDate);
  Document.Paragraphs.Item(130).Range.Text:=Ta1;
  Document.Paragraphs.Item(136).Range.Text:=Ta2;
  Document.Paragraphs.Item(142).Range.Text:=Ta3;
  Document.Paragraphs.Item(148).Range.Text:=Ta4;
  Document.Paragraphs.Item(154).Range.Text:=Ta5;
  Document.Paragraphs.Item(131).Range.Text:=St1;
  Document.Paragraphs.Item(137).Range.Text:=St2;
  Document.Paragraphs.Item(143).Range.Text:=St3;
  Document.Paragraphs.Item(149).Range.Text:=St4;
  Document.Paragraphs.Item(155).Range.Text:=St5;
  Document.Paragraphs.Item(131).Range.Text:=St1;
  Document.Paragraphs.Item(137).Range.Text:=St2;
  Document.Paragraphs.Item(143).Range.Text:=St3;
  Document.Paragraphs.Item(149).Range.Text:=St4;
  Document.Paragraphs.Item(155).Range.Text:=St5;
  GetNachweisTemplateData(FindNachweisTemplate((GetNachweisTemplate(Path))),Dummy,SecondPersonTitle,SecondPersonName,ThirdPersonTitle,ThirdPersonName);
  Document.Paragraphs.Item(163).Range.Text:='Auszubildender'+sLineBreak;
  Document.Paragraphs.Item(167).Range.Text:=UserName;
  Document.Paragraphs.Item(168).Range.Text:=SecondPersonTitle+sLineBreak;
  Document.Paragraphs.Item(172).Range.Text:=SecondPersonName;
  Document.Paragraphs.Item(173).Range.Text:=ThirdPersonTitle+sLineBreak;
  Document.Paragraphs.Item(177).Range.Text:=ThirdPersonName;
end;

procedure TWordHandler.SaveNachweisAt(const Path, UserName, Destination: string; const FullPath: Boolean);
var
  RootPath,DataFile,DataPath,WordPath: string;
  Document: _Document;
  FileName: OleVariant;
begin
  DataFile:=GetDataFile;
  DataPath:=GetDataPath;
  RootPath:=AppendPath(AppendPath(DataPath,ExtractFilePart(DataFile)),'Vorlagen');
  MyWordApplication.OpenDocument(AppendPath(RootPath,'Main.docx'));
  MyWordApplication.ShowMe;
  Document:=MyWordApplication.ActiveDocument;
  EditDocument(Path,UserName,Document);
  if FullPath then
    FileName:=Destination
  else
    FileName:=AppendPath(Destination,GetNachweisName(Path));
  Document.SaveAs(FileName,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
                  EmptyParam,EmptyParam,EmptyParam);
end;

procedure TWordHandler.PrintNachweis(const Path, UserName: string);
var
  RootPath,DataFile,DataPath,WordPath: string;
  Document: _Document;
  FileName: OleVariant;
begin
  DataFile:=GetDataFile;
  DataPath:=GetDataPath;
  RootPath:=AppendPath(AppendPath(DataPath,ExtractFilePart(DataFile)),'Vorlagen');
  SaveNachweisAt(Path,UserName,AppendPath(RootPath,'Print.docx'),True);
  MyWordApplication.PrintActiveDocument;
end;

end.
