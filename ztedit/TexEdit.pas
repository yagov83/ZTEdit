unit TexEdit;

{$MODE Delphi}

interface

uses
LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs, StdCtrls, ExtCtrls, ImgList, ComCtrls, Math;

type

{ TTexEditForm }

TTexEditForm = class(TForm)
  BtnRemoveEmpty: TButton;
  BtnShowTex: TButton;
  ComboBoxPreviewScale: TComboBox;
  ImagePreview: TImage;
  PanelLists:  TPanel;
  PanelTools:  TPanel;
  SplitterHor: TSplitter;
  Panel1:      TPanel;
  Panel2:      TPanel;
  Panel3:      TPanel;
  Panel4:      TPanel;
  Panel5:      TPanel;
  Panel6:      TPanel;
  Panel7:      TPanel;
  Panel8:      TPanel;
  Panel9:      TPanel;
  Panel10:     TPanel;
  Panel11:     TPanel;
  Panel12:     TPanel;
  Panel13:     TPanel;
  Panel14:     TPanel;
  Panel15:     TPanel;
  Panel16:     TPanel;
  Label1:      TLabel;
  GridChk:     TCheckBox;
  ImageListTiles:  TImageList;
  ListViewTiles:   TListView;
  ListViewTextures:   TListView;
  ImageListTextures:  TImageList;
  procedure BtnRemoveEmptyClick(Sender: TObject);
  procedure BtnShowTexClick(Sender: TObject);
  procedure ListViewTexturesResize(Sender: TObject);
  procedure ListViewTilesChange (Sender: TObject; Item: TListItem; Change: TItemChange);
  procedure FormCreate (Sender: TObject);
  procedure FormShow (Sender: TObject);
private
  { Private declarations }
public
  { Public declarations }
end;

var
TexEditForm: TTexEditForm;


implementation

uses main;

{$R *.lfm}

var
{  CurPal: Array [0..15] of TColor = (
{  $00000000, $004A2400, $00946D4A, $00DEBA94,
  $00FFDFDE, $00002421, $0000494A, $00FF6D21,
  $0000004A, $0000246B, $004A92FF, $00214994,
  $00BDFFFF, $000024DE, $0021924A, $00000000);}
  CurPal: Array [0..15] of TColor = (
  $00E000E0, $00402000, $00806040, $00c0a080,
  $00e0c0c0, $00002020, $00004040, $00e06020,
  $00000040, $00002060, $004080e0, $00204080,
  $00a0e0e0, $000020c0, $00208040, $00000000);


function GetClr1(B: Byte): Byte;
begin
Result:=B shr 4;
end;

function GetClr2(B: Byte): Byte;
begin
B:=B shl 4;
Result:=B shr 4;
end;

procedure TTexEditForm.FormCreate(Sender: TObject);
begin

end;


procedure TTexEditForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to High(CurPal) do
    begin
    CurPal[i]:=MainForm.CurPal[i];
    end;

  Panel1.Color:=CurPal[0];
  Panel2.Color:=CurPal[1];
  Panel3.Color:=CurPal[2];
  Panel4.Color:=CurPal[3];
  Panel5.Color:=CurPal[4];
  Panel6.Color:=CurPal[5];
  Panel7.Color:=CurPal[6];
  Panel8.Color:=CurPal[7];
  Panel9.Color:=CurPal[8];
  Panel10.Color:=CurPal[9];
  Panel11.Color:=CurPal[10];
  Panel12.Color:=CurPal[11];
  Panel13.Color:=CurPal[12];
  Panel14.Color:=CurPal[13];
  Panel15.Color:=CurPal[14];
  Panel16.Color:=CurPal[15];

  BtnShowTexClick(self);

end;


procedure TTexEditForm.ListViewTilesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  tempBitmap: TBitmap;
begin
  tempBitmap:=TBitmap.Create;
  ImageListTiles.GetBitmap(Item.ImageIndex,tempBitmap);
  ImagePreview.Canvas.Clear;
  ImagePreview.Canvas.StretchDraw(Bounds(0,0,
                                         32*round(power(2,ComboBoxPreviewScale.ItemIndex)),
                                         32*round(power(2,ComboBoxPreviewScale.ItemIndex))),tempBitmap);
  tempBitmap.Free;
end;

procedure TTexEditForm.BtnShowTexClick(Sender: TObject);
var
  i,k: integer;
  tb: TBitmap;
begin
  tb:=TBitmap.Create;

  ListViewTiles.BeginUpdate;
  ImageListTiles.Clear;
  ListViewTiles.Items.Clear;
  for i:=0 to MainForm.TileList.Count-1 do
    begin
    MainForm.TileList.GetBitmap(i,tb);
    ImageListTiles.Add(tb,nil);
    ListViewTiles.AddItem(i.ToString,MainForm);
    ListViewTiles.Items.Item[i].ImageIndex:=i;
    end;
  ListViewTiles.EndUpdate;

  ImageListTextures.BeginUpdate;
  ImageListTextures.Clear;
  ListViewTextures.Items.Clear;
  k:=0;
  for i:=0 to MainForm.TexList1.Count-1 do
    begin
    MainForm.TexList1.GetBitmap(i,tb);
    ImageListTextures.Add(tb,nil);
    ListViewTextures.AddItem('E1Tex'+i.ToString,MainForm);
    ListViewTextures.Items.Item[k].ImageIndex:=k;
    k+=1;
    end;
  for i:=0 to MainForm.TexList2.Count-1 do
    begin
    MainForm.TexList2.GetBitmap(i,tb);
    ImageListTextures.Add(tb,nil);
    ListViewTextures.AddItem('E2Tex'+i.ToString,MainForm);
    ListViewTextures.Items.Item[k].ImageIndex:=k;
    k+=1;
    end;
  for i:=0 to MainForm.TexList3.Count-1 do
    begin
    MainForm.TexList3.GetBitmap(i,tb);
    ImageListTextures.Add(tb,nil);
    ListViewTextures.AddItem('E3Tex'+i.ToString,MainForm);
    ListViewTextures.Items.Item[k].ImageIndex:=k;
    k+=1;
    end;
  ImageListTextures.EndUpdate;

  tb.Free;
end;

procedure TTexEditForm.ListViewTexturesResize(Sender: TObject);
begin

end;

procedure TTexEditForm.BtnRemoveEmptyClick(Sender: TObject);
begin

end;


end.
