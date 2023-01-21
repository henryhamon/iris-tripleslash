Class iris.beaker.Core Extends %RegisteredObject
{

Property ProjectPackage As %String;

Method %OnNew(pProjectPackage As %String = "") As %Status [ Private, ServerOnly = 1 ]
{
	Set:pProjectPackage'="" ..ProjectPackage = pProjectPackage
	Quit $$$OK
}

}
