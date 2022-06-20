unit U_JSEncode;

{
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.

  Copyright (c) Martijn Coppoolse <https://sourceforge.net/u/vor0nwe>
  Revisions copyright (c) 2022 Robert Di Pardo <dipardo.r@gmail.com>
}

interface
uses
  Classes,
  NppSimpleObjects;

type
  TEntityReplacementScope = (ersSelection, ersDocument, ersAllDocuments);

procedure EncodeJS(Scope: TEntityReplacementScope = ersSelection);
function  DecodeJS(Scope: TEntityReplacementScope = ersSelection): Integer;

////////////////////////////////////////////////////////////////////////////////////////////////////
implementation
uses
  Windows,
  SysUtils,
  NppPlugin;

{ ------------------------------------------------------------------------------------------------ }
type
  TTextRange = NppSimpleObjects.TTextRange;
  TConversionMethod = function(var Text: WideString): Integer;
  TRangeConversionMethod = function(const TextRange: TTextRange): Integer;

{ ------------------------------------------------------------------------------------------------ }
function PerformConversion(Conversion: TRangeConversionMethod; Scope: TEntityReplacementScope = ersSelection): Integer;
var
  npp: TApplication;
  doc: TActiveDocument;
  DocIndex: Integer;
  Range: TTextRange;
begin
  npp := GetApplication();

  Result := 0;
  case Scope of
    ersDocument: begin
      doc := npp.ActiveDocument;
      Range := doc.GetRange();
      try
        Result := Conversion(Range);
      finally
        Range.Free;
      end;
    end;

    ersAllDocuments: begin
      for DocIndex := 0 to npp.Documents.Count - 1 do begin
        doc := npp.Documents[DocIndex].Activate;
        Range := doc.GetRange();
        Result := Conversion(Range);
      end;
    end;

    else begin // ersSelection
      doc := npp.ActiveDocument;
      Range := doc.Selection;
      Result := Conversion(Range);
    end;
  end{case};
end {PerformConversion};

{ ------------------------------------------------------------------------------------------------ }
function DoEncodeJS(var Text: WideString): Integer; overload;
var
  CharIndex: Cardinal;
  CharCode: Cardinal;
  EntitiesReplaced: integer;
begin
  EntitiesReplaced := 0;

  for CharIndex := Length(Text) downto 1 do begin
    CharCode := Ord(Text[CharIndex]);
    if CharCode > 127 then begin
      Text := Copy(Text, 1, CharIndex - 1)
              + WideFormat('\u%s', [IntToHex(CharCode, 4)])
              + Copy(Text, CharIndex + 1);
      Inc(EntitiesReplaced);
    end;
  end;
  Result := EntitiesReplaced;
end {DoEncodeJS};

{ ------------------------------------------------------------------------------------------------ }
function DoEncodeJS(const Range: TTextRange): Integer; overload;
var
  Text: WideString;
begin
  Text := Range.Text;
  Result := DoEncodeJS(Text);
  if Result > 0 then begin
    Range.Text := Text;
  end;
end{DoEncodeJS};

{ ------------------------------------------------------------------------------------------------ }
procedure EncodeJS(Scope: TEntityReplacementScope = ersSelection);
begin
  PerformConversion(DoEncodeJS, Scope);
end{EncodeJS};

{ ------------------------------------------------------------------------------------------------ }
function DecodeJS(Scope: TEntityReplacementScope = ersSelection): Integer;
var
  npp: TApplication;
  doc: TActiveDocument;
  Target, Match: TTextRange;
  NewStart, NewEnd: Cardinal;
begin
  Result := 0;

  npp := GetApplication();
  doc := npp.ActiveDocument;

  Target := TTextRange.Create(doc, doc.Selection.StartPos, doc.Selection.EndPos);
  Match := TTextRange.Create(doc);
  try
    repeat
      doc.Find('\\u[0-9A-F][0-9A-F][0-9A-F][0-9A-F]', Match, SCFIND_REGEXP, Target.StartPos, Target.EndPos);
      if Match.Length <> 0 then begin
        // Adjust the target already
        Target.StartPos := Match.StartPos + 1;

        // replace this match's text by the appropriate Unicode character
        Match.Text := WideChar(StrToInt(Format('$%s', [Copy(Match.Text, 3, 4)])));

        Inc(Result);
      end;
    until Match.Length = 0;

    if ((Result > 1) and (Target.StartPos > 0)) then
    begin
      case GetACP of
        65001:
          begin
            // use a wider offset so we don't land in between high-low bytes
            if Target.StartPos > 1 then
              NewStart := 2
            else
              NewStart := 1;
            NewEnd := 2;
          end;
        else
        begin
          NewStart := 1;
          NewEnd := 1;
        end;
      end;
      doc.SendMessage(SCI_SETSEL, doc.Selection.StartPos - NewStart, doc.Selection.EndPos + NewEnd);
    end;
  finally
    Target.Free;
    Match.Free;
  end;
//DebugWrite('DecodeJS', Format('Result: %d replacements', [Result]));
end{DecodeJS};


////////////////////////////////////////////////////////////////////////////////////////////////////
initialization

finalization

end.

