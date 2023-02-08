/// A simple class for testing purpose.
/// 
/// <beforeAll>
/// Write "Executes once before any of the test methods in a test class execute. Can set up a test environment."
/// </beforeAll>
/// 
/// <afterAll>
/// Write "Executes once after all of the test methods in a test class execute. Can tear down a test environment."
/// </afterAll>
/// 
/// <beforeOne>
/// Write "Executes immediately before each test method in a test class executes."
/// </beforeOne>
/// 
/// <afterOne>
/// Write "Executes immediately after each test method in a text class executes."
/// </afterOne>
Class dc.sample.ObjectScript
{

/// A simple method for testing purpose.
/// 
/// <example>
/// Write ..TheAnswerForEverything()
/// 42
/// </example>
ClassMethod TheAnswerForEverything() As %Integer
{
    Set a = 42 
    Write "Hello World!",!
    Write "This is InterSystems IRIS with version ",$zv,!
    Write "Current time is: "_$zdt($h,2)
    Return a
}

/// Another simple method for testing purpose.
/// 
/// <example>
/// Do ..GuessTheNumber(42)
/// $$$OK
/// Do ..GuessTheNumber(23)
/// $$$NotOK
/// </example>
ClassMethod GuessTheNumber(pNumber As %Integer) As %Status
{
    Set st = $$$OK
    Set theAnswerForEverything = 42
    Try {
        Throw:(pNumber '= theAnswerForEverything) ##class(%Exception.StatusException).%New("Sorry, wrong number...")
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Return st
}

}
