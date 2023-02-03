Class dc.sample.ObjectScript
{

/// A simple method for testing purpose.
/// 
/// <example>
/// Write ##class(dc.sample.ObjectScript).TheAnswerForEverything()
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

ClassMethod GuessTheNumber(pNumber As %Integer) As %Status
{
    Set st = $$$OK
    Set theAnswerForEveryThing = 42
    Try {
        Throw:(pNumber '= theAnswerForEveryThing) ##class(%Exception.StatusException).%New("Sorry, wrong number...")
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Return st
}

}
