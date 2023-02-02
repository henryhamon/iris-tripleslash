Class iris.tripleSlash.Core Extends %RegisteredObject
{

Parameter TripleSlashPackage = "iris.tripleSlash.tst.";

Parameter DefaultUnitTestRoot = "/irisrun/repo";

Property ProjectPackage As %String;

Property KeepTestClasses As %Boolean [ InitialExpression = 0 ];

Property KeepTestFile As %Boolean [ InitialExpression = 0 ];

Property TestPath As %String [ InitialExpression = "/tests" ];

Property Hash As %String [ Private ];

Method %OnNew(projectPackage As %String = "", testPath As %String = "", keepTestClasses As %Boolean = "", keepTestFile As %Boolean = "") As %Status [ Private, ServerOnly = 1 ]
{
	Set:(projectPackage'="") ..ProjectPackage = projectPackage
	Set:(testPath'="") ..TestPath = testPath
	Set:(keepTestClasses'="") ..KeepTestClasses = keepTestClasses
	Set:(keepTestFile'="") ..KeepTestFile = keepTestFile
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
    Try {
        //$$$ThrowOnError(..EnvValidation())
        $$$ThrowOnError(..PrepareTestClass(className))
        $$$ThrowOnError(..ExportTestPackage())
        $$$ThrowOnError(..RunTest())
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Return st
}

Method PrepareTestClass(className As %String = "") As %Status [ Private ]
{
    Set st = $$$OK
    Set:(..ProjectPackage'="") className = ""
    Set klass = ""
    Set testClass = ""
    Try {
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
	Set className = ..#TripleSlashPackage _ $Piece(className, ".", *)
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

Method RunTest(p, pTestPath = "/tests") As %Status [ Private ]
{
    Set st = $$$OK
    Set unitTestRoot = $Get(^UnitTestRoot)
    Set:(unitTestRoot="") ^UnitTestRoot = ..#DefaultUnitTestRoot
    Set qualifiers = ""
    Try {
        Set:('..KeepTestFile) qualifiers = qualifiers _ "/delete"
        Do ##class(%UnitTest.Manager).RunTest(pTestPath, qualifiers)
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Kill:(unitTestRoot = "") ^UnitTestRoot
    Return st
}

Method ExportTestPackage() As %Status [ Private ]
{
    Set unitTestRoot = $Get(^UnitTestRoot)
    Set:(unitTestRoot="") unitTestRoot = ..#DefaultUnitTestRoot
    Set path = unitTestRoot _ ..TestPath
    Return $system.OBJ.ExportPackage($Extract(..#TripleSlashPackage, 1, *-1), path _ ..Hash _".xml")
}

}
