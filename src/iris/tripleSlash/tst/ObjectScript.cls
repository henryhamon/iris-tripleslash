Class iris.tripleSlash.tst.ObjectScript Extends %UnitTest.TestCase [ Not ProcedureBlock ]
{

Method TestTheAnswerForEverything()
{
  Do $$$AssertEquals(##class(dc.sample.ObjectScript).TheAnswerForEverything(), 42)
}

}
