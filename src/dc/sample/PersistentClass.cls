/// <beforeOne>
/// Set obj = ##class(dc.sample.PersistentClass).%New()
/// Set obj.Test = "Setup"
/// Do obj.%Save()
/// </beforeOne>
/// 
/// <afterOne>
/// Do ##class(dc.sample.PersistentClass).%KillExtent()
/// </afterOne>
Class dc.sample.PersistentClass Extends %Persistent
{

Property Test As %VarString;

/// Empty Test
/// <pre>
/// Do ##class(dc.sample.PersistentClass).CreateRecord()
/// $$$OK
/// </pre>
/// Another test
/// <pre>
/// Set var = 1
/// Write var
/// 1
/// </pre>
ClassMethod CreateRecord(ByRef id As %Integer) As %Status
{
    set sc=$$$OK
    set objPC=..%New()
    set objPC.Test="Test string"
    set sc=objPC.%Save()
    set id=objPC.%Id()
    return sc
}

/// opens the record by id and reads its property
/// <pre>
/// W 1
/// 1
/// </pre>
ClassMethod ReadProperty(id As %Integer) As %Status
{
    Set sc = $$$OK
    #dim obj as dc.sample.PersistentClass
    set obj=..%OpenId(id,,.sc)
    if $ISOBJECT(obj) write obj.Test
    Return sc
}

Storage Default
{
<Data name="PersistentClassDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Test</Value>
</Value>
</Data>
<DataLocation>^dc.Package4C8F.PersistentC1A93D</DataLocation>
<DefaultData>PersistentClassDefaultData</DefaultData>
<IdLocation>^dc.Package4C8F.PersistentC1A93D</IdLocation>
<IndexLocation>^dc.Package4C8F.PersistentC1A93I</IndexLocation>
<StreamLocation>^dc.Package4C8F.PersistentC1A93S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
