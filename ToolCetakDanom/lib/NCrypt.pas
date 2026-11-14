unit NCrypt;
{
   Modul        : NCrypt
   Deskripsi    : Modul Ini berisi kelas TNHash dan TNCipher untuk hash,
                  enkripsi dan dekripsi data
   Autor        : Nasruddin M.
   E-Mail       : Nas@Posindonesia.co.id
   Versi        : 1.00
   Tanggal      : 21 Oktober 2004
   Library lain :
     1. Md5 yang tidak diketahui siapa yang membuat
     2. DCPcrypt v2.0 oleh David Barton (crypto@cityinthesky.co.uk)
   Feature      :
   - Hash hanya MD5
   - Chiper :
     0 - Tanpa ENcrypt
     1 - Bluefish
     2 - TwoFish
     3 - 3Des
     4 - RC4
}

interface

uses
  SysUtils,Classes, DCPcrypt2, DCPrc4, DCPsha1, DCPblockciphers,
  DCPblowfish, DCPtwofish, DCPdes, Md5;

Type
  TNHash = class
    private
      VHashType:String;
      procedure SetHashType(const Value :String);
    protected

    public
      property HashType:String read VHashType write SetHashType;
      function GetHash(const value:String):String;
      constructor Create;
      destructor Destroy;override;
  end;

  TNCipher = class
    private
      VCipherType:Integer;
      VKey:String;
      procedure SetCipherType(const Value :Integer);
      procedure SetKey(const Value :String);
    protected

    public
      property CipherType:Integer read VCipherType write SetCipherType;
      property Key:String read VKey write SetKey;
      function GetEnCrypt(const value:String):String;
      function GetDeCrypt(const value:String):String;
      procedure GetEnCryptStream(instream,outstream:Tstream);
      procedure GetDeCryptStream(instream,outstream:Tstream);
      constructor Create;
      destructor Destroy;override;
  end;
  NBlueFish= TDCP_blowfish;
  NRc4= TDCP_rc4;
  NTwoFish= TDCP_TwoFish;
  N3Des=TDCP_3Des;
  NSha1=TDCP_sha1;
  
implementation

////// TNHASH ///////
procedure TNHash.SetHashType(const value:String);
begin
   VHashType:= UpperCase(value);
end;

function TNHash.GetHash(const value:String):String;
begin
   if VHashType='MD5' then
     Result:=MD5Print(MD5String(value));
end;

constructor TNHash.Create;
begin
  VHashType:='MD5';
end;

destructor TNHash.Destroy;
begin
 // nothing to destroy
end;

/////// TNCIPHER //////
procedure TNCipher.SetCipherType(const value:Integer);
begin
   VCipherType:=value;
end;

procedure TNCipher.SetKey(const value:String);
begin
   VKey:=value;
end;

function TNCipher.GetEnCrypt(const value:String):String;
begin
   if VCipherType=0 then
   begin
      Result:=value;
   end else
   if VCipherType=1 then
   begin
      With NBlueFish.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         Result:=EncryptString(value);
         Burn;
         Free;
      end;
   end else
   if VCipherType=2 then
   begin
      With NTWOFISH.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         Result:=EncryptString(value);
         Burn;
         Free;
      end;
   end else
   if VCipherType=3 then
   begin
      With N3DES.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         Result:=EncryptString(value);
         Burn;
         Free;
      end;
   end else
   if VCipherType=4 then
   begin
      With NRC4.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         Result:=EncryptString(value);
         Burn;
         Free;
      end;
   end;
end;


function TNCipher.GetDeCrypt(const value:String):String;
begin
   if VCipherType=0 then
   begin
      Result:=value;
   end else
   if VCipherType=1 then
   begin
      With NBlueFish.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         Result:=DecryptString(value);
         Burn;
         Free;
      end;
   end else
   if VCipherType=2 then
   begin
      With NTWOFISH.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         Result:=DecryptString(value);
         Burn;
         Free;
      end;
   end else
   if VCipherType=3 then
   begin
      With N3DES.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         Result:=DecryptString(value);
         Burn;
         Free;
      end;
   end else
   if VCipherType=4 then
   begin
      With NRC4.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         Result:=DecryptString(value);
         Burn;
         Free;
      end;
   end;
end;

procedure TNCipher.GetEnCryptStream(inStream,outStream:Tstream);
begin
   inStream.Position:=0;
   if VCipherType=0 then
   begin
      OutStream.CopyFrom(inStream,inStream.Size);
   end else
   if VCipherType=1 then
   begin
      With NBlueFish.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         EncryptStream(inStream,outStream,inStream.Size);
         Burn;
         Free;
      end;
   end else
   if VCipherType=2 then
   begin
      With NTWOFISH.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         EncryptStream(inStream,outStream,inStream.Size);
         Burn;
         Free;
      end;
   end else
   if VCipherType=3 then
   begin
      With N3DES.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         EncryptStream(inStream,outStream,inStream.Size);
         Burn;
         Free;
      end;
   end else
   if VCipherType=4 then
   begin
      With NRC4.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         EncryptStream(inStream,outStream,inStream.Size);
         Burn;
         Free;
      end;
   end;
   outStream.Position:=0
end;

procedure TNCipher.GetDeCryptStream(inStream,outStream:Tstream);
begin
   inStream.Position:=0;
   if VCipherType=0 then
   begin
      outStream.CopyFrom(inStream,inStream.Size);
   end else
   if VCipherType=1 then
   begin
      With NBlueFish.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         DecryptStream(inStream,outStream,inStream.Size);
         Burn;
         Free;
      end;
   end else
   if VCipherType=2 then
   begin
      With NTWOFISH.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         DecryptStream(inStream,outStream,inStream.Size);
         Burn;
         Free;
      end;
   end else
   if VCipherType=3 then
   begin
      With N3DES.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         DecryptStream(inStream,outStream,inStream.Size);
         Burn;
         Free;
      end;
   end else
   if VCipherType=4 then
   begin
      With NRC4.Create(nil) do
      begin
         InitStr(VKey,NSha1);
         DecryptStream(inStream,outStream,inStream.Size);
         Burn;
         Free;
      end;
   end;
   outStream.Position:=0;
end;


constructor TNCipher.Create;
var
  Hash:TNHash;
begin
  VCipherType:=1;
  Hash:=TNHash.Create;
  DateSeparator:='/';
  //VKey:=Hash.GetHash(FormatDateTime('MM/dd/yyyy',now)+'NABFA MASNAS 1973'+
  //      '!@#!we$%^&asdhgkasdlkksduatyerweqQEERETY NJJASLD;SA12642138909-6'+
  //      '0=-\!@#!!$$%^%9)*)~!)*<>.,?/":#@!$%^&*');
  VKey:=Hash.GetHash('!@#!we$%^&asdhgkasdlkksduatyerweqQEERETY NJJASLD;SA12642138909-6'+
                     '0=-\!@#!!$$%^%9)*)~!)*<>.,?/":#@!$%^&*{}{{{":?><ZXC@#!%^&*JHDYDL:');
  FreeAndNil(Hash);
end;

destructor TNCipher.Destroy;
begin
 // nothing to destroy
end;

end.
