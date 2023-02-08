Class iris.tripleSlash.tst.ObjectScript Extends %UnitTest.TestCase [ Not ProcedureBlock ]
{

Method OnAfterAllTests()
{
  Write "Executes once after all of the test methods in a test class execute. Can tear down a test environment."
}

Method OnAfterOneTest()
{
  Write "Executes immediately after each test method in a text class executes."
}

Method OnBeforeAllTests()
{
  Write "Executes once before any of the test methods in a test class execute. Can set up a test environment."
}

Method OnBeforeOneTest()
{
  Write "Executes immediately before each test method in a test class executes."
}

Method TestGuessTheNumber()
{
  Do $$$AssertStatusOK(##class(dc.sample.ObjectScript).GuessTheNumber(42))
  Do $$$AssertStatusNotOK(##class(dc.sample.ObjectScript).GuessTheNumber(23))
}

Method TestTheAnswerForEverything()
{
  Do $$$AssertEquals(##class(dc.sample.ObjectScript).TheAnswerForEverything(), 42)
}

}
