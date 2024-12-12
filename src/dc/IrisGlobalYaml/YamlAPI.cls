Class dc.IrisGlobalYaml.YamlAPI Extends dc.IrisGlobalYaml.Base
{

Parameter Version = "1.0.0";

Parameter YAMLCONTENTTYPE = "application/x-yaml";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>

<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />

<!-- Get all namespace globals -->
<Route Url="/globals/:namespace" Method="GET" Call="GetNamespaceGlobals"/>
<!-- GET method to return JSON for a given person id-->
<Route Url="/globals/:namespace/:globalname" Method="GET" Call="GetGlobalByName"/>
<!-- Set a global with values into a yaml -->
<Route Url="/globals/:namespace/:globalname" Method="POST" Call="SetGlobalWithYaml"/>
<!-- Delete a global by name -->
<Route Url="/globals/:namespace/:globalname" Method="DELETE" Call="DeleteGlobal"/>
<!-- Set a global with simple value -->
<Route Url="/globals/:namespace/:globalname" Method="PUT" Call="SetGlobalWithValue"/>

</Routes>
}

/// API general information
ClassMethod GetInfo() As %Status
{
  SET version = ..#Version
  SET info = {
    "version": (version)
  }
  RETURN ..%ProcessResult($$$OK, info)
}

/// Retreive all globals in a namespace into a yaml
ClassMethod GetNamespaceGlobals(namespace As %String) As %Status
{

    #dim tSC As %Status = $$$OK

    Set $NAMESPACE = namespace

    Set %response.ContentType = ..#YAMLCONTENTTYPE
    
    Write namespace_":",!

    SET NAME=""
    FOR I=1:1 {
        SET NAME=$ORDER(^$GLOBAL(NAME))
        If (NAME '= "") {
            WRITE " ",NAME_": ", $GET(@NAME), !
        }
        QUIT:NAME=""
        SET GLOBAL(I)=NAME
    }
    
    Quit tSC
}

/// Get the globals by name
ClassMethod GetGlobalByName(namespace As %String, globalname As %String) As %Status
{
	#dim tSC As %Status = $$$OK 
    
    Set $NAMESPACE = namespace

    Set %response.ContentType = ..#YAMLCONTENTTYPE
    
    Write namespace_":",!
    
    Write " ", globalname, ": ", $GET(@globalname)

    Quit tSC
}

/// Set globals using a yaml
ClassMethod SetGlobalWithYaml(namespace As %String, globalname As %String) As %Status
{
	#dim tSC As %Status = $$$OK
    
    Quit tSC
}

/// Update a record in dc.Sample.Person with id
ClassMethod DeleteGlobal(namespace As %String, globalname As %String) As %Status
{
	#dim tSC As %Status = $$$OK
    
    Set $NAMESPACE = namespace

    Kill @globalname

    Quit tSC
}

/// Delete a record with id in dc.Sample.Person
ClassMethod SetGlobalWithValue(namespace As %String, globalname As %String) As %Status
{
	#dim tSC As %Status = $$$OK
    
    Set $NAMESPACE = namespace

    If $EXTRACT(globalname,1) '= "^" {
        Set globalname = "^"_globalname
    }

    set @globalname = %request.Data("globalvalue", 1)

    Quit tSC
}

ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/iris-global-yaml"
  Set swagger.info.title = "InterSystems IRIS Globals editor using YAML"
  Set swagger.info.version = "1.0.0"
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

}
