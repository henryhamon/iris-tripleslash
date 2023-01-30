Class iris.beaker.unittests.TestParser Extends %UnitTest.TestCase
{

Method TestGetCodeBlockExample()
{
    Set block = "Documentation Test"_$Char(13,10)_"<example>"_$Char(13,10)_
        "Write 1"_$Char(13,10)_"; 1"_$Char(13,10)_"</example>"
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).GetCodeBlock(block, .codeBlock))
    Set tExpected = 2
    Set tResults = codeBlock.Count()
	Do $$$AssertEquals(tResults, tExpected, tExpected_" = "_tResults)
}

Method TestGetCodeBlockPre()
{
    Set block = "Documentation Test"_$Char(13,10)_"<pre>"_$Char(13,10)_
        "Write 1"_$Char(13,10)_"; 1"_$Char(13,10)_"</pre>"
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).GetCodeBlock(block, .codeBlock))
    Set tExpected = 2
    Set tResults = codeBlock.Count()
	Do $$$AssertEquals(tResults, tExpected, tExpected_" = "_tResults)
}

Method TestRemoveCommentLineDelimiters()
{
    Set tExpected = "comment"
    Set comment = "// comment"
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, tExpected, tExpected_" = "_comment)
    Set comment = "//comment"
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, tExpected, tExpected_" = "_comment)
    Set comment = ";comment"
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, tExpected, tExpected_" = "_comment)
    Set comment = "; comment"
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, tExpected, tExpected_" = "_comment)
    Set comment = "1"
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, "1", "1 = "_comment)
}

Method TestLinesTrim()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("   Write 1 ")
    Do codeBlock.Insert("; 1")
    Do codeBlock.Insert("  Set 1    ")
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).LinesTrim(.codeBlock))

    Set tExpected = "Write 1"
	Do $$$AssertEquals(codeBlock.GetAt(1), tExpected, tExpected_" = "_codeBlock.GetAt(1))
    Set tExpected = "; 1"
	Do $$$AssertEquals(codeBlock.GetAt(2), tExpected, tExpected_" = "_codeBlock.GetAt(2))
    Set tExpected = "Set 1"
	Do $$$AssertEquals(codeBlock.GetAt(3), tExpected, tExpected_" = "_codeBlock.GetAt(3))
}

Method TestLstToStr()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("Do ##class(iris.beaker.Core).Execute()")
    Do codeBlock.Insert("Write 1")
    Do codeBlock.Insert("1")
    Do codeBlock.Insert("Set var = 2")
    Do codeBlock.Insert("Write var")
    Do codeBlock.Insert("2")
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).ListToStr(codeBlock, .block))
    Set tExpected = "Do ##class(iris.beaker.Core).Execute()" _ $Char(13,10)_
        "Write 1" _ $Char(13,10)_
        "1" _ $Char(13,10)_
        "Set var = 2" _ $Char(13,10)_
        "Write var" _ $Char(13,10)_
        "2" 
    Do $$$AssertEquals(block, tExpected,block _ "|" _ tExpected)
    Kill block
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).ListToStr(codeBlock, .block))
    Do $$$AssertEquals(block, "",block)
}

Method TestAssertOkNotOk()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("Write 1")
    Do codeBlock.Insert("1")
    Do codeBlock.Insert("Do ##class(iris.beaker.Core).Execute()")
    Do codeBlock.Insert("$$$OK")
    Do codeBlock.Insert("Set var = 2")
    Do codeBlock.Insert("Write var")
    Do codeBlock.Insert("2")
    Do codeBlock.Insert("D ##class(iris.beaker.Core).Execute()")
    Do codeBlock.Insert("$$$NotOK")
    Do codeBlock.Insert("Do ##class(iris.beaker.Core).Execute()")
    Do codeBlock.Insert("$$$ERROR")
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).AssertOkNotOk(.codeBlock))
    Do $$$AssertStatusOK(##class(iris.beaker.Parser).ListToStr(codeBlock, .block))
    Set tExpected = "Write 1" _ $Char(13,10)_
        "1" _ $Char(13,10)_
        "Do $$$AssertStatusOK(##class(iris.beaker.Core).Execute())" _ $Char(13,10)_
        "Set var = 2" _ $Char(13,10)_
        "Write var" _ $Char(13,10)_
        "2" _
        "Do $$$AssertStatusNotOK(##class(iris.beaker.Core).Execute())" _ $Char(13,10)_
        "Do $$$AssertStatusNotOK(##class(iris.beaker.Core).Execute())"
    Do $$$AssertEquals(block, tExpected,block _ "|" _ tExpected)
}

Method TestIdentifyWriteCommand()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("Write 1")
    Do codeBlock.Insert("; 1")
}

}
