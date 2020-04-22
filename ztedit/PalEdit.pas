unit PalEdit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ComCtrls, StdCtrls, ExtCtrls;

type
  TPalEditForm = class(TForm)
    PalGrid: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    RedTrackBar: TTrackBar;
    RedLabel: TLabel;
    GreenLabel: TLabel;
    GreenTrackBar: TTrackBar;
    BlueTrackBar: TTrackBar;
    BlueLabel: TLabel;
    RedValLabel: TLabel;
    GreenValLabel: TLabel;
    BlueValLabel: TLabel;
    ClrPreview: TShape;
    SaveClrBtn: TButton;
    SavePalBtn: TButton;
    CancelBtn: TButton;
    procedure PalGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure RedTrackBarChange(Sender: TObject);
    procedure GreenTrackBarChange(Sender: TObject);
    procedure BlueTrackBarChange(Sender: TObject);
    procedure PalGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SaveClrBtnClick(Sender: TObject);
    procedure SavePalBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PalEditForm: TPalEditForm;
  PalSaved: Boolean;
  CurrentColorIndex: Byte;
  BackupPal: Array [0..15] of TColor;

implementation

uses main;

{$R *.lfm}

function ValuesToColor(R, G, B: Byte): TColor;
var
  Clr: String;
begin
  Clr:='$00'+IntToHex(B,2)+IntToHex(G,2)+IntToHex(R,2);
  Result:=StrToInt(Clr)
end;

procedure TPalEditForm.BlueTrackBarChange(Sender: TObject);
begin
  BlueTrackBar.Position:=(BlueTrackBar.Position div 32)*32;
  BlueValLabel.Caption:=IntToStr(BlueTrackBar.Position);
  ClrPreview.Brush.Color:=ValuesToColor(RedTrackBar.Position,
                                        GreenTrackBar.Position,
                                        BlueTrackBar.Position);
end;

procedure TPalEditForm.CancelBtnClick(Sender: TObject);
begin
  Close
end;

procedure TPalEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Byte;
begin
  if not PalSaved then
    for I := 0 to 15 do
      MainForm.CurPal[I]:=BackupPal[I]
end;

procedure TPalEditForm.FormShow(Sender: TObject);
var
  I: Byte;
begin
  for I := 0 to 15 do
    BackupPal[I]:=MainForm.CurPal[I];
  PalSaved:=False
end;

procedure TPalEditForm.GreenTrackBarChange(Sender: TObject);
begin
  GreenTrackBar.Position:=(GreenTrackBar.Position div 32)*32;
  GreenValLabel.Caption:=IntToStr(GreenTrackBar.Position);
  ClrPreview.Brush.Color:=ValuesToColor(RedTrackBar.Position,
                                        GreenTrackBar.Position,
                                        BlueTrackBar.Position);
end;

procedure TPalEditForm.PalGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  PalGrid.Canvas.Brush.Color:=MainForm.CurPal[ACol];
  PalGrid.Canvas.Brush.Style:=bsSolid;
  PalGrid.Canvas.FillRect(Rect);
end;

procedure TPalEditForm.PalGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  S: String;
begin
  CurrentColorIndex:=ACol;
  S:=IntToHex(MainForm.CurPal[ACol],8);
  BlueTrackBar.Position:=StrToInt('$'+S[3]+S[4]);
  GreenTrackBar.Position:=StrToInt('$'+S[5]+S[6]);
  RedTrackBar.Position:=StrToInt('$'+S[7]+S[8]);
end;

procedure TPalEditForm.RedTrackBarChange(Sender: TObject);
begin
  RedTrackBar.Position:=(RedTrackBar.Position div 32)*32;
  RedValLabel.Caption:=IntToStr(RedTrackBar.Position);
  ClrPreview.Brush.Color:=ValuesToColor(RedTrackBar.Position,
                                        GreenTrackBar.Position,
                                        BlueTrackBar.Position);
end;

procedure TPalEditForm.SaveClrBtnClick(Sender: TObject);
begin
  MainForm.CurPal[CurrentColorIndex]:=ClrPreview.Brush.Color;
  PalGrid.Refresh
end;

procedure TPalEditForm.SavePalBtnClick(Sender: TObject);
begin
  PalSaved:=True;
  MainForm.DataChanged:=True;
  Close
end;

end.
