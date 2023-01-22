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
		Set commentLineDelimiters = $ListBuild("//",";")
		For k=1:1:$ListLength(commentLineDelimiters){
			Set pValue = $ListFromString(pValue, $List(commentLineDelimiters,k)) // <- comment
			Set pValue = $List(pValue,1)
		}
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

}
