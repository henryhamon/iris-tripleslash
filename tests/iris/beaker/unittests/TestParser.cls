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

}