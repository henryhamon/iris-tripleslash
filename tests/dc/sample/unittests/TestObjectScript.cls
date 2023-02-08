Class dc.sample.unittests.TestObjectScript Extends %UnitTest.TestCase
{

Method OnAfterAllTests() As %Status
{
  Write "Executes once after all of the test methods in a test class execute. Can tear down a test environment."
  Return $$$OK
}

Method OnAfterOneTest() As %Status
{
  Write "Executes immediately after each test method in a text class executes."
  Return $$$OK
}

Method OnBeforeAllTests() As %Status
{
  Write "Executes once before any of the test methods in a test class execute. Can set up a test environment."
  Return $$$OK
}

Method OnBeforeOneTest() As %Status
{
  Write "Executes immediately before each test method in a test class executes."
  Return $$$OK
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
