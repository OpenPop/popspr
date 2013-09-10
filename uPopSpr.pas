{
  made by ALACN
  http://www.strategyplanet.com/populous/
}

unit uPopSpr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TPopSprExt = class(TForm)
    btnLoadPal: TButton;
    txtPal: TLabel;
    txtSpr: TLabel;
    btnLoadSpr: TButton;
    txtFrames: TLabel;
    btnExtract: TButton;
    progress: TProgressBar;
    btnCancel: TButton;
    pnlImg: TPanel;
    img: TImage;
    txtALACN: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Lock;
    procedure Unlock;
    procedure load_pal(Sender: TObject);
    procedure load_spr(Sender: TObject);
    procedure extract(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  SPR_HEADER = packed record
    magic: DWORD; // PSFB
    frames_count: DWORD;
  end;

  SPR_ENTRY_HEADER = packed record
    width: WORD;
    height: WORD;
    offset: DWORD;
  end;

const
  PSFB = $42465350;

var
  PopSprExt: TPopSprExt;
  Palette: array[0..255] of DWORD;
  SprFile: string;
  Cancel: boolean;

implementation

{$R *.DFM}

procedure TPopSprExt.FormCreate(Sender: TObject);
begin
  FillChar(Palette, SizeOf(Palette), 0);
end;

procedure TPopSprExt.Lock;
begin
  btnLoadPal.Enabled := False;
  btnLoadSpr.Enabled := False;
  btnExtract.Enabled := False;
end;

procedure TPopSprExt.Unlock;
begin
  btnLoadPal.Enabled := True;
  btnLoadSpr.Enabled := True;
  btnExtract.Enabled := True;
end;

procedure TPopSprExt.load_pal(Sender: TObject);
var
  dlg: TOpenDialog;
  h: THandle;
  dw: DWORD;
begin
  dlg := TOpenDialog.Create(Self);
  with dlg do
  try
    Lock;

    Title := 'Load Palette';
    InitialDir := GetCurrentDir;
    Filter := 'All Files (*.*)|*.*|Palette (pal*.dat)|pal*.dat';
    Options := Options + [ofPathMustExist, ofFileMustExist];

    if not Execute then Exit;

    txtPal.Caption := 'Palette: not loaded';

    h := CreateFile(PChar(dlg.FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if h = INVALID_HANDLE_VALUE then
    begin
      MessageBox(PopSprExt.Handle, 'Cannot Open Palette', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    dw := SetFilePointer(h, 0, nil, 2);
    if dw <> SizeOf(Palette) then
    begin
      CloseHandle(h);
      MessageBox(PopSprExt.Handle, 'Invalid Palette Size', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    SetFilePointer(h, 0, nil, 0);
    dw := 0;
    ReadFile(h, Palette, SizeOf(Palette), dw, nil);
    if dw <> SizeOf(Palette) then
    begin
      CloseHandle(h);
      MessageBox(PopSprExt.Handle, 'Palette Read Error', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    CloseHandle(h);

    txtPal.Caption := 'Palette: ' + ExtractFileName(FileName);
  finally
    dlg.Free;
    Unlock;
  end;
end;

procedure TPopSprExt.load_spr(Sender: TObject);
var
  dlg: TOpenDialog;
  dw: DWORD;
  hdr: SPR_HEADER;
  h: THandle;
begin
  dlg := TOpenDialog.Create(Self);
  with dlg do
  try
    Lock;

    Title := 'Load Sprite';
    InitialDir := GetCurrentDir;
    Filter := 'All Files (*.*)|*.*';
    Options := Options + [ofPathMustExist, ofFileMustExist];

    if not Execute then Exit;

    img.Picture.Bitmap.Width := 0;
    img.Picture.Bitmap.Height := 0;

    txtSpr.Caption := 'Sprite: not loaded';
    SprFile := '';
    txtFrames.Caption := 'Frames: 0';

    h := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if h = INVALID_HANDLE_VALUE then
    begin
      CloseHandle(h);
      MessageBox(PopSprExt.Handle, 'Cannot Open Sprite', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    dw := 0;
    ReadFile(h, hdr, SizeOf(hdr), dw, nil);
    if dw <> SizeOf(hdr) then
    begin
      CloseHandle(h);
      MessageBox(PopSprExt.Handle, 'Read Sprite Error', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    if hdr.magic <> PSFB then
    begin
      CloseHandle(h);
      MessageBox(PopSprExt.Handle, 'Invalid Sprite File', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    txtSpr.Caption := 'Sprite: ' + ExtractFileName(FileName);
    SprFile := FileName;
    txtFrames.Caption := IntToStr(hdr.frames_count);

    CloseHandle(h);
  finally
    dlg.Free;
    Unlock;
  end;
end;

procedure TPopSprExt.extract(Sender: TObject);
var
  dlg: TSaveDialog;
  h: THandle;
  dw, dwOffsetHeader, frames: DWORD;
  x, y, z, w: DWORD;
  hdr: SPR_HEADER;
  entry: SPR_ENTRY_HEADER;
  buf: array[0..255] of BYTE;
  b: BYTE;
  rc: TRect;
begin
  if Length(SprFile) = 0 then Exit;

  dlg := TSaveDialog.Create(Self);
  with dlg do
  try
    Lock;

    Title := 'Extract';
    InitialDir := GetCurrentDir;
    Filter := 'Bitmap (*.bmp)|*.bmp';
    Options := Options + [ofOverwritePrompt];

    if not Execute then Exit;

    h := CreateFile(PChar(SprFile), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if h = INVALID_HANDLE_VALUE then
    begin
      CloseHandle(h);
      MessageBox(PopSprExt.Handle, 'Cannot Open Sprite', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    dw := 0;
    ReadFile(h, hdr, SizeOf(hdr), dw, nil);
    if dw <> SizeOf(hdr) then
    begin
      CloseHandle(h);
      MessageBox(PopSprExt.Handle, 'Read Sprite Error', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    if hdr.magic <> PSFB then
    begin
      CloseHandle(h);
      MessageBox(PopSprExt.Handle, 'Invalid Sprite File', PChar(Application.Title), MB_ICONHAND);
      Exit;
    end;

    progress.Position := 0;
    progress.Max := hdr.frames_count;

    dwOffsetHeader := SizeOf(SPR_HEADER);
    frames := 0;

    Cancel := False;
    while frames < hdr.frames_count do
    begin
      progress.Position := frames;
      Application.ProcessMessages;
      if Cancel then
      begin
        CloseHandle(h);
        Exit;
      end;

      dw := 0;
      ReadFile(h, entry, SizeOf(SPR_ENTRY_HEADER), dw, nil);
      if dw <> SizeOf(SPR_ENTRY_HEADER) then
      begin
        CloseHandle(h);
        MessageBox(PopSprExt.Handle, 'Read Sprite Error', PChar(Application.Title), MB_ICONHAND);
        Exit;
      end;

      img.Picture.Bitmap.Width := entry.width;
      img.Picture.Bitmap.Height := entry.height;
      SetFilePointer(h, entry.offset, nil, 0);

      rc.Left := 0;
      rc.Top := 0;
      rc.Right := entry.width;
      rc.Bottom := entry.height;
      img.Picture.Bitmap.Canvas.Brush.Color := 0;
      img.Picture.Bitmap.Canvas.FillRect(rc);

      Application.ProcessMessages;

      y := 0;
      x := 0;
      z := 0;
      w := 0;
      dw := 0;
      while y < entry.height do
      begin
        if dw = 0 then
        begin
          ReadFile(h, buf, SizeOf(buf), dw, nil);
          if dw = 0 then break;
          z := 0;
        end;

        b := buf[z];

        if w = 0
        then begin
          if b < $80
          then begin
            w := b;
            if w = 0 then
            begin
              x := 0;
              y := y + 1;
            end;
          end
          else begin
            x := x + (b xor $FF) + 1;
          end;
        end
        else begin
          w := w - 1;
          if (x < entry.width) and (y < entry.height) then
            img.Picture.Bitmap.Canvas.Pixels[x, y] := Palette[b];
          x := x + 1;
        end;

        z := z + 1;
        dw := dw - 1;
      end;

      try
        img.Picture.Bitmap.SaveToFile(FileName + IntToStr(frames) + '.bmp');
      except
        CloseHandle(h);
        MessageBox(PopSprExt.Handle, 'Save Failed', PChar(Application.Title), MB_ICONHAND);
        Exit;
      end;

      dwOffsetHeader := dwOffsetHeader + SizeOf(SPR_ENTRY_HEADER);
      SetFilePointer(h, dwOffsetHeader, nil, 0);
      frames := frames + 1;
    end;

    progress.Position := progress.Max;

    CloseHandle(h);
  finally
    dlg.Free;
    Unlock;
  end;
end;

procedure TPopSprExt.btnCancelClick(Sender: TObject);
begin
  Cancel := True;
end;

end.
