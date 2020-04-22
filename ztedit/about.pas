unit about;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    LabelAbout: TLabel;
    OKButton: TButton;
    ProgramImage: TImage;
    AboutText1: TStaticText;
    AboutText3: TStaticText;
    AboutText4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure AboutText4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

const
  Vers: string = 'v0.41L (2020-04-21)';

implementation

{$R *.lfm}

procedure TAboutForm.AboutText4Click(Sender: TObject);
begin
   OpenDocument(PChar('mailto:'+AboutText4.Caption)) ;
end;

procedure TAboutForm.OKButtonClick(Sender: TObject);
begin
  Close
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
LabelAbout.Caption:=LabelAbout.Caption+' '+Vers;
end;


end.
