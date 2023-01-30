Class tests.iris.beaker.unittests.TestCore Extends %UnitTest.TestCase
{

Method TestProjectPackageOnNew()
{
    Set tExpected = "dc.sample"
    Set core = ##class(iris.beaker.Core).%New(tExpected)
    Do $$$AssertEquals(core.ProjectPackage, tExpected, tExpected _ " = " _ core.ProjectPackage)
}

/// I'm not sure yet if this step is needed
Method TestEnvironmentNotOk()
{
    Set current = ^UnitTestRoot
    Set ^UnitTestRoot=""
    Do $$$AssertStatusNotOK(##class(iris.beaker.Core).EnvValidation())
    Set ^UnitTestRoot = current
}

/// I'm not sure yet if this step is needed
Method TestEnvironmentOk()
{
    Set current = ^UnitTestRoot
    Set ^UnitTestRoot="test"
    Do $$$AssertStatusOK(##class(iris.beaker.Core).EnvValidation())
    Set ^UnitTestRoot = current
}

Method TestBuildTestClass()
{
    Set className = "dc.sample.ObjectScript"
    Set tExpected = "%Dictionary.ClassDefinition"
    Do ##class(iris.beaker.Core).BuildTestClass(className, .tClass)
    Set tResult = $ClassName(tClass)
    Do $$$AssertEquals(tResult, tExpected, tExpected _ " = " _ tResult)
    Do $$$AssertNotEquals(tClass.Name, className, className _ " = " _ tClass.Name)
}

}
