unit main;

{$MODE Delphi}

interface

uses
LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs, Menus, ExtCtrls, Grids, StdCtrls, ComCtrls, IniFiles, ImgList,
ActnList, Buttons, Types;

type
TZMap = record
  Signature: array [0..3] of AnsiChar;
  TexDefs:   array [0..255] of array [0..7] of word;
  TexOrders: array [0..255] of array [0..3] of word;
  CellDefs:  array [0..255] of byte;
  Levels:    array [0..15] of array [0..31] of array[0..31] of byte;
  LevelEnv:  array [0..15] of byte;
  AnimData:  array [0..2565] of byte;
end;

{ TMainForm }

TMainForm = class(TForm)
  BtnMapZoomIn: TBitBtn;
  BtnMapZoomOut: TBitBtn;
  CellLabel: TLabel;
  Map:     TStringGrid;
  LevelStatBar: TStatusBar;
  ClearButton: TButton;
  EastTexture: TImage;
  FillButton: TButton;
  FillEdit: TEdit;
  GroupBoxLegend: TGroupBox;
  ImageLegendDoorHor: TImage;
  ImageLegendDoorVer: TImage;
  ImageLegendEmpty: TImage;
  ImageLegendEnemy: TImage;
  ImageLegendItem: TImage;
  ImageLegendLLCorner: TImage;
  ImageLegendLRCorner: TImage;
  ImageLegendShootableWall: TImage;
  ImageLegendSpecialCell: TImage;
  ImageLegendSpecialWall: TImage;
  ImageLegendStart: TImage;
  ImageLegendULCorner: TImage;
  ImageLegendUnknown: TImage;
  ImageLegendURCorner: TImage;
  ImageLegendWall: TImage;
  ImageLegendWeapon: TImage;
  Label1:  TLabel;
  Label10: TLabel;
  Label11: TLabel;
  Label12: TLabel;
  Label13: TLabel;
  Label14: TLabel;
  Label15: TLabel;
  Label16: TLabel;
  Label17: TLabel;
  Label18: TLabel;
  Label19: TLabel;
  Label2:  TLabel;
  Label20: TLabel;
  Label3:  TLabel;
  Label4:  TLabel;
  Label5:  TLabel;
  Label6:  TLabel;
  Label7:  TLabel;
  Label8:  TLabel;
  Label9:  TLabel;
  LevelSelect: TComboBox;
  NorthTexture: TImage;
  OpenDialog: TOpenDialog;
  PanelEditMap: TGroupBox;
  PanelRight: TPanel;
  PanelSelectLevel: TGroupBox;
  PanelTexView: TGroupBox;
  ReplaceButton: TButton;
  ReplaceEdit1: TEdit;
  ReplaceEdit2: TEdit;
  SaveDialog: TSaveDialog;
  ImageListCells: TImageList;
  MapPopup: TPopupMenu;
  ScrollBoxMap: TScrollBox;
  SouthTexture: TImage;
  TileList: TImageList;
  TexList1: TImageList;
  TexList2: TImageList;
  TexList3: TImageList;
  StartupTimer: TTimer;
  WestTexture: TImage;
  MainMenu: TMainMenu;
  File1:   TMenuItem;
  MenuOpenRom: TMenuItem;
  MenuSaveROM: TMenuItem;
  MenuSaveROMAs: TMenuItem;
  N1:      TMenuItem;
  MenuExit:   TMenuItem;
  MenuTools:  TMenuItem;
  MenuPalEditor: TMenuItem;
  MenuTexEditor: TMenuItem;
  MenuHelp:   TMenuItem;
  MenuAbout:  TMenuItem;
  WithLabel: TLabel;
  procedure BtnMapZoomInClick(Sender: TObject);
  procedure BtnMapZoomOutClick(Sender: TObject);
  procedure FreePopup;
  procedure ReadIni;
  procedure MenuDefClick (Sender: TObject);
  procedure MenuExitClick (Sender: TObject);
  procedure MenuOpenROMClick (Sender: TObject);
  procedure FormCreate (Sender: TObject);
  procedure FormDestroy (Sender: TObject);
  function LoadROM: boolean;
  procedure SaveROM;
  function ConfirmROMSave: integer;
  function LevelChanged: boolean;
  procedure LoadLevel (EpisodeNum, LevelNum: byte);
  procedure SaveLevel;
  function ConfirmLevelSave: integer;
  procedure LevelSelectChange (Sender: TObject);
  procedure FormClose (Sender: TObject; var Action: TCloseAction);
  procedure MenuSaveROMClick (Sender: TObject);
  procedure MenuSaveROMAsClick (Sender: TObject);
  procedure MenuAboutClick (Sender: TObject);
  procedure CalcStats;
  procedure ClearButtonClick (Sender: TObject);
  procedure FillButtonClick (Sender: TObject);
  procedure ReplaceButtonClick (Sender: TObject);
  procedure MenuTexEditorClick (Sender: TObject);
  procedure BuildTextures;
  function HexToInt (HexStr: string): int64;
  procedure StartupTimerTimer (Sender: TObject);
  procedure UpdateTexView (Value: byte);
  procedure MenuPalEditExecute (Sender: TObject);
  procedure MapDrawCell (Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
  procedure MapContextPopup (Sender: TObject; MousePos: TPoint; var Handled: boolean);
  procedure MapSelectCell (Sender: TObject; ACol, ARow: integer; var CanSelect: boolean);
  procedure MapSetEditText (Sender: TObject; ACol, ARow: integer; const Value: string);
private
  { Private declarations }
public
  { Public declarations }
  // var
  TexTilesOffset, E1TexOffset, E2TexOffset, E3TexOffset: integer;
  ZMap1, ZMap2, ZMap3, CE: TZMap;
  CurPal: array [0..15] of TColor;
  DataChanged: boolean;
  CurEp:  byte;
  CurLev: byte;
end;


type
TLevelMap = array of array of byte;     // Level map is a 32x32 grid

TBeyondLevel = record
  Offset: longword;
  X, Y:   byte
end;
TGenesisColor = array [0..1] of byte;
TGenesisPal = array [0..15] of TGenesisColor;
TLevelShortName = array [0..15] of AnsiChar; // Short level name is 16
// characters wdde
TCellDef = record
  CellType: byte;
  Name, Description: string
end;

const
IniName = 'ztedit.ini';
ROMSection = 'ROM';
ColorsSection = 'Colors';
CellDefsSection = 'CellDefs';
BCellDefsSection = 'BCellDefs';
ValidIDKey = 'ValidID';
ValidID2Key = 'ValidID2';
IDOffsetKey = 'IDOffset';
ShortNamesOffsetKey = 'ShortNamesOffset';
TexTilesOffsetKey = 'TexTilesOffset';
PalOffsetKey = 'PalOffset';
E1OffsetKey = 'E1Offset';
E2OffsetKey = 'E2Offset';
E3OffsetKey = 'E3Offset';
E1TexOffsetKey = 'E1TexOffset';
E2TexOffsetKey = 'E2TexOffset';
E3TexOffsetKey = 'E3TexOffset';
BE1OffsetKey = 'BE1Offset';
BE2OffsetKey = 'BE2Offset';
BE3OffsetKey = 'BE3Offset';
BeyondE1Section = 'BE1L';
BeyondE2Section = 'BE2L';
BeyondE3Section = 'BE3L';
OffsetKey = 'Offset';
XKey    = 'X';
YKey    = 'Y';
CellKey = 'Cell';
/// defaults ///
DefaultShortNamesOffset = $30B2;   // Short level names offset (used in start menu)
DefaultIDOffset = $180;            // ROM cart serial number offset
DefaultValidID = 'GM T-119146-01'; // Game ROM serial number
DefaultValidID2 = 'GM T-119146-00';// Game ROM serial number
DefaultTexTilesOffset = $12EF26;   // Texture tiles offset
DefaultPalOffset = $21F2;          // Palette offset
DefaultE1Offset = $15BA0A;         // Episode 1 maps offset
DefaultE2Offset = $161D24;         // Episode 2 maps offset
DefaultE3Offset = $16792C;         // Episode 3 maps offset
DefaultE1TexOffset = $15A10A;      // Episode 1 textures offset
DefaultE2TexOffset = $160424;      // Episode 2 textures offset
DefaultE3TexOffset = $16602C;      // Episode 3 textures offset
DefaultBE1Offset = $AC630;  // Beyond Episode 1 definitions offset
DefaultBE2Offset = $B0CF6;  // Beyond Episode 1 definitions offset
DefaultBE3Offset = $B5CBE;  // Beyond Episode 1 definitions offset
WindowTitle = '%s - %s';
StatFmt = 'Enemies: %d   Weapons: %d    Items: %d    Sprites: %d';
CellTypes: array [0..16] of string = (
  'Empty', 'Wall', 'Upper-right corner', 'Lower-right corner',
  'Lower-left corner', 'Upper-left corner', 'Horizontal door',
  'Vertical door', 'Special', 'Player start', 'Enemy', 'Unknown',
  'Weapon', 'Item', 'Special wall', 'Shootable wall', 'Sprite');
  {CurPal: Array [0..15] of TColor = (
  $00E000E0, $00402000, $00806040, $00c0a080,
  $00e0c0c0, $00002020, $00004040, $00e06020,
  $00000040, $00002060, $004080e0, $00204080,
  $00a0e0e0, $000020c0, $00208040, $00000000);}

var
MainForm: TMainForm;
Ini:     TIniFile;
IDOffset, ShortNamesOffset, PalOffset, E1Offset, E2Offset, E3Offset, BE1Offset, BE2Offset, BE3Offset, BeyondOffset, BackgroundColor, BackgroundText, MainColor1, MainColor2, MainColor3, MainText, SpecialColor, SpecialText, StartColor, StartText, EnemyColor, EnemyText, UnknownColor, UnknownText, WeaponColor, WeaponText, ItemColor, ItemText, SpecialWallColor, SpecialWallText, ReservedColor, ReservedText: longword;
ValidID, ValidID2: string;
CellDefs, BCellDefs: array [0..255] of TCellDef;
ROM:     TMemoryStream; // The game ROM will be loaded in here
ID:      array [0..13] of AnsiChar; // ROM serial variable
ShortNames: array [0..43] of TLevelShortName; // There are 44 records
CurrentMap: array of array of byte; // The map being edited is loaded in here
BeyondROM: boolean;
MapTile: TBitmap;
ParentPopupItems: array [0..16] of TMenuItem;
PopupItems: array [0..255] of TMenuItem;
PPopup:  boolean;
CurCol, CurRow: integer;
BeyondLevels: array [0..23] of TBeyondLevel;
RomPal:  TGenesisPal;

implementation

uses about, TexEdit, PalEdit;

{$R *.lfm}

function TMainForm.HexToInt (HexStr: string): int64;
var
  RetVar: int64;
  i:      byte;
begin
  HexStr := UpperCase (HexStr);
  if HexStr = '' then
    HexStr := '00';
  if HexStr[length (HexStr)] = 'H' then
    Delete (HexStr, length (HexStr), 1);
  RetVar := 0;

  for i := 1 to length (HexStr) do
    begin
    RetVar := RetVar shl 4;
    if HexStr[i] in ['0'..'9'] then
      RetVar := RetVar + (byte (HexStr[i]) - 48)
    else
      if HexStr[i] in ['A'..'F'] then
        RetVar := RetVar + (byte (HexStr[i]) - 55)
      else
        begin
        Retvar := 0;
        break;
        end;
    end;
  Result := RetVar;
end;


function Split (Cmd: string): TCellDef;
var
  S: string;
begin
  S := Copy (Cmd, 1, Pos (';', Cmd) - 1);
  Delete (Cmd, 1, Pos (';', Cmd));
  Result.CellType := StrToInt (S);
  S := Copy (Cmd, 1, Pos (';', Cmd) - 1);
  Delete (Cmd, 1, Pos (';', Cmd));
  Result.Name := S;
  Result.Description := Cmd;
end;


procedure TMainForm.BuildTextures;
const
  StatText = 'Episode %d texture %d of %d';
var
  CurTile: TBitmap;
  TileBuf: array [0..511] of byte;

  function GetClr1 (B: byte): byte;
    begin
      Result := B shr 4;
    end;

  function GetClr2 (B: byte): byte;
    begin
      B := B shl 4;
      Result := B shr 4;
    end;

  procedure BuildTiles;
    var
      I, J, K, L: word;
    begin
      ROM.Seek (TexTilesOffset, soFromBeginning);
      TileList.Clear;
      for L := 0 to 246 do
        begin
        K := 0;
        ROM.ReadBuffer (TileBuf, SizeOf (TileBuf));
        CurTile := TBitmap.Create;
        CurTile.Width := 32;
        CurTile.Height := 32;
        for I := 0 to 15 do
          begin
          for J := 0 to 31 do
            begin
            CurTile.Canvas.Pixels[I * 2, J] := CurPal[GetClr1 (TileBuf[K])];
            CurTile.Canvas.Pixels[I * 2 + 1, J] := CurPal[GetClr2 (TileBuf[K])];
            Inc (K);
            end;
          end;
        TileList.Add (CurTile, nil);
        CurTile.Free;
        end;
    end;


  procedure BuildTextureEp (Ep: TZMap; EpNum: byte; var DestList: TImageList);
    var
      I, J, L: word;
      Tiles:      array [0..7] of TBitmap;
      DRect, SRect: TRect;
    begin
      DestList.Clear;
      CurTile := TBitmap.Create;
      CurTile.Width := 128;
      CurTile.Height := 64;
      for L := 0 to 255 do
        begin
        for i := 0 to 7 do
          begin
          Tiles[i] := TBitmap.Create;
          TileList.GetBitmap (Hi (Ep.TexDefs[L, i]), Tiles[i]);
          end;
        SRect:=Bounds(0,0,32,32);

        for i := 0 to 3 do
          for j := 0 to 1 do
            begin
            DRect:=Bounds(i * 32,j * 32,32,32);
            CurTile.Canvas.CopyRect (DRect, Tiles[2*i+j].Canvas, SRect);
            end;

        for i := 0 to 7 do
          Tiles[i].Free;
        DestList.Add (CurTile, nil);
        LevelStatBar.Panels.Items[4].Text:=Format(StatText,[EpNum,L+1,256]);
        Application.ProcessMessages;
        end;
      CurTile.Free;
    end;

begin
  MainForm.Enabled := False;
  BuildTiles;
  BuildTextureEp (ZMap1, 1, TexList1);
  BuildTextureEp (ZMap2, 2, TexList2);
  BuildTextureEp (ZMap3, 3, TexList3);
  LevelStatBar.Panels.Items[4].Text:='';
  MainForm.Enabled := True;
  MainForm.BringToFront;
end;


procedure TMainForm.UpdateTexView (Value: byte);
var
  TmpList: TImageList;
begin
  NorthTexture.Picture := nil;
  SouthTexture.Picture := nil;
  EastTexture.Picture := nil;
  WestTexture.Picture := nil;
  case CurEp of
    0: exit;
    1: TmpList := TexList1;
    2: TmpList := TexList2;
    3: TmpList := TexList3;
    end;
  TmpList.GetBitmap (Hi (CE.TexOrders[Value, 0]), NorthTexture.Picture.Bitmap);
  TmpList.GetBitmap (Hi (CE.TexOrders[Value, 1]), WestTexture.Picture.Bitmap);
  TmpList.GetBitmap (Hi (CE.TexOrders[Value, 2]), EastTexture.Picture.Bitmap);
  TmpList.GetBitmap (Hi (CE.TexOrders[Value, 3]), SouthTexture.Picture.Bitmap);
  Application.ProcessMessages;
end;


procedure TMainForm.ReadIni;
var
  I: byte;
begin
  // reading ROM-related variables //
  ValidID := Ini.ReadString (ROMSection, ValidIDKey, DefaultValidID);
  ValidID2 := Ini.ReadString (ROMSection, ValidID2Key, DefaultValidID2);
  IDOffset := Ini.ReadInteger (ROMSection, IDOffsetKey, DefaultIDOffset);
  ShortNamesOffset := Ini.ReadInteger (ROMSection, ShortNamesOffsetKey,
    DefaultShortNamesOffset);
  TexTilesOffset := Ini.ReadInteger (ROMSection, TexTilesOffsetKey, DefaultTexTilesOffset);
  E1Offset := Ini.ReadInteger (ROMSection, E1OffsetKey, DefaultE1Offset);
  E2Offset := Ini.ReadInteger (ROMSection, E2OffsetKey, DefaultE2Offset);
  E3Offset := Ini.ReadInteger (ROMSection, E3OffsetKey, DefaultE3Offset);
  PalOffset := Ini.ReadInteger (ROMSection, PalOffsetKey, DefaultPalOffset);
  E1TexOffset := Ini.ReadInteger (ROMSection, E1TexOffsetKey, DefaultE1TexOffset);
  E2TexOffset := Ini.ReadInteger (ROMSection, E2TexOffsetKey, DefaultE2TexOffset);
  E3TexOffset := Ini.ReadInteger (ROMSection, E3TexOffsetKey, DefaultE3TexOffset);
  BE1Offset := Ini.ReadInteger (ROMSection, BE1OffsetKey, DefaultBE1Offset);
  BE2Offset := Ini.ReadInteger (ROMSection, BE2OffsetKey, DefaultBE2Offset);
  BE3Offset := Ini.ReadInteger (ROMSection, BE3OffsetKey, DefaultBE3Offset);
  for I := 0 to 7 do
    begin
    BeyondLevels[I].Offset := Ini.ReadInteger (BeyondE1Section + IntToStr (I + 1), OffsetKey, 0);
    BeyondLevels[I].X := Ini.ReadInteger (BeyondE1Section + IntToStr (I + 1), XKey, 0);
    BeyondLevels[I].Y := Ini.ReadInteger (BeyondE1Section + IntToStr (I + 1), YKey, 0);
    end;
  for I := 8 to 13 do
    begin
    BeyondLevels[I].Offset := Ini.ReadInteger (BeyondE2Section + IntToStr (I - 7), OffsetKey, 0);
    BeyondLevels[I].X := Ini.ReadInteger (BeyondE2Section + IntToStr (I - 7), XKey, 0);
    BeyondLevels[I].Y := Ini.ReadInteger (BeyondE2Section + IntToStr (I - 7), YKey, 0);
    end;
  for I := 14 to 23 do
    begin
    BeyondLevels[I].Offset := Ini.ReadInteger (BeyondE3Section + IntToStr (I - 13), OffsetKey, 0);
    BeyondLevels[I].X := Ini.ReadInteger (BeyondE3Section + IntToStr (I - 13), XKey, 0);
    BeyondLevels[I].Y := Ini.ReadInteger (BeyondE3Section + IntToStr (I - 13), YKey, 0);
    end;
  // reading cell definitions //
  for I := 0 to 255 do
    begin
    CellDefs[I] := Split (Ini.ReadString (CellDefsSection, CellKey + IntToStr (I), '11;Undefined;'));
    BCellDefs[I] := Split (Ini.ReadString (BCellDefsSection, CellKey + IntToStr (I), '11;empty'));
    if BCellDefs[I].Description = 'empty' then
      BCellDefs[I] := CellDefs[I];
    end;
end;


procedure TMainForm.ReplaceButtonClick (Sender: TObject);
var
  I, J:  byte;
  Count: word;
begin
  Count := 0;
  for I := 0 to Map.ColCount-1 do
    for J := 0 to Map.RowCount-1 do
      if Uppercase (Map.Cells[I, J]) = Uppercase (ReplaceEdit1.Text) then
        begin
        Map.Cells[I, J] := Uppercase (ReplaceEdit2.Text);
        Count := Count + 1;
        end;
  Application.MessageBox (PChar (IntToStr (Count) + ' replacements made'), 'Information',
    MB_ICONINFORMATION or MB_OK);
end;


procedure TMainForm.FreePopup;
var
  I: byte;
begin
  for I := 255 downto 0 do
    PopupItems[I].Free;
  for I := 16 downto 0 do
    ParentPopupItems[I].Free;
  PPopup := False;
end;


procedure TMainForm.BtnMapZoomInClick(Sender: TObject);
var
  i,n: integer;
begin

if Map.Width>32*100 then
  exit;

for i:=0 to Map.ColCount-1 do
  begin
  Map.ColWidths[i]:=Map.ColWidths[i]+4;
  Map.RowHeights[i]:=Map.RowHeights[i]+4;
  end;
n:=0;
for i:=0 to Map.ColCount-1 do
  n+=Map.ColWidths[i];
Map.Width:=n;
Map.Height:=n;
end;

procedure TMainForm.BtnMapZoomOutClick(Sender: TObject);
var
  i,n: integer;
begin

if Map.Width<32*17 then
  exit;

for i:=0 to Map.ColCount-1 do
  begin
  Map.ColWidths[i]:=Map.ColWidths[i]-4;
  Map.RowHeights[i]:=Map.RowHeights[i]-4;
  end;
n:=0;
for i:=0 to Map.ColCount-1 do
  n+=Map.ColWidths[i];
Map.Width:=n;
Map.Height:=n;
end;



procedure TMainForm.MenuDefClick (Sender: TObject);
begin
  with Sender as TMenuItem do
    Map.Cells[CurCol, CurRow] := IntToHex (Tag, 2);
end;


procedure TMainForm.LevelSelectChange (Sender: TObject);
var
  LN, EN: byte;
begin
  MainForm.Enabled := False;
  if LevelChanged then
    case ConfirmLevelSave of
      mrCancel: Exit;
      mrYes: SaveLevel
      end;
  case LevelSelect.ItemIndex of
    0..15:
      begin
      LN := LevelSelect.ItemIndex;
      EN := 1;
      end;
    16..31:
      begin
      LN := LevelSelect.ItemIndex - 16;
      EN := 2;
      end;
    32..47:
      begin
      LN := LevelSelect.ItemIndex - 32;
      EN := 3;
      end;
    end;
  LoadLevel (EN, LN);
  MainForm.Enabled := True;
  LevelSelect.SetFocus;
end;


function TMainForm.LoadROM: boolean;
var
  I: byte;
  J: integer;


procedure LoadPal;
  var
    CurClr, CurClr2: string;
    I, J: byte;
  begin
    ROM.Seek (PalOffset, soFromBeginning);
    ROM.ReadBuffer (RomPal, SizeOf (RomPal));
    for I := 0 to 15 do
      begin
      CurClr2 := '$';
      CurClr := IntToHex (RomPal[I][0], 2) + IntToHex (RomPal[I][1], 2);
      for J := 1 to Length (CurClr) do
        CurClr2 := CurClr2 + CurClr[J] + '0';
      if I <> 0 then
        CurPal[I] := StrToInt (CurClr2)
      else
        CurPal[I] := StrToInt ('$00E000E0');
      end;
  end;

begin
  Result := False;
  if DataChanged then
    case ConfirmROMSave of
      mrCancel: Exit;
      mrYes: SaveROM
      end;
  DataChanged := False;
  if not OpenDialog.Execute then
    Exit;
  MainForm.Enabled := False;
  LevelSelect.Clear;
  ROM.LoadFromFile (OpenDialog.FileName);
  ROM.Seek (IDOffset, soFromBeginning);
  ROM.ReadBuffer (ID, SizeOf (ID)); // Read ROM serial
  if (ID <> ValidID) and (ID <> ValidID2) then // The file is invalid, we won' load it
    begin
    Application.MessageBox ('This is not a valid Zero Tolerance ROM file.'#13#10 +
      'A good dump in .BIN (not .SMD) format is required.',
      'Error', MB_ICONERROR or MB_OK);
    Exit;
    end;
  if ID = ValidID2 then
    begin
    Application.MessageBox ('Sorry, Beyond Zero Tolerance support has been temporarily ' +
      'removed from this release. It will be back soon.',
      'Error', MB_ICONERROR or MB_OK);
    Exit;
    end;
  BeyondROM := False;
  if ID = ValidID2 then
    BeyondROM := True;
  SaveDialog.FileName := OpenDialog.FileName;
  if not BeyondROM then
    begin
    LoadPal;
    ROM.Seek (ShortNamesOffset, soFromBeginning);
    ROM.ReadBuffer (ShortNames, SizeOf (ShortNames));
    for I := 0 to 43 do
      LevelSelect.Items.Add (ShortNames[I]);
    for I := 44 to 47 do
      LevelSelect.Items.Add ('<UNTITLED ' + IntToStr (I) + '>');
    ROM.Seek (E1Offset, soFromBeginning);
    ROM.ReadBuffer (ZMap1, SizeOf (ZMap1));
    ROM.Seek (E2Offset, soFromBeginning);
    ROM.ReadBuffer (ZMap2, SizeOf (ZMap2));
    ROM.Seek (E3Offset, soFromBeginning);
    ROM.ReadBuffer (ZMap3, SizeOf (ZMap3));
    end
  else
    begin
    ROM.Seek (BE1Offset, soFromBeginning);
    ROM.ReadBuffer (ZMap1, SizeOf (ZMap1));
    ROM.Seek (BE2Offset, soFromBeginning);
    ROM.ReadBuffer (ZMap2, SizeOf (ZMap2));
    ROM.Seek (BE3Offset, soFromBeginning);
    ROM.ReadBuffer (ZMap3, SizeOf (ZMap3));
    for I := 0 to 7 do
      LevelSelect.Items.Add (BeyondE1Section + IntToStr (I + 1));
    for I := 8 to 13 do
      LevelSelect.Items.Add (BeyondE2Section + IntToStr (I - 7));
    for I := 14 to 23 do
      LevelSelect.Items.Add (BeyondE3Section + IntToStr (I - 13));
    end;
  LevelSelect.ItemIndex := 0;
  for I := 0 to Map.ColCount - 1 do
    for J := 0 to Map.RowCount - 1 do
      Map.Cells[I, J] := '';
  BuildTextures;
  LoadLevel (1, 0);
  MenuSaveROM.Enabled := True;
  MenuSaveROMAs.Enabled := True;
  MainForm.Enabled := True;
  Result := True;
  CalcStats;
end;


procedure TMainForm.SaveROM;


procedure SavePal;
  var
    SCurrentClr: string;
    CurrentClr: array [0..1] of byte;
    I: byte;
  begin
    ROM.Seek (PalOffset, soFromBeginning);
    for I := 0 to 15 do
      begin
      SCurrentClr := IntToHex (CurPal[I], 8);
      SCurrentClr := SCurrentClr[1] + SCurrentClr[3] + SCurrentClr[5] + SCurrentClr[7];
      if I = 0 then
        begin
        CurrentClr[0] := 0;
        CurrentClr[1] := 0;
        end
      else
        begin
        //        ShowMessage('$'+SCurrentClr[1]+SCurrentClr[2]+', '+'$'+SCurrentClr[3]+SCurrentClr[4]);
        CurrentClr[0] := StrToInt ('$' + SCurrentClr[1] + SCurrentClr[2]);
        CurrentClr[1] := StrToInt ('$' + SCurrentClr[3] + SCurrentClr[4]);
        end;
      RomPal[I][0] := CurrentClr[0];
      RomPal[I][1] := Currentclr[1];
      end;
    ROM.WriteBuffer (RomPal, SizeOf (RomPal));
  end;

begin
  SavePal;
  ROM.SaveToFile (SaveDialog.FileName);
  DataChanged := False;
end;


procedure TMainForm.StartupTimerTimer (Sender: TObject);
begin
  StartupTimer.Enabled := False;
  if not LoadROM then
    Application.Terminate;
end;



function TMainForm.ConfirmROMSave: integer;
begin
  Result := Application.MessageBox ('ROM data has been changed. Do you wish to ' +
    'save changes?', 'Question', MB_ICONQUESTION or
    MB_YESNOCANCEL);
end;


procedure TMainForm.LoadLevel (EpisodeNum, LevelNum: byte);
var
  I, J: byte;
  CI:   string;
begin
  case EpisodeNum of
    1: CE := ZMap1;
    2: CE := ZMap2;
    3: CE := ZMap3;
    end;
  CellLabel.Caption := '';
  if PPopup then
    FreePopup;
  Map.ColCount := 32;
  Map.RowCount := 32;
  if (EpisodeNum = 3) and (LevelNum > 11) then
    MainForm.Caption := '?'
  else
    MainForm.Caption := 'Map - ' + ShortNames[LevelNum + 16 * (EpisodeNum - 1)];// Show level name below the map grid}
  for I := 0 to 16 do
    begin
    ParentPopupItems[I] := TMenuItem.Create (MapPopup);
    MapPopup.Items.Add (ParentPopupItems[I]);
    ParentPopupItems[I].Name := 'PopupParent' + IntToStr (I);
    ParentPopupItems[I].Caption := CellTypes[I];
    end;
  for I := 0 to 255 do
    begin
    CI := IntToHex (I, 2);
    PopupItems[I] := TMenuItem.Create (MapPopup);
    MapPopup.Items[CellDefs[CE.CellDefs[I]].CellType].Add (PopupItems[I]);
    PopupItems[I].Name := 'MenuDef' + IntToStr (I);
    PopupItems[I].Caption := '[' + CI + ']: ' + CellDefs[CE.CellDefs[I]].Name;
    PopupItems[I].Tag := I;
    PopupItems[I].OnClick := MenuDefClick;
    end;
  PPopup := True;
  SetLength (CurrentMap, 32, 32);
  for I := 0 to 31 do
    for J := 0 to 31 do
      begin
      CurrentMap[I, J] := CE.Levels[LevelNum, I, J];
      Map.Cells[J, I] := IntToHex (CurrentMap[I, J], 2);
      end;
  CurEp := EpisodeNum;
  CurLev := LevelNum;
  Map.Refresh; // Redraw the grid
  CalcStats;
end;


function TMainForm.LevelChanged: boolean;
var
  I, J:   byte;
  NewMap: TLevelMap;
begin
  Result := False;
  SetLength (NewMap, Map.RowCount, Map.ColCount);
  for I := 0 to Map.RowCount - 1 do
    for J := 0 to Map.ColCount - 1 do
      begin
      NewMap[I, J] := HexToInt (Map.Cells[J, I]);
      if NewMap[I, J] <> CurrentMap[I, J] then
        Result := True;
      end;
end;


function TMainForm.ConfirmLevelSave: integer;
begin
  Result := Application.MessageBox ('Level data has been changed. Do you wish to ' +
    'save changes?', 'Question', MB_ICONQUESTION or
    MB_YESNOCANCEL);
end;


procedure TMainForm.MenuSaveROMAsClick (Sender: TObject);
begin
  if LevelChanged then
    case ConfirmLevelSave of
      mrYes: SaveLevel;
      mrCancel: Exit
      end;
  if SaveDialog.Execute then
    SaveROM;
end;


procedure TMainForm.SaveLevel;
var
  NewMap: array of array of byte;
  I, J:   byte;
begin
  case CurEp of
    1:
      begin
      ROM.Seek (E1Offset, soFromBeginning);
      CE := ZMap1;
      end;// Ep. 1 maps
    2:
      begin
      ROM.Seek (E2Offset, soFromBeginning);
      CE := ZMap2;
      end;// Ep. 2 maps
    3:
      begin
      ROM.Seek (E3Offset, soFromBeginning);
      CE := ZMap3;
      end;// Ep. 3 maps
    else
      Exit; // Level # is out of bounds so we're not saving it
    end;
  SetLength (NewMap, Map.RowCount, Map.ColCount);
  for I := 0 to Map.RowCount - 1 do
    for J := 0 to Map.ColCount - 1 do
      begin
      NewMap[I, J] := HexToInt (Map.Cells[J, I]);
      CurrentMap[I, J] := NewMap[I, J];
      CE.Levels[CurLev, I, J] := CurrentMap[I, J];
      end;
  case CurEp of
    1: ZMap1 := CE;
    2: ZMap2 := CE;
    3: ZMap3 := CE;
    end;
  ROM.WriteBuffer (CE, SizeOf (CE));
  DataChanged := True;
end;


procedure TMainForm.FillButtonClick (Sender: TObject);
var
  I, J: byte;
begin
  if Application.MessageBox ('Are you sure you want to fill this map?', 'Question',
    MB_ICONQUESTION or MB_YESNO) = mrYes then
    for I := 0 to Map.ColCount-1 do
      for J := 0 to Map.RowCount-1 do
        Map.Cells[I, J] := FillEdit.Text;
end;


procedure TMainForm.FormClose (Sender: TObject; var Action: TCloseAction);
begin
  if LevelChanged then
    case ConfirmLevelSave of
      mrCancel:
        begin
        Action := caNone;
        Exit;
        end;
      mrYes: SaveLevel
      end;
  if DataChanged then
    case ConfirmROMSave of
      mrCancel:
        begin
        Action := caNone;
        Exit;
        end;
      mrYes: SaveROM
      end;
end;


procedure TMainForm.FormCreate (Sender: TObject);
var
  i: integer;
begin
  CurEp := 0;
  PPopup := False;
  Ini := TIniFile.Create (ExtractFilePath (Application.ExeName)+ IniName);
  ReadIni;
  DataChanged := False;
  ROM := TMemoryStream.Create; // Initialize ROM content storage

  ImageListCells.GetBitmap (0, ImageLegendEmpty.Picture.Bitmap);
  ImageListCells.GetBitmap (1, ImageLegendWall.Picture.Bitmap);
  ImageListCells.GetBitmap (5, ImageLegendULCorner.Picture.Bitmap);
  ImageListCells.GetBitmap (2, ImageLegendURCorner.Picture.Bitmap);
  ImageListCells.GetBitmap (4, ImageLegendLLCorner.Picture.Bitmap);
  ImageListCells.GetBitmap (3, ImageLegendLRCorner.Picture.Bitmap);
  ImageListCells.GetBitmap (6, ImageLegendDoorHor.Picture.Bitmap);
  ImageListCells.GetBitmap (7, ImageLegendDoorVer.Picture.Bitmap);
  ImageListCells.GetBitmap (8, ImageLegendSpecialCell.Picture.Bitmap);
  ImageListCells.GetBitmap (9, ImageLegendStart.Picture.Bitmap);
  ImageListCells.GetBitmap (10, ImageLegendEnemy.Picture.Bitmap);
  ImageListCells.GetBitmap (12, ImageLegendWeapon.Picture.Bitmap);
  ImageListCells.GetBitmap (13, ImageLegendItem.Picture.Bitmap);
  ImageListCells.GetBitmap (14, ImageLegendSpecialWall.Picture.Bitmap);
  ImageListCells.GetBitmap (15, ImageLegendShootableWall.Picture.Bitmap);
  ImageListCells.GetBitmap (11, ImageLegendUnknown.Picture.Bitmap);

  MapTile := TBitmap.Create;
  for i:=0 to Map.ColCount-1 do
    begin
    Map.ColWidths[i]:=16;
    Map.RowHeights[i]:=16;
    end;
  Map.Width:=Map.DefaultColWidth*32;
  Map.Height:=Map.DefaultRowHeight*32;
end;


procedure TMainForm.FormDestroy (Sender: TObject);
begin
  FreePopup;
  MapTile.Free;
  Ini.Free;
  ROM.Free; // Destroy ROM content storage
end;


procedure TMainForm.ClearButtonClick (Sender: TObject);
var
  I, J: byte;
begin
  if Application.MessageBox ('Are you sure you want to clear this map?', 'Question',
    MB_ICONQUESTION or MB_YESNO) = mrYes then
    for I := 0 to Map.ColCount-1 do
      for J := 0 to Map.RowCount-1 do
        Map.Cells[I, J] := '00';
end;


procedure TMainForm.CalcStats;
var
  Enemies, Weapons, Items, Sprites: word;
  I, J: byte;
begin
  Enemies := 0;
  Weapons := 0;
  Items := 0;
  Sprites := 0;
  for I := 0 to Map.ColCount - 1 do
    for J := 0 to Map.RowCount - 1 do
      if BeyondROM then
        case BCellDefs[CE.CellDefs[HexToInt (Map.Cells[I, J])]].CellType of
          10: Enemies := Enemies + 1;
          12: Weapons := Weapons + 1;
          13: Items := Items + 1;
          16: Sprites := Sprites + 1
          end
      else
        case CellDefs[CE.CellDefs[HexToInt (Map.Cells[I, J])]].CellType of
          10: Enemies := Enemies + 1;
          12: Weapons := Weapons + 1;
          13: Items := Items + 1;
          16: Sprites := Sprites + 1
          end;
  LevelStatBar.Panels.Items[0].Text := 'Enemies: ' + IntToStr (Enemies);
  LevelStatBar.Panels.Items[1].Text := 'Weapons: ' + IntToStr (Weapons);
  LevelStatBar.Panels.Items[2].Text := 'Items: ' + IntToStr (Items);
  LevelStatBar.Panels.Items[3].Text := 'Sprites: ' + IntToStr (Sprites);
end;


procedure TMainForm.MenuAboutClick (Sender: TObject);
begin
  AboutForm.ShowModal;
end;


procedure TMainForm.MenuExitClick (Sender: TObject);
begin
  Close;
end;


procedure TMainForm.MenuOpenROMClick (Sender: TObject);
begin
  LoadROM;
end;


procedure TMainForm.MenuPalEditExecute (Sender: TObject);
begin
  PalEditForm.ShowModal;
end;


procedure TMainForm.MenuSaveROMClick (Sender: TObject);
begin
  if LevelChanged then
    case ConfirmLevelSave of
      mrYes: SaveLevel;
      mrCancel: Exit
      end;
  SaveROM;
end;


procedure TMainForm.MenuTexEditorClick (Sender: TObject);
begin
  Application.CreateForm (TTexEditForm, TexEditForm);
  TexEditForm.ShowModal;
end;


procedure TMainForm.MapContextPopup (Sender: TObject; MousePos: TPoint; var Handled: boolean);
var
  CanSelect: boolean;
begin
  Map.MouseToCell (MousePos.X, MousePos.Y, CurCol, CurRow);
  MapSelectCell (Map, CurCol, CurRow, CanSelect);
end;


procedure TMainForm.MapDrawCell (Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
var
  TileNum: byte;
  CL: word;
  S: string;
begin
  with MainForm do
    begin
    CL := Length (Map.Cells[ACol, ARow]);
    if CL < 2 then
      Map.Cells[ACol, ARow] := '0' + Map.Cells[ACol, ARow];
    if CL > 2 then
      begin
      S := Map.Cells[ACol, ARow];
      Delete (S, 3, CL - 1);
      Map.Cells[ACol, ARow] := S;
      end;
    if Map.Cells[ACol, ARow] <> Uppercase (Map.Cells[ACol, ARow]) then
      Map.Cells[ACol, ARow] := Uppercase (Map.Cells[ACol, ARow]);
    if BeyondROM then
      TileNum := BCellDefs[CE.CellDefs[HexToInt (Map.Cells[ACol, ARow])]].CellType
    else
      TileNum := CellDefs[CE.CellDefs[HexToInt (Map.Cells[ACol, ARow])]].CellType;
    if TileNum in [8, 10, 13, 16] then
      Map.Canvas.Font.Color := clWhite
    else
      Map.Canvas.Font.Color := clBlack;
    ImageListCells.GetBitmap (TileNum, MapTile);
    Map.Canvas.StretchDraw (Rect, MapTile);
    if not (TileNum in [0, 6, 7]) then
      with Map.Canvas, Rect do
        begin
        Map.Canvas.Brush.Style := bsClear;
        Map.Canvas.Font.Name := 'Small Fonts';
        Map.Canvas.Font.Size := 6;
        case TileNum of
          2: Map.Canvas.TextOut (Left + 6, Top, UpperCase (Map.Cells[ACol, ARow]));
          3: Map.Canvas.TextOut (Left + 6, Top + 7, UpperCase (Map.Cells[ACol, ARow]));
          4: Map.Canvas.TextOut (Left, Top + 7, UpperCase (Map.Cells[ACol, ARow]));
          5: Map.Canvas.TextOut (Left, Top, UpperCase (Map.Cells[ACol, ARow]));
          else
            Map.Canvas.TextOut (Left + 3, Top + 3, UpperCase (Map.Cells[ACol, ARow]))
          end;
        end;
    if gdSelected in State then
      begin
      Map.Canvas.Pen.Style:=psSolid;
      Map.Canvas.Pen.Color := clRed;
      Map.Canvas.Rectangle (Rect.Left, Rect.Top, Rect.Right, Rect.Top + 2);
      Map.Canvas.Rectangle (Rect.Left, Rect.Top, Rect.Left + 2, Rect.Bottom);
      Map.Canvas.Rectangle (Rect.Left, Rect.Bottom - 2, Rect.Right, Rect.Bottom);
      Map.Canvas.Rectangle (Rect.Right - 2, Rect.Top, Rect.Right, Rect.Bottom);
      end;
    end;
end;


procedure TMainForm.MapSelectCell (Sender: TObject; ACol, ARow: integer; var CanSelect: boolean);
const
  CellLabelText = '[%s] %s';
var
  CNum, CDef, CName: string;
begin

CNum := Map.Cells[ACol, ARow];
if BeyondROM then
  begin
  CDef := CellTypes[BCellDefs[CE.CellDefs[HexToInt (Map.Cells[ACol, ARow])]].CellType];
  CName := BCellDefs[CE.CellDefs[HexToInt (Map.Cells[ACol, ARow])]].Name;
  end
else
  begin
  CDef := CellTypes[CellDefs[CE.CellDefs[HexToInt (Map.Cells[ACol, ARow])]].CellType];
  CName := CellDefs[CE.CellDefs[HexToInt (Map.Cells[ACol, ARow])]].Name;
  end;
if CName <> '' then
  CDef := CDef + ': ' + CName;
{if BeyondROM then
  CDescr := BCellDefs[CE.CellDefs[HexToInt (Map.Cells[ACol, ARow])]].Description
else
  CDescr := CellDefs[CE.CellDefs[HexToInt (Map.Cells[ACol, ARow])]].Description;}
CellLabel.Caption := Format (CellLabelText, [CNum, CDef]);
  try
  UpdateTexView (HexToInt (Map.Cells[ACol, ARow]))
  except
  end;

end;


procedure TMainForm.MapSetEditText (Sender: TObject; ACol, ARow: integer; const Value: string);
begin
  MainForm.CalcStats;
  MainForm.UpdateTexView (MainForm.HexToInt (Value));
end;

end.
