Class iris.beaker.Core Extends %RegisteredObject
{

Property ProjectPackage As %String;

Method %OnNew(pProjectPackage As %String = "") As %Status [ Private, ServerOnly = 1 ]
{
	Set:pProjectPackage'="" ..ProjectPackage = pProjectPackage
	Return $$$OK
}

ClassMethod EnvValidation() As %Status
{
    Return:($Get(^UnitTestRoot)="") $$$ERROR(5002, "UnitTestRoot Not Found")
    Return $$$OK
}

ClassMethod Execute(package As %String = "", className As %String = "") As %Status
{
    Set tSC = $$$OK
    Set:(package'="") className = ""
    Try {
        $$$ThrowOnError(..EnvValidation())
        Set:(package'="") rs = ..FindByPackageFunc(package)
        Set:(className'="") rs = ..FindByClassFunc(className)
        While rs.%Next() {
            /// Parser
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

}
