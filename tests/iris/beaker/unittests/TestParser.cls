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

Method TestIdentifyWriteCommand()
{
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("Write 1")
    Do codeBlock.Insert("; 1")
}

}
