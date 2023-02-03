Class tests.iris.tripleSlash.unittests.TestCore Extends %UnitTest.TestCase
{

Method TestProjectPackageOnNew()
{
    Set tExpected = "dc.sample"
    Set core = ##class(iris.tripleSlash.Core).%New(tExpected)
    Do $$$AssertEquals(core.ProjectPackage, tExpected, tExpected _ " = " _ core.ProjectPackage)
}

/// I'm not sure yet if this step is needed
Method TestEnvironmentNotOk()
{
    Set current = ^UnitTestRoot
    Set ^UnitTestRoot=""
    Do $$$AssertStatusNotOK(##class(iris.tripleSlash.Core).EnvValidation())
    Set ^UnitTestRoot = current
}

/// I'm not sure yet if this step is needed
Method TestEnvironmentOk()
{
    Set current = ^UnitTestRoot
    Set ^UnitTestRoot="test"
    Do $$$AssertStatusOK(##class(iris.tripleSlash.Core).EnvValidation())
    Set ^UnitTestRoot = current
}

Method TestBuildTestClass()
{
    Set className = "dc.sample.ObjectScript"
    Set tExpected = "%Dictionary.ClassDefinition"
    Do ##class(iris.tripleSlash.Core).BuildTestClass(className, .tClass)
    Set tResult = $ClassName(tClass)
    Do $$$AssertEquals(tResult, tExpected, tExpected _ " = " _ tResult)
    Do $$$AssertEquals(tClass.Super, "%UnitTest.TestCase", tExpected _ " = %UnitTest.TestCase" )
    Do $$$AssertNotEquals(tClass.Name, className, className _ " = " _ tClass.Name)
}

Method TestBuildTestMethod()
{
    Set tExpected = "%Dictionary.MethodDefinition"
    Set codeBlock = ##class(%ListOfDataTypes).%New()
    Do codeBlock.Insert("Set a = 1")
    Do ##class(iris.tripleSlash.Core).BuildTestMethod(.tMethod, "BuildMethod", codeBlock)
    Set tResult = $ClassName(tMethod)
    Do $$$AssertEquals(tResult, tExpected, tExpected _ " = " _ tResult)
    Do $$$AssertEquals(tMethod.Name, "TestBuildMethod", "TestBuildMethod"_ " = " _ tMethod.Name)
    Do $$$AssertNotTrue(tMethod.ClassMethod)
    Set tImplementation = tMethod.Implementation.Read()
    Set tExpected = "  "_codeBlock.GetAt(1)_$Char(13,10)
    Do $$$AssertEquals(tImplementation, tExpected, tImplementation _ "|" _tExpected)
}

}
