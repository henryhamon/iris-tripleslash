Class iris.beaker.Parser Extends %RegisteredObject
{

Parameter exampleOpen = "<example>";

Parameter exampleClose = "</example>";

Parameter exampleSub = 11;

Parameter preOpen = "<pre>";

Parameter preClose = "</pre>";

Parameter preSub = 7;

Parameter BL = {$Char(13,10)};

ClassMethod GetCodeBlock(pBlock As %String, Output codeBlock As %ListOfDataTypes) As %Status
{
	Set tSC = $$$OK
    Set codeBlock = ##class(%ListOfDataTypes).%New()
	Try {
        For tag=1:1:2 {
            Set block = ..ExtractContent(tag, pBlock)
            Continue:(block="")
            Set lstBlock = $ListFromString(block, ..#BL)
            Set pos = 0
            While $ListNext(lstBlock, pos, value) {
                Continue:(value="")
                Do codeBlock.Insert(value)
            }
        }

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Return tSC
}

ClassMethod ExtractContent(tag As %Integer, block As %String) As %String [ Private ]
{
    Set tagOpen = ..#exampleOpen
    Set tagClose = ..#exampleClose
    Set sub = ..#exampleSub
    If (tag = 2) {
        Set tagOpen = ..#preOpen
        Set tagClose = ..#preClose
        Set sub = ..#preSub

    }
    Quit $Extract(block, $Find(block, tagOpen), $Find(block, tagClose) - sub)
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

ClassMethod ListToStr(list As %ListOfDataTypes, Output block As %String) As %Status
{
    Set lst = ""
    For idx=1:1:list.Count() {
        Set $List(lst, * + 1) = list.GetAt(idx)
    }
    Set block = $ListToString(lst, $Char(13,10))
    Return $$$OK
}

ClassMethod AssertOkNotOk(ByRef list As %ListOfDataTypes) As %Status
{
    Set tSC = $$$OK
	Try {
        Do ..ListToStr(list, .codeBlock)
        Set re = ##class(%SYS.Python).Import("re")
        Set pttrn = re.compile("^(([dD]([oO]|))\s+)*")
        Set x = re.finditer(codeBlock)
		
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
        W !,$System.Status.GetErrorText(tSC)
	}
	Return tSC
}

/// ^(Write\s+)((.|\n)*?)(Set\s|Do\s)

}
