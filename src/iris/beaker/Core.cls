Class iris.beaker.Core Extends %RegisteredObject
{

Parameter BeakerPackager = "iris.beaker.tst.";

Property ProjectPackage As %String;

Property Hash As %String [ Private ];

Method %OnNew(pProjectPackage As %String = "") As %Status [ Private, ServerOnly = 1 ]
{
	Set:pProjectPackage'="" ..ProjectPackage = pProjectPackage
	Set ..Hash = ""
	For i=1:1:10 {
		Set ..Hash = ..Hash _ $Char($Random(26)+97)
	}
	Return $$$OK
}

ClassMethod EnvValidation() As %Status
{
    Return:($Get(^UnitTestRoot)="") $$$ERROR(5002, "UnitTestRoot Not Found")
    Return $$$OK
}

Method Execute(className As %String = "") As %Status
{
    Set st = $$$OK
    Set:(..ProjectPackage'="") className = ""
    Set klass = ""
    Set testClass = ""
    Try {
        //$$$ThrowOnError(..EnvValidation())
        Set:(className="") rs = ..FindByPackageFunc(..ProjectPackage)
        Set:(className'="") rs = ..FindByClassFunc(className)
        While rs.%Next() {
            If (klass'=rs.Class) {
                Do:($IsObject(testClass)) testClass.%Save()
                Set klass = rs.Class
                Kill testClass
                Do ..BuildTestClass(rs.Class, .testClass)
            }
            /// Parser
            $$$ThrowOnError(##class(Parser).GetCodeBlock(rs.Block, .codeBlock))
            $$$ThrowOnError(##class(Parser).AssertOk(.codeBlock))
            $$$ThrowOnError(##class(Parser).AssertEql(.codeBlock))
            $$$ThrowOnError(..BuildTestMethod(.testMethod, rs.Method, codeBlock))
            Do testClass.Methods.Insert(testMethod)
        }
        Do:($IsObject(testClass)) testClass.%Save()
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Return st
}

Query FindByClass(className As %String) As %SQLQuery [ SqlProc ]
{
    Select Parent As Class, Name As Method, Description As Block 
	FROM %Dictionary.MethodDefinition
	Where parent = :className
	And Abstract = 0
	And (Description like '%Examples%' OR Description like '%<example>%' OR Description like '%<pre>%')
}

Query FindByPackage(packageName As %String) As %SQLQuery [ SqlProc ]
{
    Select Parent As Class, Name As Method, Description As Block 
	FROM %Dictionary.MethodDefinition
	Where parent %StartsWith :packageName
	And Abstract = 0
	And (Description like '%Examples%' OR Description like '%<example>%' OR Description like '%<pre>%')
    Group By Parent
}

ClassMethod BuildTestClass(className As %String, Output testClass As %Dictionary.ClassDefinition)
{
	Set className = ..#BeakerPackager _ $Piece(className, ".", *)
    Set testClass = ##class(%Dictionary.ClassDefinition).%New(className)
    Set testClass.Super = "%UnitTest.TestCase"
}

ClassMethod BuildTestMethod(Output testMethod As %Dictionary.MethodDefinition, name As %String, codeBlock As %ListOfDataTypes) As %Status
{
    Set st = $$$OK
    Try {
        Set testMethod = ##class(%Dictionary.MethodDefinition).%New()
        Set testMethod.Name = "Test"_name
        For idx=1:1:codeBlock.Count() {
            Continue:(codeBlock.GetAt(idx)="")
            Do testMethod.Implementation.WriteLine("  "_codeBlock.GetAt(idx))
        }
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Return st
}

ClassMethod RunTest(pUnitTestRoot As %String = "/irisrun/repo", pTestPath = "/tests") As %Status
{
    Set st = $$$OK
    Set unitTestRoot = $G(^UnitTestRoot)
    Try {
        Set ^UnitTestRoot = pUnitTestRoot
        Do ##class(%UnitTest.Manager).RunTest(pTestPath)
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Set:(unitTestRoot '= "") ^UnitTestRoot = unitTestRoot
    Kill:(unitTestRoot = "") ^UnitTestRoot
    Return st
}

}
