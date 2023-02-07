Class iris.tripleSlash.Core Extends %RegisteredObject
{

Parameter TripleSlashPackage = "iris.tripleSlash.tst.";

Parameter DefaultUnitTestRoot = "/irisrun/repo";

Property ProjectPackage As %String;

Property KeepTestClasses As %Boolean [ InitialExpression = 0 ];

Property KeepTestFile As %Boolean [ InitialExpression = 0 ];

Property TestPath As %String [ InitialExpression = "/tests" ];

Property Hash As %String [ Private ];

/// Create an instance for generation of unit test from method documentation
/// 
/// Tests:
/// <example>
/// Set tExpected = "dc.sample"
/// Set core = ##class(iris.beaker.Core).%New(tExpected)
/// Write core.ProjectPackage
/// tExpected, tExpected _ " = " _ core.ProjectPackage
/// </example>
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

/// Check if the unit test root folder global ^UnitTestRoot is set correctly
/// 
/// <example>
/// Set current = ^UnitTestRoot
/// Set ^UnitTestRoot = ""
/// Do ##class(iris.beaker.Core).EnvValidation()
/// $$$NotOK
/// Set ^UnitTestRoot = current
/// </example>
ClassMethod EnvValidation() As %Status
{
    Return:($Get(^UnitTestRoot)="") $$$ERROR(5002, "UnitTestRoot Not Found")
    Return $$$OK
}

/// Generates unit tests for methods with tests annotated in <example></example> tag.
/// You can pass a specific class or a package name
/// 
/// <example>
/// Do ##class(iris.beaker.Core).Execute()
/// $$$NotOK
/// Do ##class(iris.beaker.Core).Execute()
/// $$$OK
/// </example>
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
            $$$ThrowOnError(##class(Parser).AssertOk(.codeBlock, rs.Class))
            $$$ThrowOnError(##class(Parser).AssertEql(.codeBlock, rs.Class))
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
    Order By sequenceNumber
}

Query FindByPackage(packageName As %String) As %SQLQuery [ SqlProc ]
{
    Select Parent As Class, Name As Method, Description As Block 
	FROM %Dictionary.MethodDefinition
	Where parent %StartsWith :packageName
	And Abstract = 0
	And (Description like '%Examples%' OR Description like '%<example>%' OR Description like '%<pre>%')
    Order By Parent, sequenceNumber
}

ClassMethod BuildTestClass(className As %String, Output testClass As %Dictionary.ClassDefinition) As %Status
{
	Set TestClassName = ..#TripleSlashPackage _ $Piece(className, ".", *)
    Set testClass = ##class(%Dictionary.ClassDefinition).%New(TestClassName)
    Set testClass.Super = "%UnitTest.TestCase"
    set st = $$$OK
    Try {
        Set class = ##class(%Dictionary.ClassDefinition).%OpenId(className)
        If (($IsObject(class))&&(class.Description'="")) {
            $$$ThrowOnError(..AddSetup(.testClass, class.Description))
        }
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Return st
}

ClassMethod BuildTestMethod(Output testMethod As %Dictionary.MethodDefinition, name As %String, codeBlock As %ListOfDataTypes, prefix As %String = "Test") As %Status
{
    Set st = $$$OK
    Try {
        Set testMethod = ##class(%Dictionary.MethodDefinition).%New()
        Set testMethod.Name = prefix_name
        For idx=1:1:codeBlock.Count() {
            Continue:(codeBlock.GetAt(idx)="")
            Do testMethod.Implementation.WriteLine("  "_codeBlock.GetAt(idx))
        }
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Return st
}

ClassMethod AddSetup(ByRef class As %Dictionary.ClassDefinition, description As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set allEvents = $ListBuild("beginAll", "afterAll", "beforeOne", "afterOne")
        Set ptr = 0
        While $ListNext(allEvents, ptr, event) {
            Set codeBlock = ##class(%ListOfDataTypes).%New()
            Set eventCode = ##class(Parser).ExtractContent(event, .description)
            $$$ThrowOnError(##class(Parser).StrToList(eventCode, .codeBlock))
            Continue:(codeBlock.Count() = 0)
            Set plural = ""
            Set:($Find(event,"All")) plural = "s"
            Set event = $ZConvert($Extract(event, 1, 1), "U")_$Extract(event, 2, *)
            Set mtdName = event_"Test"_plural
            $$$ThrowOnError(..BuildTestMethod(.testMethod, mtdName, codeBlock, "On"))
            Set exists = $$$NO
            For idx=1:1:class.Methods.Count() {
                Set:(class.Methods.GetAt(idx).Name = mtdName) exists = $$$YES
            }
            Do:('exists) class.Methods.Insert(testMethod)
        }
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Return tSC
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
