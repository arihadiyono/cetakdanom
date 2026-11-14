unit NZip;
{
   Modul        : Nzip
   Deskripsi    : Modul ini menangani kompresi dan dekompresi data
   Autor        : Nasruddin M.
   E-Mail       : nas@posindonesia.co.id
   Versi        : 1.00
   Tanggal      : 21 Oktober 2004
   Library lain :
     1. Zlib V.1.1.4 copyright (c) 2002 Roberto Della Pasqua
   
   Feature      :
   - Suport Type Compressi :
     0 - Tanpa compressi
     1 - Zlib zcFastest
     2 - Zlib zcDefault
     3 - Zlib zcMax
}

interface

Uses
  Classes,ZLibEx;

Type
  TNZip = class
    private
      VZipType:Integer;
      procedure SetZipType(const value:integer);
    protected

    public
      property ZipType : Integer read VZipType write SetZipType;
      function GetZipStr(const value:String):String;
      function GetUnZipStr(const value:String):String;
      procedure GetZipStream(InStream,OutStream:Tstream);
      procedure GetUnZipStream(InStream,OutStream:Tstream);
      constructor Create;
      destructor Destroy;override;
  end;
implementation

procedure TNZip.SetZipType(const value:integer);
begin
  VZipType:=value;
end;

function TNZip.GetZipStr(const value:String):String;
var
  outBuf: Pointer;
  outBytes: Integer;
  s:String;
begin
  s:=value;
  if VzipType<>0 then
  begin
    Case VZipType of
      //0: ZCompress(pointer(s), length(s), outBuf, outBytes, ZcNone);
      1: ZCompress(pointer(s), length(s), outBuf, outBytes, ZcFastest);
      2: ZCompress(pointer(s), length(s), outBuf, outBytes, ZcDefault);
      3: ZCompress(pointer(s), length(s), outBuf, outBytes, ZcMax);
    end;
    SetLength(s, outBytes);
    moveI32(pointer(outBuf)^, pointer(s)^, outBytes);
    Result:=s;
    FreeMem(outBuf);
  end else
  begin
    Result:=s;
  end;
end;

function TNZip.GetUnZipStr(const value:String):String;
var
  buffer: Pointer;
  size: Integer;
begin
  if VZipType <> 0 then
  begin
    ZDecompress(PChar(value), Length(value), buffer, size);
    SetLength(result, size);
    moveI32(buffer^, pointer(result)^, size);
    FreeMem(buffer);
  end else
  begin
    Result:=Value;
  end;
end;

procedure TNZip.GetZipStream(InStream,OutStream:Tstream);
begin
  InStream.Position:=0;
  If VZipType <> 0 then
  begin
    Case VZipType of
      //0: ZCompressStream(InStream,OutStream,zcNone);
      1: ZCompressStream(InStream,OutStream,zcFastest);
      2: ZCompressStream(InStream,OutStream,zcDefault);
      3: ZCompressStream(InStream,OutStream,zcMax);
    end;
  end else
  begin
    OutStream.CopyFrom(Instream,Instream.Size);
  end;
  OutStream.Position:=0;
end;

procedure TNZip.GetUnZipStream(InStream,OutStream:Tstream);
begin
  InStream.Position:=0;
  if VZipType<>0 then
  begin
    ZDecompressStream(InStream,OutStream);
  end else
  begin
    OutStream.CopyFrom(Instream,Instream.Size);
  end;
  OutStream.Position:=0;
end;

constructor TNZip.Create;
begin
  VZipType:=3;
end;

destructor TNZip.Destroy;
begin
 // nothing to destroy
end;

end.
