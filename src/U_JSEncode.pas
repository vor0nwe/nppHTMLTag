unit U_JSEncode;

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
  SysUtils, Windows,
//  L_DebugLogger,
  NppPluginConstants, SciSupport;

{ ------------------------------------------------------------------------------------------------ }
type
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
  CharIndex: integer;
  CharCode: SmallInt;
  EntitiesReplaced: integer;
begin
  EntitiesReplaced := 0;

  for CharIndex := Length(Text) downto 1 do begin
    CharCode := Ord(Text[CharIndex]);
    if CharCode > 127 then begin
      Text := Copy(Text, 1, CharIndex - 1)
              + '\u' + IntToHex(CharCode, 4)
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
begin
  Result := 0;

  npp := GetApplication();
  doc := npp.ActiveDocument;

  Target := TTextRange.Create(doc, doc.Selection.StartPos, doc.Selection.EndPos);
  try
    repeat
      Match := doc.Find('\\u[0-9A-F][0-9A-F][0-9A-F][0-9A-F]', SCFIND_REGEXP, Target);
      if Assigned(Match) then begin
        // Adjust the target already
        Target.StartPos := Match.StartPos + 1;
        Target.EndPos := Target.EndPos - Length(Match.Text) + 2;

        // replace this match's text by the appropriate Unicode character
        Match.Text := Char(StrToInt('$' + Copy(Match.Text, 3, 4)));

        Inc(Result);
      end;
    until not Assigned(Match);
  finally
    Target.Free;
  end;
//DebugWrite('DecodeJS', Format('Result: %d replacements', [Result]));
end{DecodeJS};


////////////////////////////////////////////////////////////////////////////////////////////////////
initialization

finalization

end.

