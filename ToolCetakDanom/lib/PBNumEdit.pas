{Author:	Poul Bak}
{}
{Copyright © 1999 - 2002 : BakSoft-Denmark (Poul Bak). All rights reserved.}
{}
{http://home11.inet.tele.dk/BakSoft/}
{Mailto: baksoft-denmark@dk2net.dk}
{}
{Component Version: 7.00.00.00}
{}
{PBNumEdit is a Delphi Edit component with Alignment, DisabledColor
 and mouse-AutoSelect-all.}
{PBNumEdit is a special Edit component for numeric values - supporting
 WYSIWYG editing, floating and fixed decimalpoint.}
{NumberFormat sets the display- and editformat (Standard, Thousands,
Scientific and Engineering). You can set max- and minValue.}
{ Note: To prevent conversion errors, the display is limited to 15 significant
 numbers though the Value (and AsFloat) property is of type Extended.}
{Supports Windows 95, 98 and NT.}
{Supports Default-Button click.}
{Supports Cancel-button click.}
{Edited by nas }

unit PBNumEdit;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls;

type
{Default: Normal format.}
{Thousands: Showing Thousand-separators.}
{Scientific: Exponential - 1 number left of decimalseparator and a 10-exponent (ex: 1.23E8).}
{Engineering: Same as Scientific except the 10-exponent is always a multiplum
of 3 (like milli, kilo, Mega etc.) and there are 1 to 3 numbers
left of the decimalseparator.}
	TNumberFormat = (Standard, Thousands, Scientific, Engineering);

{Author:	Poul Bak}
{}
{Copyright © 1999 - 2002 : BakSoft-Denmark (Poul Bak). All rights reserved.}
{}
{http://home11.inet.tele.dk/BakSoft/}
{Mailto: baksoft-denmark@dk2net.dk}
{}
{Component Version: 7.00.00.00}
{}
{PBNumEdit is a Delphi Edit component with Alignment, DisabledColor
 and mouse-AutoSelect-all.}
{PBNumEdit is a special Edit component for numeric values - supporting
 WYSIWYG editing, floating and fixed decimalpoint.}
{NumberFormat sets the display- and editformat (Standard, Thousands,
Scientific and Engineering). You can set max- and minValue.}
{ Note: To prevent conversion errors, the display is limited to 15 significant
 numbers though the Value (and AsFloat) property is of type Extended.}
{Supports Windows 95, 98 and NT.}
{Supports Default-Button click.}
{Supports Cancel-button click.}
	TPBNumEdit = class(TCustomEdit)
	private
		FAlignment: TAlignment;
		FDecimals: ShortInt;
		FEnter : Boolean;
		FInvalidEntry: TNotifyEvent;
		FMaxValue: Extended;
		FMinValue: Extended;
		FNumberFormat : TNumberFormat;
		FVersion: String;
		FDisabledColor, FEnabledColor : TColor;
                FThousandSeparator,FDecimalSeparator:char;
		function FormatText(Value: Extended): string;
		function GetAsCurrency: Currency;
		function GetAsFloat: Extended;
		function GetAsInteger: Integer;
		function GetValue: Extended;
		function Remove1000(Num : string): string;
                function NFormatFloat(Num : string): string;
		procedure DeleteKey(Key: Word);
		procedure DeleteSelection;
		procedure SetAlignment(Value: TAlignment);
		procedure SetAsCurrency(Value: Currency);
		procedure SetAsFloat(Value: Extended);
		procedure SetAsInteger(Value: Integer);
		procedure SetColor(Value : TColor);
		procedure SetDisabledColor(Value : TColor);
		procedure SetDecimals(Value: ShortInt);
		procedure SetMaxValue(Value: Extended);
		procedure SetMinValue(Value: Extended);
		procedure SetNumberFormat(Value: TNumberFormat);
		procedure SetValue(Value: Extended);
		procedure SetVersion(Value: String);
		procedure WMCut(var Message: TMessage); message WM_CUT;
		procedure WMCopy(var Message: TMessage); message WM_COPY;
		procedure WMGetDlgCode(var Msg : TWMGetDlgCode); message WM_GETDLGCODE;
		procedure WMPaste(var Message: TMessage); message WM_PASTE;
	protected
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
                procedure Change; override;
		procedure DoEnter; override;
		procedure DoExit; override;
		procedure InvalidEntry;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyPress(var Key: Char); override;
		procedure Keyup(var Key: Word; Shift: TShiftState); override;
		procedure SetEnabled(Value : Boolean); override;
		procedure Loaded; override;
	public
		constructor Create(AOwner: TComponent); override;
		procedure CreateParams(var Params: TCreateParams); override;
{Set or access the value as a currency type.}
		property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
{Set or access the value as an extended type.}
{ Note: To prevent conversion errors, the display is limited to 15 significant
numbers though the Value and AsFloat property are of type Extended and
internally calculates with up to 20 significant numbers.}
		property AsFloat: Extended read GetAsFloat write SetAsFloat;
{Set or access the value as an integer type.}
		property AsInteger: Integer read GetAsInteger write SetAsInteger;
	published
{Set Alignment to: taLeftJustify, taCenter or taRightJustify.}
{Default : taLeftJustify.}
{Supports Windows 95, 98 and NT.}
		property Alignment: TAlignment read FAlignment write SetAlignment;
{Default: True.}
{Set AutoSelect to True to select all text when you set focus:}
{Notice that when you set focus using the mouse, all text is also selected -
unlike standard Delphi components that only selects all when setting focus with <tab>.}
{When a form has a defaultbutton and you press <enter>, the click event
triggers and focus is returned to the edit control which autoselect all.}
		property AutoSelect;
		property AutoSize;
		property BorderStyle;
{The Color property sets only the enabled-color. When you disable the
edit-control the Disabled color will be used.}
		property Color : TColor read FEnabledColor write SetColor default clWindow;
{DisabledColor is the background color used when the edit-control is disabled.}
{To set the color when Enabled - use the Color property.}
		property DisabledColor : TColor read FDisabledColor
			write SetDisabledColor default clBtnFace;
{Besides standard enabling/disabling - this property also changes the background
color to either the Color or the DisabledColor property.}
		property Enabled : Boolean read GetEnabled
			write SetEnabled default True;
		property Ctl3D;
{Set Decimals to -1 if you want a floating decimalpoint with 0 - 14
decimals.}
{Set Decimals to 0 or a value up to 14 to get fixed decimals.}
{ Note: To prevent conversion errors, the display is limited to 15 significant
numbers though the Value (and AsFloat) property is of type Extended and
internally calculates with up to 20 significant numbers.}
		property Decimals: ShortInt read FDecimals write SetDecimals;
		property DragCursor;
		property DragMode;
		property Font;
		property HideSelection;
		property MaxLength;
{Set MaxValue to prevent users from entering values greater than MaxValue.}
{OnInvalidEntry triggers when the edit component looses focus.}
{When MaxValue and MinValue are both zero, they have no effect.}
		property MaxValue: Extended read FMaxValue write SetMaxValue;
{Set MinValue to prevent users from entering values less than MinValue.}
{OnInvalidEntry triggers when the edit component looses focus.}
{When MaxValue and MinValue are both zero, they have no effect.}
		property MinValue: Extended read FMinValue write SetMinValue;
{Sets the display- and editformat.}
{Standard: Normal format.}
{Thousands: Showing Thousand-separators.}
{Scientific: Exponential - 1 number left of decimalseparator and a 10-exponent
(ex: 1.23E8).}
{Engineering: Same as Scientific except the 10-exponent is always a multiplum
of 3 (like milli, kilo, Mega etc.) and there are 1 to 3 numbers
left of the decimalseparator.}
		property NumberFormat: TNumberFormat read FNumberFormat write SetNumberFormat;
		property OnChange;
		property OnClick;
		property OnDblClick;
		property OnDragDrop;
		property OnDragOver;
		property OnEndDrag;
		property OnEnter;
		property OnExit;
{Is called when the user enters a value greater than MaxValue or smaller
than MinValue. If no procedure is assigned to this event Value will simply be set to MaxValue if Value is greater than MaxValue and MinValue if Value is less than MinValue.}
		property OnInvalidEntry: TNotifyEvent read FInvalidEntry write FInvalidEntry;
		property OnKeyDown;
		property OnKeyPress;
		property OnKeyUp;
		property OnMouseDown;
		property OnMouseMove;
		property OnMouseUp;
		property OnStartDrag;
		property ParentColor;
		property ParentCtl3D;
		property ParentFont;
		property ParentShowHint;
		property PopupMenu;
		property ReadOnly;
		property ShowHint;
		property TabOrder;
		property TabStop;
{The value of the text. Set or access the displayed text through
this property.}
{ Note: To prevent conversion errors, the display is limited to 15 significant
numbers though the Value (and AsFloat) property is of type Extended and
internally calculates with up to 20 significant numbers.}
		property Value: Extended read GetValue write SetValue;
{Read only}
		property Version: String read FVersion write SetVersion stored False;
		property Visible;
	end;

procedure Register;

implementation

uses Clipbrd;

constructor TPBNumEdit.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
        FThousandSeparator:=',';
        FDecimalSeparator:='.';
	Width := 100;
	FAlignment := taRightJustify;
	FDecimals := -1;
	FEnter := False;
	FMaxValue := 0;
	FMinValue := 0;
	FNumberFormat := Standard;
	FVersion := '7.00.00.00';
        MaxLength:=18;
	Value := 0;
	Text := FormatText(Value);
	inherited Enabled := True;
	inherited Color := clWindow;
	FEnabledColor := clWindow;
	FDisabledColor := clBtnFace;

end;

procedure TPBNumEdit.Loaded;
begin
	inherited;
	if Enabled then inherited Color := FEnabledColor
	else inherited Color := FDisabledColor;
end;

procedure TPBNumEdit.CreateParams(var Params: TCreateParams);
const
	Alignments: array[TAlignment] of Word = (ES_LEFT, ES_RIGHT, ES_CENTER);
begin
	inherited CreateParams(Params);
	Params.Style := Params.Style or ES_MULTILINE or Alignments[FAlignment];
end;

procedure TPBNumEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	if (Button = mbLeft) or (ssLeft in Shift) then
	begin
		if FEnter = True then
		begin
			FEnter := False;
			if AutoSelect then SelectAll;
		end;
	end;
	inherited MouseDown(Button, Shift, X, Y);
end;

procedure TPBNumEdit.Change;
begin
	inherited Change;
	//Showmessage(Text);
        //if NumberFormat = Thousands then
        //begin
          Text := FormatText(Value);
          Selstart:=length(Text);
        //end;
end;

procedure TPBNumEdit.DoEnter;
begin
	inherited DoEnter;
	if csLButtonDown in ControlState then FEnter := True;
	if AutoSelect then SelectAll;
end;

procedure TPBNumEdit.DoExit;
begin
	//Text := FormatText(Value);
	if ((FMinValue <> 0) or (FMaxValue <> 0))
		and ((Value < FMinValue) or (Value > FMaxValue)) then InvalidEntry
	else inherited DoExit;
end;

procedure TPBNumEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
	inherited KeyDown(Key, Shift);
	FEnter := False;
	if not ReadOnly then
	begin
		if Key in [VK_DELETE, VK_BACK] then
		begin
			if SelLength > 0 then DeleteSelection
			else DeleteKey(Key);
			Key := 0;
		end;

	end;
end;

procedure TPBNumEdit.KeyPress(var Key: Char);
var
	P, D, E : Integer;
	N, NE : Boolean;
begin
	inherited KeyPress(Key);
        if length(text)>maxlength then
          key:=#0;
	if ReadOnly or (Key in [#3, #22, #24]) then exit;
       //	if not (Key in ['0'..'9', DecimalSeparator, '-', 'e', 'E'])
        if not (Key in ['0'..'9', FDecimalSeparator, '-'])
		or ((Key = FDecimalSeparator) and (FDecimals = 0))or (length(text)>MaxLength) then
	begin
		MessageBeep(0);
		Key := #0;
		Exit;
	end;
	P := SelStart;
	D := pos(FDecimalSeparator, Text);
	E := pos('E', Text);
	if Key = 'e' then Key := 'E';
	if Key in [FDecimalSeparator, 'E'] then SelLength := 0
	else DeleteSelection;
	N := (Text[1] = '-');
	NE := (pos('-', copy(Text, E + 1, length(Text) - E)) <> 0) and (E <> 0);
	if N and (SelStart = 0) then SelStart := 1;
	if NE and (Selstart = E + 1) then SelStart := SelStart + 1;
	if Key = '-' then
	begin
		if (P < E) or (E = 0) then
		begin
			if not N then
			begin
				Text := '-' + Text;
				SelStart := P + 1;
			end
			else
			begin
				Text := Copy(Text, 2, Length(Text) - 1);
				SelStart := P - 1;
			end;
		end
		else
		begin
			if not NE then
			begin
				Text := copy(Text, 1, E) + '-' + copy(Text, E + 1, Length(Text) - E);
				SelStart := P + 1;
			end
			else
			begin
				Text := copy(Text, 1, E) + copy(Text, E + 2, Length(Text) - E - 1);
				SelStart := P - 1;
			end;
		end;
		Key := #0;
		exit;
	end;
	if Key = FDecimalSeparator then
	begin
		if D <> 0 then
		begin
			Selstart := D;
			Key := #0;
		end
		else if FDecimals < 0 then
		begin
			if E <> 0 then Selstart := E - 1
			else Selstart := Length(Text);
		end;
		exit;
	end
	else if Key = 'E' then
	begin
		if E = 0 then SelStart := Length(Text)
		else
		begin
			SelStart := E;
			Key := #0;
		end;
		Exit;
	end;
	if (SelStart <= 2) and (Copy(Text, 2, 1) = '0') and N then
	begin
		SelStart := 1;
		SelLength := 1;
	end
	else if (SelStart <= 1) and (Copy(Text, 1, 1) = '0') then
	begin
		SelStart := 0;
		SelLength := 1;
	end
	else if (SelStart = E) and (E <> 0) and (copy(Text,E + 1, 1) = '0')
		then SelLength := 1
	else if (SelStart >= E) and (E <> 0) then
	begin
		if  Abs(StrToInt(Copy(Text, E + 1, SelStart - E) + Key + Copy(Text, SelStart + 1, 99))) > 4932 then
		begin
			MessageBeep(0);
			Key := #0;
		end;
	end
	else if FDecimals > 0 then
	begin
		if (SelStart = D + FDecimals) then
		begin
			MessageBeep(0);
			Key := #0;
		end
		else if SelStart >= D then SelLength := 1
		else if SelStart < D - 1 then SelLength := 0;
	end;
        //Text := FormatText(Value);
        //Selstart:=length(Text);
end;

procedure TPBNumEdit.Keyup(var Key: Word; Shift: TShiftState);
var
	Numsep, NumSep0, SelStart0, X, D, N, N0 : integer;
	Text0 : string;
begin
	inherited KeyUp(Key, Shift);
	if (SelLength > 0) then exit;
	if NumberFormat <> Thousands then exit;
	D := pos(FDecimalSeparator, Text);
	SelStart0 := SelStart;
	NumSep := 0;
	NumSep0 := 0;
	Text0 := FormatText(AsFloat);
	for X := 1 to length(Text0) do
		if Text0[X] = FThousandSeparator then inc(NumSep0);
	for X := 1 to length(Text) do
		if Text[X] = FThousandSeparator then inc(NumSep);
	N := pos(FThousandSeparator, Text);
	N0 := pos(FThousandSeparator, Text0);
	if (NumSep <> NumSep0) or (N <> N0) or (Key in [32, 13]) then
	begin
		Text := Text0;
		Selstart := SelStart0 + NumSep0 - NumSep;
		if (pos(FDecimalSeparator, Text) <> 0) and (D = 0) then Selstart := Selstart + 1
		else if (D <> 0) and (pos(FDecimalSeparator, Text) = 0) then Selstart := Selstart - 1;
		if Copy(Text, Selstart + 1, 1) = FThousandSeparator then Selstart := Selstart + 1;
	end;


end;

function TPBNumEdit.GetAsCurrency: Currency;
begin
	Result := StrToCurr(Remove1000(Text));
end;
/////////////////////////////////////////////////////////////////////////////////////////////////////
function TPBNumEdit.GetAsFloat: Extended;
var
  Tmp:String;
begin
        Tmp:= Remove1000(Text);
	Result := StrToFloat(Remove1000(Text));
end;

function TPBNumEdit.GetAsInteger: Integer;
begin
	Result := Trunc(StrToFloat(Remove1000(Text)));
end;

function TPBNumEdit.GetValue: Extended;
begin
	Result := StrToFloat(Remove1000(Text));
end;

procedure TPBNumEdit.SetAsCurrency(Value: Currency);
begin
	if Text <> FormatText(Value) then Text := FormatText(Value);
end;

procedure TPBNumEdit.SetAsFloat(Value: Extended);
begin
	if Text <> FormatText(Value) then Text := FormatText(Value);
end;

procedure TPBNumEdit.SetAsInteger(Value: Integer);
begin
	if Text <> FormatText(Value) then Text := FormatText(Value);
end;

procedure TPBNumEdit.SetAlignment(Value: TAlignment);
var
	SelSt, SelLe : integer;
begin
	if FAlignment <> Value then
	begin
		SelSt := SelStart;
		SelLe := SelLength;
		FAlignment := Value;
		RecreateWnd;
		SelStart := SelSt;
		SelLength := SelLe;
	end;
end;

procedure TPBNumEdit.SetColor(Value : TColor);
begin
	if FEnabledColor <> Value then
	begin
		FEnabledColor := Value;
		if Enabled then inherited Color := Value;
	end;
end;

procedure TPBNumEdit.SetDisabledColor(Value : TColor);
begin
	if FDisabledColor <> Value then
	begin
		FDisabledColor := Value;
		if (not Enabled) then inherited Color := Value;
	end;
end;

procedure TPBNumEdit.SetEnabled(Value : Boolean);
begin
	inherited;
	if Enabled then inherited Color := FEnabledColor
	else inherited Color := FDisabledColor;
end;

procedure TPBNumEdit.SetDecimals(Value: ShortInt);
var Value0 : ShortInt;
begin
	Value0 := Value;
	if FDecimals <> Value0 then
	begin
		if Value0 < 0 then Value0 := -1
		else if Value0 > 14 then Value0 := 14;
		if (Value0 > MaxLength - 2) and (MaxLength > 0) then Value0 := maxlength - 2;
		FDecimals := Value0;
		Text := FormatText(AsFloat);
	end;
end;

procedure TPBNumEdit.SetMaxValue(Value: Extended);
begin
	if (FMaxValue <> Value) and (Value >= FminValue) then
	begin
		FMaxValue := Value;
	end;
end;

procedure TPBNumEdit.SetMinValue(Value: Extended);
begin
	if (FMinValue <> Value) and (Value <= FmaxValue) then
	begin
		FMinValue := Value;
	end;
end;

procedure TPBNumEdit.SetValue(Value: Extended);
begin
	if csDesigning in ComponentState then
	begin
		if (Value > FMaxValue) and ((FMaxValue <> 0) or (FMinValue <> 0)) then InvalidEntry;
		if (Value < FMinValue) and ((FMaxValue <> 0) or (FMinValue <> 0)) then InvalidEntry;
	end;
	if Text <> FormatText(Value) then Text := FormatText(Value);
end;

procedure TPBNumEdit.DeleteKey(Key: Word);
var
	P, D, E: Integer;
	N: Boolean;
	str0 : string;
begin
	D := pos(FDecimalSeparator, Text);
	E := pos('E', Text);
	if E = 0 then E := length(Text) + 1;
	if Key = VK_DELETE then
	begin
		P := SelStart + 1;
		if P > Length(Text) then Exit;
		if Text[P] in [FThousandSeparator, FDecimalSeparator, 'E'] then inc(P);
	end
	else
	begin
		P := SelStart;
		if P = 0 then Exit;
		if Text[P] in [FThousandSeparator, FDecimalSeparator, 'E'] then dec(P);
	end;
	N := (Pos('-', Text) > 0);
	if (P = 0) or (P > Length(Text)) then exit;
	str0 := '';
	if (P > D) and (D <> 0) and ((P < E) or (E = 0)) then
	begin
		if FDecimals > 0 then str0 := '0';
		Text := Copy(Text, 1, P - 1) + Copy(Text, P + 1,E - P - 1)
			+ str0 + Copy(Text, E, length(Text) - E + 1);
		SelStart := P - 1;
	end
	else if (P = 1) and N then
	begin
		Text := Copy(Text, 2, Length(Text) - 1);
		if Text = '' then Text := '0';
	end
	else if (P = 1) and ((P = D - 1) or (P = E - 1) or (P = length(Text))) then
	begin
		Text := '0' + Copy(Text, 2, Length(Text) - 1);
		SelStart := 1;
		if N then Text := '-' + Text;
	end
	else if P > 0 then
	begin
		Text := Copy(Text, 1, P - 1) + Copy(Text, P + 1, Length(Text) - P);
		SelStart := P - 1;
		if ((FNumberFormat = Scientific) or (FNumberFormat = Engineering))
			and (Text[length(Text)] = 'E') then Text := Text + '0';
	end;
end;

procedure TPBNumEdit.DeleteSelection;
var
	X, Y, Z: Integer;
begin
	if SelLength = 0 then exit;
	if SelText = Text then
	begin
		Text := FormatText(0);
		exit;
	end;
	Y := Length(Remove1000(SelText));
	if pos(FDecimalSeparator, SelText) <> 0 then dec(Y);
	Z := Length(SelText);
	SelStart := SelStart + Z;
	for X:= 1 to Y do
	begin
		DeleteKey(VK_BACK);
	end;
end;

procedure TPBNumEdit.InvalidEntry;
begin
	if not (csLoading in ComponentState) then
	begin
		if Assigned(FInvalidEntry) then FInvalidEntry(Self)
		else
		begin
			if Value < FMinValue then Value := FMinValue
			else if Value > FMaxValue then Value := FMaxValue;
			MessageBeep(0);
			if CanFocus and (not (csDesigning in ComponentState)) then SetFocus;
		end;
	end;
end;

procedure TPBNumEdit.SetVersion(Value: String);
begin
	{ Read only! }
end;

procedure TPBNumEdit.WMCopy(var Message: TMessage);
begin
	ClipBoard.AsText := Remove1000(Seltext);
end;

procedure TPBNumEdit.WMCut(var Message: TMessage);
begin
	ClipBoard.AsText := Remove1000(Seltext);
	DeleteSelection;
end;

procedure TPBNumEdit.WMPaste(var Message: TMessage);
var
	X: integer;
	S: String;
	W: Word;
begin
	DeleteSelection;
	S := Clipboard.AsText;
	for X := 1 to Length(S) do
	begin
		W := Ord(S[X]);
		Perform(WM_CHAR, W, 0);
	end;
end;

procedure TPBNumEdit.SetNumberFormat(Value: TNumberFormat);
begin
	if FNumberFormat <> Value then FNumberFormat := Value;
	Text := FormatText(AsFloat);
end;

function TPBNumEdit.Remove1000(Num : string): string;
var
	t : integer;
begin
	Result := '';
	for t :=1 to length(Num) do
	begin
		if Num[t] <> FThousandSeparator then Result := Result + Num[t];
	end;
	if Result = '' then Result := '0';
	if Result = '-' then Result := '-0';
end;
//////////tambahan nas
function TPBNumEdit.NFormatFloat(Num : string): string;
var
  OutStr:String;
  I,C,L:Integer;
begin
  OutStr:='';
  C:=0;
  L:= length(Num);
  if FNumberFormat = Thousands then
  begin
    for I:=L downto 1  do
    begin
      OutStr:=Num[I]+OutStr;
      C:=C+1;
      if (C mod 3=0) and not((C=L) or((C=L-1) and (Num[1]='-')))then
         OutStr:=FThousandSeparator+OutStr;
  end;
  end else
     OutStr:=Num;
  Result:=OutStr;
end;

function TPBNumEdit.FormatText(Value: Extended) : string;
var
	e0, E, D, NN, t, FD : integer;
	a : extended;
	Formatmask : string;
begin
	if (FNumberFormat = Engineering) and (Value <> 0) then
	begin
		e0 := trunc(ln(abs(Value)) / ln(10) / 3) * 3;
		Result := 'E' + inttostr(e0);
		a := Value / StrToFloat('1' + Result);
		FD := 14;
		if a > 9 then dec(FD);
		if a > 99 then dec(FD);
		if (FD > FDecimals) and (FDecimals <> -1) then FD := FDecimals;
		if FDecimals < 0 then Result := formatfloat('0'+FDecimalSeparator + StringOfChar('#',FD), a) + Result
		else if FDecimals = 0 then Result := formatfloat('0', a) + Result
		else Result := formatfloat('0'+FDecimalSeparator + StringOfChar('0',FD), a) + Result;
	end
	else
	begin
		FormatMask := '0';
		//if FNumberFormat = Thousands then FormatMask := ',' + FormatMask;
                if FNumberFormat = Thousands then FormatMask := FThousandSeparator + FormatMask;
		//if FDecimals > 0 then FormatMask := FormatMask + '.' + StringOfChar('0', FDecimals)
                if FDecimals > 0 then FormatMask := FormatMask + FDecimalSeparator + StringOfChar('0', FDecimals)
		//else if FDecimals < 0 then FormatMask := FormatMask + '.' + StringOfChar('#', 14);
		//if FNumberFormat > Thousands then FormatMask := FormatMask + 'E-';
                else if FDecimals < 0 then FormatMask := FormatMask + FDecimalSeparator + StringOfChar('#', 14);
		if FNumberFormat > Thousands then FormatMask := FormatMask + 'E-';

		//Result := FormatFloat(FormatMask, Value);
                Result:=NFormatFloat(Floattostr(Value));
		E := pos('E',Result);
		if E = 0 then
		begin
			D := pos(FDecimalSeparator, Result);
			if (D <> 0) then
			begin
				{NN := 0;
				for t := 1 to D do if (Result[t] in ['0'..'9'] = True) then inc(NN);
				if (FDecimals = -1) then
				begin
					if FNumberFormat = Thousands then Result := FormatFloat(',0.' + StringOfChar('#',15 - NN),Value)
					else if FDecimals <> -1 then Result := FormatFloat('0.' + StringOfChar('#',15 - NN),Value);
				end
				else if (FDecimals > 15 - NN) then
				begin
					if FNumberFormat = Thousands then Result := FormatFloat(',0.' + StringOfChar('0',15 - NN),Value)
					else if FDecimals <> -1 then Result := FormatFloat('0.' + StringOfChar('0',15 - NN),Value);
					Result := Result + StringOfChar('0', Fdecimals -15 + NN);
				end;}
                                NN := 0;
				for t := 1 to D do if (Result[t] in ['0'..'9'] = True) then inc(NN);
				if (FDecimals = -1) then
				begin
					if FNumberFormat = Thousands then Result := FormatFloat(FThousandSeparator+'0'+FDecimalSeparator + StringOfChar('#',18 - NN),Value)
					else if FDecimals <> -1 then Result := FormatFloat('0'+FDecimalSeparator + StringOfChar('#',18 - NN),Value);
				end
				else if (FDecimals > 15 - NN) then
				begin
					if FNumberFormat = Thousands then Result := FormatFloat(FThousandSeparator+'0'+FDecimalSeparator + StringOfChar('0',18 - NN),Value)
					else if FDecimals <> -1 then Result := FormatFloat('0'+FDecimalSeparator + StringOfChar('0',18 - NN),Value);
					Result := Result + StringOfChar('0', Fdecimals -18 + NN);
				end;
			end;
		end;
	end;
end;

procedure TPBNumEdit.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
	Msg.Result := DLGC_WANTCHARS or DLGC_WANTARROWS;
end;

procedure Register;
begin
	RegisterComponents('NEdit', [TPBNumEdit]);
end;

end.
