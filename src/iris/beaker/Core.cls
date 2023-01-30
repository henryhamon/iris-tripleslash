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
    Set tSC = $$$OK
    Set:(..ProjectPackage'="") className = ""
    Try {
        $$$ThrowOnError(..EnvValidation())
        Set:(className="") rs = ..FindByPackageFunc(..ProjectPackage)
        Set:(className'="") rs = ..FindByClassFunc(className)
        While rs.%Next() {
            /// Parser
            $$$ThrowOnError(##class(Parser).GetCodeBlock(rs.Block, .codeBlock))
        }
    } Catch tException {

    }
    Return tSC
}

Query FindByClass(className As %String) As %SQLQuery [ SqlProc ]
{
    Select Parent As Class, Name As Method, Description As Block 
	FROM %Dictionary.MethodDefinition
	Where parent = :className
	And Abstract = 0
	And (Description like '%Examples%' OR Description like '%<example>%')
}

Query FindByPackage(packageName As %String) As %SQLQuery [ SqlProc ]
{
    Select Parent As Class, Name As Method, Description As Block 
	FROM %Dictionary.MethodDefinition
	Where parent %StartsWith :packageName
	And Abstract = 0
	And (Description like '%Examples%' OR Description like '%<example>%')
}

ClassMethod BuildTestClass(className As %String, Output testClass As %Dictionary.ClassDefinition)
{
	Set className = ..#BeakerPackager _ $Piece(className, ".", *-1)
    Set testClass = ##class(%Dictionary.ClassDefinition).%New(className)
}

}
