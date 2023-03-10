Class iris.tripleSlash.Parser Extends %RegisteredObject
{

Parameter BL = {$Char(13,10)};

ClassMethod GetCodeBlock(pBlock As %String, Output codeBlock As %ListOfDataTypes) As %Status
{
	Set tSC = $$$OK
    Set codeBlock = ##class(%ListOfDataTypes).%New()
	Try {
        Set block = ..ExtractContent("example|pre", pBlock)
        $$$ThrowOnError(..StrToList(block, .codeBlock))
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Return tSC
}

ClassMethod RemoveComments(ByRef pValue As %String) As %Status
{
	Set tSC = $$$OK
	Try {
		Set commentLineDelimiters = $ListBuild("// ","; ","//",";")
		For k=1:1:$ListLength(commentLineDelimiters){
            Set delimiter = $List(commentLineDelimiters,k)
			Set:($Find(pValue, delimiter)) pValue = $Replace(pValue, delimiter,"") // <- comment
		}
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Return tSC
}

ClassMethod LinesTrim(ByRef codeBlock As %ListOfDataTypes) As %Status
{
	Set tSC = $$$OK
    Set code = ##class(%ListOfDataTypes).%New()
    Try {
        For idx=1:1:codeBlock.Count() {
            Set matcher=##class(%Regex.Matcher).%New("^[\s\t]+|[\s]+$")                             
            Set matcher.Text = codeBlock.GetAt(idx)
            Do codeBlock.SetAt(matcher.ReplaceAll(""), idx)
        }
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
    Return tSC
}

ClassMethod ListToStr(list As %ListOfDataTypes, Output block As %String, breakSeparator As %String = "") As %Status
{
    Set lst = ""
    Set:(breakSeparator = "" ) breakSeparator = $Char(13,10)
    For idx=1:1:list.Count() {
        Set $List(lst, * + 1) = list.GetAt(idx)
    }
    Set block = $ListToString(lst, breakSeparator)
    Return $$$OK
}

ClassMethod StrToList(block As %String, Output list As %ListOfDataTypes) As %Status
{
    Set list = ##class(%ListOfDataTypes).%New()
    Set lstBlock = $ListFromString(block, ..#BL)
    Set pos = 0
    While $ListNext(lstBlock, pos, value) {
        Continue:(value="")
        Do list.Insert(value)
    }
    Return $$$OK
}

ClassMethod AssertOk(ByRef list As %ListOfDataTypes, className As %String = "") As %Status
{
    Set tSC = $$$OK
    Set asserts = $ListBuild("$$$OK", "$$$NotOK", "$$$ERROR")
	Try {
        Do ..ListToStr(list, .codeBlock, "\n")
        Set codeAux = codeBlock
        Set matcher=##class(%Regex.Matcher).%New("(([dD]([oO]|))\s+)(.|\n)*?(\${3}\w+)")                             
        Set matcher.Text = codeBlock
        While matcher.Locate() {
            Set assertStr = "NotOK"
            Set code = $Extract(codeBlock,matcher.Start - 2, matcher.End + 1)
            Set:($Extract(code,* - 1, *)="\n") code = $Extract(code,1, * - 2)
            Set replace = code
            Set:($Find(replace,$List(asserts,1))) assertStr = "OK"
            Set replace = $Replace($Piece(replace, " ", 2, *),"\n", "")
            Set ptr = 0
            While $ListNext(asserts, ptr, value) {
                Set replace = $Replace(replace, value, "")
            }
            Set replace = ..AddCurrentClassName(replace, className)
            Set codeAux = $Replace(codeAux, code, "\nDo $$$AssertStatus"_assertStr_"(" _ replace _ ")")
        }	
        Set list = ##class(%ListOfDataTypes).%New()
        Set ptr = 0
        Set code = $ListFromString(codeAux, "\n")
        While ($ListNext(code, ptr, line)) {
            Continue:(line="") //Remove empty line
            Do list.Insert(line)
        }
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Return tSC
}

ClassMethod AssertEql(ByRef list As %ListOfDataTypes, className As %String = "") As %Status
{
    Set tSC = $$$OK
    Set notSymbol = $ListBuild("'", "!")
	Try {
        Set code = ##class(%ListOfDataTypes).%New()
        For idx=1:1:list.Count() {
            Set assertStr = ""
            Set line = list.GetAt(idx)
            If ($Find($ZConvert(line,"l"), "write ")||($Find($ZConvert(line,"l"), "w "))){
                Set idx = idx + 1
                Set nextLine = list.GetAt(idx)
                Set line = $Piece(line, " ", 2, *) // Remove write command
                Do ..RemoveComments(.nextLine)
                If ($ListFind(notSymbol,$Extract(nextLine,1,1))) {
                    Set nextLine = $Extract(nextLine, 2, *)
                    Set assertStr = "Not"
                }
                Set line = ..AddCurrentClassName(line, className)
                Set line = "Do $$$Assert"_ assertStr_"Equals("_line_", "_ nextLine _ ")"
            }
            Do code.Insert(line)
        }
        Set list = code
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Return tSC
}

ClassMethod ExtractContent(tag As %String, block As %String) As %String
{
    Set content = ""
    Set block = $Replace(block, $Char(13,10), "\n")
    Set regexClean=##class(%Regex.Matcher).%New("(i?)(<("_tag_")>)|(<\/("_tag_")>)")                             
    Set matcher=##class(%Regex.Matcher).%New("(i?)<("_tag_")>.*?<\/("_tag_")>")                             
    Set matcher.Text = block
    While matcher.Locate() {
        Set regexClean.Text = matcher.Group
        Set content = content _ regexClean.ReplaceAll("")
        Set regexClean.Text = ""
    }
    Set content = $Replace(content, "\n", $Char(13,10))
    Return content
}

ClassMethod AddCurrentClassName(method As %String, className As %String = "") As %String [ Private ]
{
    Set:((className'="")&&($Extract(method, 1, 2)="..")) method = "##class("_ className_")"_$Extract(method, 2, *)
    Return method
}

}
