/// A simple class for testing purpose.
/// 
/// <beforeAll>
/// Write "Executes once before any of the test methods in a test class execute. Can set up a test environment."
/// Return $$$OK
/// </beforeAll>
/// 
/// <afterAll>
/// Write "Executes once after all of the test methods in a test class execute. Can tear down a test environment."
/// Return $$$OK
/// </afterAll>
/// 
/// <beforeOne>
/// Write "Executes immediately before each test method in a test class executes."
/// Return $$$OK
/// </beforeOne>
/// 
/// <afterOne>
/// Write "Executes immediately after each test method in a text class executes."
/// Return $$$OK
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

ClassMethod PythonTest() [ Language = python ]
{
import sketch
import numpy as np
import pandas as pd

def ask(prompt_str, df):
    print('-------')
    print(f'ask: {prompt_str}')
    resp = df.sketch.ask(prompt_str, call_display=False)
    print(resp)

# a dummy dataframe to make sketch happy...
input = """
id   actual amountofsale channel comment dateofsale discount  outletcity outletcountry  product targetamount unitssold zipcode
1      True         2.95                 2022-11-07        0    New York           USA  SKU-192                      1   13778
100    True         3.96       2         2021-10-29       .2       Tokyo         Japan  SKU-708                      1"""
df = pd.DataFrame(data={'input': input.split("\n")[1:]})

ask("Acting as a software enginnier, give me a set of inputs/expected outputs pairs (2 pairs) for a method that expects a number, returns '$$$OK' just when the number 42 is passed or a '$$$NotOK' for any other value. Format your output as a JSON like this one [{\"input\":\"<input value>\", \"output\":\"<expected value>\"}]", df)

ask("Acting as a software enginnier, give me a set of inputs/expected outputs pairs (2 pairs) for a method that always returns the number 42. Format your output as a JSON like this one [{\"input\":\"<input value>\", \"output\":\"<expected value>\"}]", df)
}

}
