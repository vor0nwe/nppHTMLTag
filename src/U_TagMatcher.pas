unit U_TagMatcher;

(*
  Port from the tag matching code in Notepad++ itself
   taken from http://svn.tuxfamily.org/viewvc.cgi/notepadplus_repository/trunk/PowerEditor/src/ScitillaComponent/xmlMatchedTagsHighlighter.cpp?revision=1123&view=markup
   on 2015-01-16
   by Martijn Coppoolse
*)

interface
uses
  NppSimpleObjects;

type
  TTagMatcher = class
  type
    TStartFinish = record
      start: integer;
      finish: integer;
    end;
    TStartFinishes = array of TStartFinish;

    TXmlMatchedTagsPos = record
      OpenStart: integer;
      NameEnd: integer;
      OpenEnd: integer;
      CloseStart: integer;
      CloseEnd: integer;
    end;

    TFindResult = record
      success: boolean;
      start: integer;
      finish: integer;
    end;
  private
    FDoc: TActiveDocument;

    function findText(const Text: string; const start, finish, options: integer): TFindResult;

    function isWhitespace(const C: char): boolean;
    function getAttributesPos(const start, finish: integer): TStartFinishes;
    function getXmlMatchedTagsPos(var xmlTags: TXmlMatchedTagsPos): boolean;
    function findOpenTag(const tagName: string; const start, finish: integer): TFindResult;
    function findCloseAngle(const startPos, endPos: integer): integer;
    function findCloseTag(const tagName: string; const start, finish: integer): TFindResult;
  public
    constructor Create(const Document: TActiveDocument);

    function MatchTags(const Highlight: Boolean): boolean; overload;
  public
    class function MatchTags(const Document: TActiveDocument; const Highlight: Boolean): boolean; overload;
  end;

implementation
uses
  Character, StrUtils,
  NppPluginConstants;



{ ================================================================================================ }
{ TTagMatcher }

{ ------------------------------------------------------------------------------------------------ }
constructor TTagMatcher.Create(const Document: TActiveDocument);
begin
  FDoc := Document;
end {TTagMatcher.Create};

{ ------------------------------------------------------------------------------------------------ }
{$MESSAGE WARN 'TODO: verify that this function does what it does in notepad++’s code'}
function TTagMatcher.findText(const Text: string; const start, finish, options: integer): TFindResult;
var
  TR: TTextRange;
begin
  TR := FDoc.Find(Text, options, start, finish);
  Result.success := Assigned(TR);
  try
    if Result.success then begin
      Result.start := TR.StartPos;
      Result.finish := TR.EndPos;
    end else begin
      Result.start := TR.StartPos;
      Result.finish := TR.EndPos;
    end;
  finally
    TR.Free;
  end;
end {TTagMatcher.findText};

{ ------------------------------------------------------------------------------------------------ }
function TTagMatcher.findCloseAngle(const startPos, endPos: integer): integer;
begin
(*
453	        // We'll search for the next '>', and check it's not in an attribute using the style
454	        FindResult closeAngle;
455
456	        bool isValidClose;
457	        int returnPosition = -1;
458
459	        // Only search forwards
460	        if (startPosition > endPosition)
461	        {
462	                int temp = endPosition;
463	                endPosition = startPosition;
464	                startPosition = temp;
465	        }
466
467	        do
468	        {
469	                isValidClose = false;
470
471	                closeAngle = findText(">", startPosition, endPosition);
472	                if (closeAngle.success)
473	                {
474	                        int style = _pEditView->execute(SCI_GETSTYLEAT, closeAngle.start);
475	                        // As long as we're not in an attribute (  <TAGNAME attrib="val>ue"> is VALID XML. )
476	                        if (style != SCE_H_DOUBLESTRING && style != SCE_H_SINGLESTRING)
477	                        {
478	                                returnPosition = closeAngle.start;
479	                                isValidClose = true;
480	                        }
481	                        else
482	                        {
483	                                startPosition = closeAngle.end;
484	                        }
485	                }
486
487	        } while (closeAngle.success && isValidClose == false);
488
489	        return returnPosition;
*)
end {TTagMatcher.findCloseAngle};

{ ------------------------------------------------------------------------------------------------ }
function TTagMatcher.findCloseTag(const tagName: string; const start, finish: integer): TFindResult;
begin
(*
495	        std::string search("</");
496	        search.append(tagName);
497	        FindResult closeTagFound;
498	        closeTagFound.success = false;
499	        FindResult result;
500	        int nextChar;
501	        int styleAt;
502	        int searchStart = start;
503	        int searchEnd = end;
504	        bool forwardSearch = (start < end);
505	        bool validCloseTag;
506	        do
507	        {
508	                validCloseTag = false;
509	                result = findText(search.c_str(), searchStart, searchEnd, 0);
510	                if (result.success)
511	                {
512	                        nextChar = _pEditView->execute(SCI_GETCHARAT, result.end);
513	                        styleAt = _pEditView->execute(SCI_GETSTYLEAT, result.start);
514
515	                        // Setup the parameters for the next search, if there is one.
516	                        if (forwardSearch)
517	                        {
518	                                searchStart = result.end + 1;
519	                        }
520	                        else
521	                        {
522	                                searchStart = result.start - 1;
523	                        }
524
525	                        if (styleAt != SCE_H_CDATA && styleAt != SCE_H_SINGLESTRING && styleAt != SCE_H_DOUBLESTRING) // If what we found was in CDATA section, it's not a valid tag.
526	                        {
527	                                // Common case - '>' follows the tag name directly
528	                                if (nextChar == '>')
529	                                {
530	                                        validCloseTag = true;
531	                                        closeTagFound.start = result.start;
532	                                        closeTagFound.end = result.end;
533	                                        closeTagFound.success = true;
534	                                }
535	                                else if (isWhitespace(nextChar))  // Otherwise, if it's whitespace, then allow whitespace until a '>' - any other character is invalid.
536	                                {
537	                                        int whitespacePoint = result.end;
538	                                        do
539	                                        {
540	                                                ++whitespacePoint;
541	                                                nextChar = _pEditView->execute(SCI_GETCHARAT, whitespacePoint);
542
543	                                        } while(isWhitespace(nextChar));
544
545	                                        if (nextChar == '>')
546	                                        {
547	                                                validCloseTag = true;
548	                                                closeTagFound.start = result.start;
549	                                                closeTagFound.end = whitespacePoint;
550	                                                closeTagFound.success = true;
551	                                        }
552	                                }
553	                        }
554	                }
555
556	        } while (result.success && !validCloseTag);
557
558	        return closeTagFound;
*)
end {TTagMatcher.findCloseTag};

{ ------------------------------------------------------------------------------------------------ }
function TTagMatcher.findOpenTag(const tagName: string; const start, finish: integer): TFindResult;
begin
(*
388	        std::string search("<");
389	        search.append(tagName);
390	        FindResult openTagFound;
391	        openTagFound.success = false;
392	        FindResult result;
393	        int nextChar = 0;
394	        int styleAt;
395	        int searchStart = start;
396	        int searchEnd = end;
397	        bool forwardSearch = (start < end);
398	        do
399	        {
400
401	                result = findText(search.c_str(), searchStart, searchEnd, 0);
402	                if (result.success)
403	                {
404	                        nextChar = _pEditView->execute(SCI_GETCHARAT, result.end);
405	                        styleAt = _pEditView->execute(SCI_GETSTYLEAT, result.start);
406	                        if (styleAt != SCE_H_CDATA && styleAt != SCE_H_DOUBLESTRING && styleAt != SCE_H_SINGLESTRING)
407	                        {
408	                                // We've got an open tag for this tag name (i.e. nextChar was space or '>')
409	                                // Now we need to find the end of the start tag.
410
411	                                // Common case, the tag is an empty tag with no whitespace. e.g. <TAGNAME>
412	                                if (nextChar == '>')
413	                                {
414	                                        openTagFound.end = result.end;
415	                                        openTagFound.success = true;
416	                                }
417	                                else if (isWhitespace(nextChar))
418	                                {
419	                                        int closeAnglePosition = findCloseAngle(result.end, forwardSearch ? end : start);
420	                                        if (-1 != closeAnglePosition && '/' != _pEditView->execute(SCI_GETCHARAT, closeAnglePosition - 1))
421	                                        {
422	                                                openTagFound.end = closeAnglePosition;
423	                                                openTagFound.success = true;
424	                                        }
425	                                }
426	                        }
427
428	                }
429
430	                if (forwardSearch)
431	                {
432	                        searchStart = result.end + 1;
433	                }
434	                else
435	                {
436	                        searchStart = result.start - 1;
437	                }
438
439	                // Loop while we've found a <TAGNAME, but it's either in a CDATA section,
440	                // or it's got more none whitespace characters after it. e.g. <TAGNAME2
441	        } while (result.success && !openTagFound.success);
442
443	        openTagFound.start = result.start;
444
445
446	        return openTagFound;
*)
end {TTagMatcher.findOpenTag};

{ ------------------------------------------------------------------------------------------------ }
function TTagMatcher.getAttributesPos(const start, finish: integer): TStartFinishes;
begin
(*
41	{
42	        vector< pair<int, int> > attributes;
43
44	        int bufLen = end - start + 1;
45	        char *buf = new char[bufLen+1];
46	        _pEditView->getText(buf, start, end);
47
48	        enum {\
49	                attr_invalid,\
50	                attr_key,\
51	                attr_pre_assign,\
52	                attr_assign,\
53	                attr_string,\
54	                attr_value,\
55	                attr_valid\
56	        } state = attr_invalid;
57
58	        int startPos = -1;
59	        int oneMoreChar = 1;
60	        int i = 0;
61	        for (; i < bufLen ; ++i)
62	        {
63	                switch (buf[i])
64	                {
65	                        case ' ':
66	                        case '\t':
67	                        case '\n':
68	                        case '\r':
69	                        {
70	                                if (state == attr_key)
71	                                        state = attr_pre_assign;
72	                                else if (state == attr_value)
73	                                {
74	                                        state = attr_valid;
75	                                        oneMoreChar = 0;
76	                                }
77	                        }
78	                        break;
79
80	                        case '=':
81	                        {
82	                                if (state == attr_key || state == attr_pre_assign)
83	                                        state = attr_assign;
84	                                else if (state == attr_assign || state == attr_value)
85	                                        state = attr_invalid;
86	                        }
87	                        break;
88
89	                        case '"':
90	                        {
91	                                if (state == attr_string)
92	                                {
93	                                        state = attr_valid;
94	                                        oneMoreChar = 1;
95	                                }
96	                                else if (state == attr_key || state == attr_pre_assign || state == attr_value)
97	                                        state = attr_invalid;
98	                                else if (state == attr_assign)
99	                                        state = attr_string;
100	                        }
101	                        break;
102
103	                        default:
104	                        {
105	                                if (state == attr_invalid)
106	                                {
107	                                        state = attr_key;
108	                                        startPos = i;
109	                                }
110	                                else if (state == attr_pre_assign)
111	                                        state = attr_invalid;
112	                                else if (state == attr_assign)
113	                                        state = attr_value;
114	                        }
115	                }
116
117	                if (state == attr_valid)
118	                {
119	                        attributes.push_back(pair<int, int>(start+startPos, start+i+oneMoreChar));
120	                        state = attr_invalid;
121	                }
122	        }
123	        if (state == attr_value)
124	                attributes.push_back(pair<int, int>(start+startPos, start+i-1));
125
126	        delete [] buf;
127	        return attributes;
*)
end {TTagMatcher.getAttributesPos};

{ ------------------------------------------------------------------------------------------------ }
function TTagMatcher.getXmlMatchedTagsPos(var xmlTags: TXmlMatchedTagsPos): boolean;
begin
(*
134	        bool tagFound = false;
135	        int caret = _pEditView->execute(SCI_GETCURRENTPOS);
136	        int searchStartPoint = caret;
137	        int styleAt;
138	        FindResult openFound;
139
140	        // Search back for the previous open angle bracket.
141	        // Keep looking whilst the angle bracket found is inside an XML attribute
142	        do
143	        {
144	                openFound = findText("<", searchStartPoint, 0, 0);
145	                styleAt = _pEditView->execute(SCI_GETSTYLEAT, openFound.start);
146	                searchStartPoint = openFound.start - 1;
147	        } while (openFound.success && (styleAt == SCE_H_DOUBLESTRING || styleAt == SCE_H_SINGLESTRING) && searchStartPoint > 0);
148
149	        if (openFound.success && styleAt != SCE_H_CDATA)
150	        {
151	                // Found the "<" before the caret, now check there isn't a > between that position and the caret.
152	                FindResult closeFound;
153	                searchStartPoint = openFound.start;
154	                do
155	                {
156	                        closeFound = findText(">", searchStartPoint, caret, 0);
157	                        styleAt = _pEditView->execute(SCI_GETSTYLEAT, closeFound.start);
158	                        searchStartPoint = closeFound.end;
159	                } while (closeFound.success && (styleAt == SCE_H_DOUBLESTRING || styleAt == SCE_H_SINGLESTRING) && searchStartPoint <= caret);
160
161	                if (!closeFound.success)
162	                {
163	                        // We're in a tag (either a start tag or an end tag)
164	                        int nextChar = _pEditView->execute(SCI_GETCHARAT, openFound.start + 1);
165
166
167	                        /////////////////////////////////////////////////////////////////////////
168	                        // CURSOR IN CLOSE TAG
169	                        /////////////////////////////////////////////////////////////////////////
170	                        if ('/' == nextChar)
171	                        {
172	                                xmlTags.tagCloseStart = openFound.start;
173	                                int docLength = _pEditView->execute(SCI_GETLENGTH);
174	                                FindResult endCloseTag = findText(">", caret, docLength, 0);
175	                                if (endCloseTag.success)
176	                                {
177	                                        xmlTags.tagCloseEnd = endCloseTag.end;
178	                                }
179	                                // Now find the tagName
180	                                int position = openFound.start + 2;
181
182	                                // UTF-8 or ASCII tag name
183	                                std::string tagName;
184	                                nextChar = _pEditView->execute(SCI_GETCHARAT, position);
185	                                // Checking for " or ' is actually wrong here, but it means it works better with invalid XML
186	                                while(position < docLength && !isWhitespace(nextChar) && nextChar != '/' && nextChar != '>' && nextChar != '\"' && nextChar != '\'')
187	                                {
188	                                        tagName.push_back((char)nextChar);
189	                                        ++position;
190	                                        nextChar = _pEditView->execute(SCI_GETCHARAT, position);
191	                                }
192
193	                                // Now we know where the end of the tag is, and we know what the tag is called
194	                                if (tagName.size() != 0)
195	                                {
196	                                        /* Now we need to find the open tag.  The logic here is that we search for "<TAGNAME",
197	                                         * then check the next character - if it's one of '>', ' ', '\"' then we know we've found
198	                                         * a relevant tag.
199	                                         * We then need to check if either
200	                                         *    a) this tag is a self-closed tag - e.g. <TAGNAME attrib="value" />
201	                                         * or b) this tag has another closing tag after it and before our closing tag
202	                                         *       e.g.  <TAGNAME attrib="value">some text</TAGNAME></TAGNA|ME>
203	                                         *             (cursor represented by |)
204	                                         * If it's either of the above, then we continue searching, but only up to the
205	                                         * the point of the last find. (So in the (b) example above, we'd only search backwards
206	                                         * from the first "<TAGNAME...", as we know there's a close tag for the opened tag.
207
208	                                         * NOTE::  NEED TO CHECK THE ROTTEN CASE: ***********************************************************
209	                                         * <TAGNAME attrib="value"><TAGNAME>something</TAGNAME></TAGNAME></TAGNA|ME>
210	                                         * Maybe count all closing tags between start point and start of our end tag.???
211	                                         */
212	                                        int currentEndPoint = xmlTags.tagCloseStart;
213	                                        int openTagsRemaining = 1;
214	                                        FindResult nextOpenTag;
215	                                        do
216	                                        {
217	                                                nextOpenTag = findOpenTag(tagName, currentEndPoint, 0);
218	                                                if (nextOpenTag.success)
219	                                                {
220	                                                        --openTagsRemaining;
221	                                                        // Open tag found
222	                                                        // Now we need to check how many close tags there are between the open tag we just found,
223	                                                        // and our close tag
224	                                                        // eg. (Cursor == | )
225	                                                        // <TAGNAME attrib="value"><TAGNAME>something</TAGNAME></TAGNAME></TAGNA|ME>
226	                                                        //                         ^^^^^^^^ we've found this guy
227	                                                        //                                           ^^^^^^^^^^ ^^^^^^^^ Now we need to cound these fellas
228	                                                        FindResult inbetweenCloseTag;
229	                                                        int currentStartPosition = nextOpenTag.end;
230	                                                        int closeTagsFound = 0;
231	                                                        bool forwardSearch = (currentStartPosition < currentEndPoint);
232
233	                                                        do
234	                                                        {
235	                                                                inbetweenCloseTag = findCloseTag(tagName, currentStartPosition, currentEndPoint);
236
237	                                                                if (inbetweenCloseTag.success)
238	                                                                {
239	                                                                        ++closeTagsFound;
240	                                                                        if (forwardSearch)
241	                                                                        {
242	                                                                                currentStartPosition = inbetweenCloseTag.end;
243	                                                                        }
244	                                                                        else
245	                                                                        {
246	                                                                                currentStartPosition = inbetweenCloseTag.start - 1;
247	                                                                        }
248	                                                                }
249
250	                                                        } while(inbetweenCloseTag.success);
251
252	                                                        // If we didn't find any close tags between the open and our close,
253	                                                        // and there's no open tags remaining to find
254	                                                        // then the open we found was the right one, and we can return it
255	                                                        if (0 == closeTagsFound && 0 == openTagsRemaining)
256	                                                        {
257	                                                                xmlTags.tagOpenStart = nextOpenTag.start;
258	                                                                xmlTags.tagOpenEnd = nextOpenTag.end + 1;
259	                                                                xmlTags.tagNameEnd = nextOpenTag.start + tagName.size() + 1;  /* + 1 to account for '<' */
260	                                                                tagFound = true;
261	                                                        }
262	                                                        else
263	                                                        {
264
265	                                                                // Need to find the same number of opening tags, without closing tags etc.
266	                                                                openTagsRemaining += closeTagsFound;
267	                                                                currentEndPoint = nextOpenTag.start;
268	                                                        }
269	                                                }
270	                                        } while (!tagFound && openTagsRemaining > 0 && nextOpenTag.success);
271	                                }
272	                        }
273	                        else
274	                        {
275	                        /////////////////////////////////////////////////////////////////////////
276	                        // CURSOR IN OPEN TAG
277	                        /////////////////////////////////////////////////////////////////////////
278	                                int position = openFound.start + 1;
279	                                int docLength = _pEditView->execute(SCI_GETLENGTH);
280
281	                                xmlTags.tagOpenStart = openFound.start;
282
283	                                std::string tagName;
284	                                nextChar = _pEditView->execute(SCI_GETCHARAT, position);
285	                                // Checking for " or ' is actually wrong here, but it means it works better with invalid XML
286	                                while(position < docLength && !isWhitespace(nextChar) && nextChar != '/' && nextChar != '>' && nextChar != '\"' && nextChar != '\'')
287	                                {
288	                                        tagName.push_back((char)nextChar);
289	                                        ++position;
290	                                        nextChar = _pEditView->execute(SCI_GETCHARAT, position);
291	                                }
292
293	                                // Now we know where the end of the tag is, and we know what the tag is called
294	                                if (tagName.size() != 0)
295	                                {
296	                                        // First we need to check if this is a self-closing tag.
297	                                        // If it is, then we can just return this tag to highlight itself.
298	                                        xmlTags.tagNameEnd = openFound.start + tagName.size() + 1;
299	                                        int closeAnglePosition = findCloseAngle(position, docLength);
300	                                        if (-1 != closeAnglePosition)
301	                                        {
302	                                                xmlTags.tagOpenEnd = closeAnglePosition + 1;
303	                                                // If it's a self closing tag
304	                                                if (_pEditView->execute(SCI_GETCHARAT, closeAnglePosition - 1) == '/')
305	                                                {
306	                                                        // Set it as found, and mark that there's no close tag
307	                                                        xmlTags.tagCloseEnd = -1;
308	                                                        xmlTags.tagCloseStart = -1;
309	                                                        tagFound = true;
310	                                                }
311	                                                else
312	                                                {
313	                                                        // It's a normal open tag
314
315
316
317	                                                        /* Now we need to find the close tag.  The logic here is that we search for "</TAGNAME",
318	                                                         * then check the next character - if it's '>' or whitespace followed by '>' then we've
319	                                                         * found a relevant tag.
320	                                                         * We then need to check if
321	                                                         * our tag has another opening tag after it and before the closing tag we've found
322	                                                         *       e.g.  <TA|GNAME><TAGNAME attrib="value">some text</TAGNAME></TAGNAME>
323	                                                         *             (cursor represented by |)
324	                                                         */
325	                                                        int currentStartPosition = xmlTags.tagOpenEnd;
326	                                                        int closeTagsRemaining = 1;
327	                                                        FindResult nextCloseTag;
328	                                                        do
329	                                                        {
330	                                                                nextCloseTag = findCloseTag(tagName, currentStartPosition, docLength);
331	                                                                if (nextCloseTag.success)
332	                                                                {
333	                                                                        --closeTagsRemaining;
334	                                                                        // Open tag found
335	                                                                        // Now we need to check how many close tags there are between the open tag we just found,
336	                                                                        // and our close tag
337	                                                                        // eg. (Cursor == | )
338	                                                                        // <TAGNAM|E attrib="value"><TAGNAME>something</TAGNAME></TAGNAME></TAGNAME>
339	                                                                        //                                            ^^^^^^^^ we've found this guy
340	                                                                        //                         ^^^^^^^^^ Now we need to find this fella
341	                                                                        FindResult inbetweenOpenTag;
342	                                                                        int currentEndPosition = nextCloseTag.start;
343	                                                                        int openTagsFound = 0;
344
345	                                                                        do
346	                                                                        {
347	                                                                                inbetweenOpenTag = findOpenTag(tagName, currentStartPosition, currentEndPosition);
348
349	                                                                                if (inbetweenOpenTag.success)
350	                                                                                {
351	                                                                                        ++openTagsFound;
352	                                                                                        currentStartPosition = inbetweenOpenTag.end;
353	                                                                                }
354
355	                                                                        } while(inbetweenOpenTag.success);
356
357	                                                                        // If we didn't find any open tags between our open and the close,
358	                                                                        // and there's no close tags remaining to find
359	                                                                        // then the close we found was the right one, and we can return it
360	                                                                        if (0 == openTagsFound && 0 == closeTagsRemaining)
361	                                                                        {
362	                                                                                xmlTags.tagCloseStart = nextCloseTag.start;
363	                                                                                xmlTags.tagCloseEnd = nextCloseTag.end + 1;
364	                                                                                tagFound = true;
365	                                                                        }
366	                                                                        else
367	                                                                        {
368
369	                                                                                // Need to find the same number of closing tags, without opening tags etc.
370	                                                                                closeTagsRemaining += openTagsFound;
371	                                                                                currentStartPosition = nextCloseTag.end;
372	                                                                        }
373	                                                                }
374	                                                        } while (!tagFound && closeTagsRemaining > 0 && nextCloseTag.success);
375	                                                } // end if (selfclosingtag)... else {
376	                                        } // end if (-1 != closeAngle)  {
377
378	                                } // end if tagName.size() != 0
379	                        } // end open tag test
380	                }
381	        }
382	        return tagFound;
*)
end {TTagMatcher.getXmlMatchedTagsPos};

{ ------------------------------------------------------------------------------------------------ }
function TTagMatcher.isWhitespace(const C: char): boolean;
begin
  Result := C.IsInArray([' ', #9, #13, #10]);
end {isWhitespace};

{ ------------------------------------------------------------------------------------------------ }
function TTagMatcher.MatchTags(const Highlight: boolean): boolean;
var
  lang: LangType;
  codeBeginTag, codeEndTag: string;
  caret: Integer;
  startFound, endFound: TFindResult;
  xmlTags: TXmlMatchedTagsPos;
  SelAnchor: Integer;
  SelectionGroup: Integer;
begin
  Result := False;

//        // Detect the current lang type. It works only with html and xml
//        LangType lang = (_pEditView->getCurrentBuffer())->getLangType();
//
//        if (lang != L_XML && lang != L_HTML && lang != L_PHP && lang != L_ASP && lang != L_JSP)
//                return;

  // Detect the current lang type. It works only with html and xml
  lang := FDoc.Language;

  if not (lang in [L_XML, L_HTML, L_PHP, L_ASP, L_JSP]) then
    Exit;

//        // If we're inside a code block (i.e not markup), don't try to match tags.
//        if (lang == L_PHP || lang == L_ASP || lang == L_JSP)
//        {
//                std::string codeBeginTag = lang == L_PHP ? "<?" : "<%";
//                std::string codeEndTag = lang == L_PHP ? "?>" : "%>";
//
//                const int caret = 1 + _pEditView->execute(SCI_GETCURRENTPOS); // +1 to deal with the case when the caret is between the angle and the question mark in "<?" (or between '<' and '%').
//                const FindResult startFound = findText(codeBeginTag.c_str(), caret, 0, 0); // This searches backwards from "caret".
//                const FindResult endFound= findText(codeEndTag.c_str(), caret, 0, 0); // This searches backwards from "caret".
//
//                if(startFound.success)
//                {
//                        if(! endFound.success)
//                                return;
//                        else if(endFound.success && endFound.start <= startFound.end)
//                                return;
//                }
//        }

  // If we're inside a code block (i.e not markup), don't try to match tags.
  if lang in [L_PHP, L_ASP, L_JSP] then begin
    codeBeginTag := IfThen(lang = L_PHP, '<?', '<%');
    codeEndTag   := IfThen(lang = L_PHP, '?>', '%>');

    caret := 1 + FDoc.CurrentPosition; // +1 to deal with the case when the caret is between the angle and the question mark in "<?" (or between '<' and '%').
    startFound := findText(codeBeginTag, caret, 0, 0);  // TODO: does this search backwards from "caret"?
    endFound   := findText(codeEndTag,   caret, 0, 0);  // TODO: does this search backwards from "caret"?
    if startFound.success then begin
      if (not endFound.success) or (endFound.start <= startFound.finish) then
        Exit;
    end;
  end;

//        // Get the original targets and search options to restore after tag matching operation
//        int originalStartPos = _pEditView->execute(SCI_GETTARGETSTART);
//        int originalEndPos = _pEditView->execute(SCI_GETTARGETEND);
//        int originalSearchFlags = _pEditView->execute(SCI_GETSEARCHFLAGS);

  // TODO: does this plugin need this?

  Result := getXmlMatchedTagsPos(xmlTags);
  if Result then begin

    // TODO: toggle between <end>, <start tag with attributes>, <attributes only>, >content only<, <open>tags and content</close>, and back to <end>?

    // TODO: first see if there's a selection, and if so, whether it exactly matches [openstart..openend] or [nameend..openend] or [closestart..closeend];
    //  if it matches either of those, select the next group. Otherwise, just look at the currentposition
    with FDoc.Selection do begin
      SelAnchor := Anchor;
      Caret := Position;
    end;
    SelectionGroup := 0; // none
    if Abs(caret - SelAnchor) > 0 then begin
      if ((SelAnchor = xmlTags.OpenStart) and (caret = xmlTags.OpenEnd)) or
          ((caret = xmlTags.OpenStart) and (SelAnchor = xmlTags.OpenEnd)) then begin
        SelectionGroup := 1; // opening tag with attributes
      end else if ((SelAnchor = xmlTags.NameEnd) and (caret = xmlTags.OpenEnd)) or
                  ((caret = xmlTags.NameEnd) and (SelAnchor = xmlTags.OpenEnd)) then begin
        SelectionGroup := 2; // attributes only
      end else if ((SelAnchor = xmlTags.OpenEnd) and (caret = xmlTags.CloseStart)) or
                  ((caret = xmlTags.CloseStart) and (SelAnchor = xmlTags.OpenEnd)) then begin
        SelectionGroup := 3; // content only
      end else if ((SelAnchor = xmlTags.OpenStart) and (caret = xmlTags.CloseEnd)) or
                  ((caret = xmlTags.CloseEnd) and (SelAnchor = xmlTags.OpenStart)) then begin
        SelectionGroup := 4; // tags and content
      end else if ((SelAnchor = xmlTags.CloseStart) and (caret = xmlTags.CloseEnd)) or
                  ((caret = xmlTags.CloseEnd) and (SelAnchor = xmlTags.CloseStart)) then begin
        SelectionGroup := 5; // end tag
      end;
      if SelectionGroup > 0 then begin
        Inc(SelectionGroup);
        if SelectionGroup > 5 then
          SelectionGroup := 1;
      end;
    end;

    if SelectionGroup = 0 then begin
      if (FDoc.CurrentPosition >= xmlTags.OpenStart) and (FDoc.CurrentPosition <= xmlTags.OpenEnd) then begin
        // the caret is inside the opening tag
        SelectionGroup := 5; // select the closing tag
      end else begin
        // the caret is inside the closing tag
        SelectionGroup := 1; // select the opening tag
      end;
    end;

    case SelectionGroup of
      1:  // opening tag
        FDoc.Select(xmlTags.OpenStart, xmlTags.OpenEnd);
      2:  // attributes
        FDoc.Select(xmlTags.NameEnd, xmlTags.OpenEnd);
      3:  // content only
        FDoc.Select(xmlTags.OpenEnd, xmlTags.CloseStart);
      4:  // tags and content
        FDoc.Select(xmlTags.OpenStart, xmlTags.CloseEnd);
      5:  // end tag
        FDoc.Select(xmlTags.CloseStart, xmlTags.CloseEnd);
    end;
  end;

end {TTagMatcher.MatchTags};

{ ------------------------------------------------------------------------------------------------ }
class function TTagMatcher.MatchTags(const Document: TActiveDocument; const Highlight: Boolean): boolean;
var
  TagMatcher: TTagMatcher;
begin
  TagMatcher := TTagMatcher.Create(Document);
  try
    Result := TagMatcher.MatchTags(Highlight);
  finally
    TagMatcher.Free;
  end;
end {TTagMatcher.MatchTags};

end.
