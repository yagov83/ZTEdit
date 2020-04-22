program ztedit;

{$MODE Delphi}

uses
  Forms, Interfaces,
  main in 'main.pas' {MainForm},
  TexEdit in 'TexEdit.pas' {TexEditForm},
  PalEdit in 'PalEdit.pas' {PalEditForm},
  about in 'about.pas' {AboutForm};

{$R *.res}

begin
  Application.Initialize;
//  Application.MainFormOnTaskbar := True;
  Application.Title := 'ZTEdit';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TPalEditForm, PalEditForm);
  Application.CreateForm(TTexEditForm, TexEditForm);
  Application.Run;
end.
