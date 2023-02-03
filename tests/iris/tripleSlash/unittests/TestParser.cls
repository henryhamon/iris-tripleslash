Class iris.tripleSlash.unittests.TestParser Extends %UnitTest.TestCase
{

Method TestGetCodeBlockExample()
{
    Set block = "Documentation Test"_$Char(13,10)_"<example>"_$Char(13,10)_
        "Write 1"_$Char(13,10)_"; 1"_$Char(13,10)_"</example>"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).GetCodeBlock(block, .codeBlock))
    Set tExpected = 2
    Set tResults = codeBlock.Count()
	Do $$$AssertEquals(tResults, tExpected, tExpected_" = "_tResults)
}

Method TestGetCodeBlockPre()
{
    Set block = "Documentation Test"_$Char(13,10)_"<pre>"_$Char(13,10)_
        "Write 1"_$Char(13,10)_"; 1"_$Char(13,10)_"</pre>"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).GetCodeBlock(block, .codeBlock))
    Set tExpected = 2
    Set tResults = codeBlock.Count()
	Do $$$AssertEquals(tResults, tExpected, tExpected_" = "_tResults)
}

Method TestRemoveCommentLineDelimiters()
{
    Set tExpected = "comment"
    Set comment = "// comment"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, tExpected, tExpected_" = "_comment)
    Set comment = "//comment"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, tExpected, tExpected_" = "_comment)
    Set comment = ";comment"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, tExpected, tExpected_" = "_comment)
    Set comment = "; comment"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, tExpected, tExpected_" = "_comment)
    Set comment = "1"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).RemoveComments(.comment))
	Do $$$AssertEquals(comment, "1", "1 = "_comment)
}

Method TestLinesTrim()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("   Write 1 ")
    Do codeBlock.Insert("; 1")
    Do codeBlock.Insert("  Set 1    ")
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).LinesTrim(.codeBlock))

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
    Do codeBlock.Insert("Do ##class(iris.tripleSlash.Core).Execute()")
    Do codeBlock.Insert("Write 1")
    Do codeBlock.Insert("1")
    Do codeBlock.Insert("Set var = 2")
    Do codeBlock.Insert("Write var")
    Do codeBlock.Insert("2")
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).ListToStr(codeBlock, .block))
    Set tExpected = "Do ##class(iris.tripleSlash.Core).Execute()" _ $Char(13,10)_
        "Write 1" _ $Char(13,10)_
        "1" _ $Char(13,10)_
        "Set var = 2" _ $Char(13,10)_
        "Write var" _ $Char(13,10)_
        "2" 
    Do $$$AssertEquals(block, tExpected,block _ "|" _ tExpected)
    Kill block
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).ListToStr(codeBlock, .block))
    Do $$$AssertEquals(block, "",block)
}

Method TestAssertOkNotOk()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("Write 1")
    Do codeBlock.Insert("1")
    Do codeBlock.Insert("Do ##class(iris.tripleSlash.Core).Execute()")
    Do codeBlock.Insert("$$$OK")
    Do codeBlock.Insert("Set var = 2")
    Do codeBlock.Insert("Write var")
    Do codeBlock.Insert("2")
    Do codeBlock.Insert("D ##class(iris.tripleSlash.Core).Execute()")
    Do codeBlock.Insert("$$$NotOK")
    Do codeBlock.Insert("Do ##class(iris.tripleSlash.Core).Execute()")
    Do codeBlock.Insert("$$$ERROR")
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).AssertOk(.codeBlock))
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).ListToStr(codeBlock, .block))
    Set tExpected = "Write 1" _ $Char(13,10)_
        "1" _ $Char(13,10)_
        "Do $$$AssertStatusOK(##class(iris.tripleSlash.Core).Execute())" _ $Char(13,10)_
        "Set var = 2" _ $Char(13,10)_
        "Write var" _ $Char(13,10)_
        "2" _$Char(13,10)_
        "Do $$$AssertStatusNotOK(##class(iris.tripleSlash.Core).Execute())" _ $Char(13,10)_
        "Do $$$AssertStatusNotOK(##class(iris.tripleSlash.Core).Execute())"
    Do $$$AssertEquals(block, tExpected, block _ " | " _ tExpected)
}

Method TestAssertEqual()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("Write 1")
    Do codeBlock.Insert("1")
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).AssertEql(.codeBlock))
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).ListToStr(codeBlock, .block))
    Set tExpected = "Do $$$AssertEquals(1, 1)"
    Do $$$AssertEquals(block, tExpected, block _ " | " _ tExpected)
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("S number = 1")
    Do codeBlock.Insert("W number")
    Do codeBlock.Insert("1")
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).AssertEql(.codeBlock))
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).ListToStr(codeBlock, .block))
    Set tExpected = "S number = 1"_$C(13,10)_ "Do $$$AssertEquals(number, 1)"
    Do $$$AssertEquals(block, tExpected, block _ " | " _ tExpected)
}

Method TestAssertNotEqual()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("Set number = 3")
    Do codeBlock.Insert("Write number")
    Do codeBlock.Insert("'1")
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).AssertEql(.codeBlock))
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).ListToStr(codeBlock, .block))
    Set tExpected = "Set number = 3"_$C(13,10)_ "Do $$$AssertNotEquals(number, 1)"
    Do $$$AssertEquals(block, tExpected, block _ " | " _ tExpected)
}

Method TestGetMultipleCodeBlock()
{
    Set block = "Documentation Test"_$Char(13,10)_"<pre>"_$Char(13,10)_
        "Write 1"_$Char(13,10)_"; 1"_$Char(13,10)_"</pre>"_
        "Dont get this line"_$Char(13,10)_"</pre>"_
        "<example>"_$Char(13,10)_
        "Write 3"_$Char(13,10)_"3"_$Char(13,10)_"</example>"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).GetCodeBlock(block, .codeBlock))
    Set tExpected = 4
    Set tResults = codeBlock.Count()
	Do $$$AssertEquals(tResults, tExpected, tExpected_" = "_tResults)
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Parser).ListToStr(codeBlock, .tResults))
    Set tExpected = "Write 1"_$C(13,10)_ "; 1"_$C(13,10)_"Write 3"_$C(13,10)_ "3"
	Do $$$AssertEquals(tResults, tExpected, tExpected_" = "_tResults)
}

}
