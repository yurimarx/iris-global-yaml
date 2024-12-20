Class dc.IrisGlobalYaml.YamlAPI Extends dc.IrisGlobalYaml.Base
{

Parameter Version = "1.0.0";

Parameter YAMLCONTENTTYPE = "application/x-yaml";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>


<!-- Get all namespace globals -->
<Route Url="/globals/:namespace" Method="GET" Call="GetNamespaceGlobals"/>
<!-- GET method to return global from globalname -->
<Route Url="/globals/:namespace/:globalname" Method="GET" Call="GetGlobalByName"/>
<!-- Set a global with values into a yaml -->
<Route Url="/globals/:namespace" Method="POST" Call="SetGlobalWithYaml"/>
<!-- Delete a global by name -->
<Route Url="/globals/:namespace/:globalname" Method="DELETE" Call="DeleteGlobal"/>
<!-- Set a global with simple value -->
<Route Url="/globals/:namespace/:globalname" Method="PUT" Call="SetGlobalWithValue"/>
<!-- Get a global yaml content -->
<Route Url="/globals/yaml/:namespace/:globalname" Method="GET" Call="GetGlobalYamlContent"/>


<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />


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

    Try {
        
        Set $NAMESPACE = namespace

        Set %response.ContentType = ..#YAMLCONTENTTYPE
        
        Write "# IRIS-Global-YAML", !
        
        Write namespace_":", !

        SET NAME=""
        FOR I=1:1 {
            SET NAME=$ORDER(^$GLOBAL(NAME))
            If (NAME '= "") {
                WRITE " ",NAME_": ", $GET(@NAME), !
            }
            QUIT:NAME=""
            SET GLOBAL(I)=NAME
        }

    } Catch ex {
        Set %response.Status = "500"
        Set tSC=ex.AsStatus()
    }
    
    Quit tSC
}

/// Return a global content as yaml
ClassMethod GetGlobalYamlContent(namespace As %String, globalname As %String) As %Status
{
    #dim tSC As %Status = $$$OK 
    
    Try {
        
        Set $NAMESPACE = namespace

        Set %response.ContentType = ..#YAMLCONTENTTYPE

        Write "# IRIS-Global-YAML", !

        Write namespace_":", !

        Set list = ..GetSubscriptsList(globalname)

        Set iter = list.%GetIterator()

        Set wroteSubscripts = 0
        
        While iter.%GetNext(.key, .value) {
            If $FIND(value, "(") > 0 {
                If wroteSubscripts = 0 {
                    Write "        subscripts:", !
                    Set wroteSubscripts = 1
                }
                Write "            - ", value, ": ", $GET(@value), !
            } Else {
                Write "    ", value, ": ", !
                Write "        value: ", $GET(@value), !
            }
        }
    }
    Catch ex {
        Set tSC=ex.AsStatus()
    }
    
    Quit tSC
}

/// Get the globals by name
ClassMethod GetGlobalByName(namespace As %String, globalname As %String) As %Status
{
	#dim tSC As %Status = $$$OK 
    
    Try {
        
        Set $NAMESPACE = namespace

        Set %response.ContentType = ..#YAMLCONTENTTYPE
        
        Write namespace_":",!
        
        Write " ", globalname, ": ", $GET(@globalname)
    }
    Catch ex {
        Set tSC=ex.AsStatus()
    }

    Quit tSC
}

/// Set globals using a yaml
ClassMethod SetGlobalWithYaml(namespace As %String) As %Status
{
	Try {
        Set source = %request.GetMimeData("file")
        Set destination=##class(%Stream.FileBinary).%New()
        Set destination.Filename="/tmp/"_source.FileName
        set tSC=destination.CopyFrom(source) //reader open the file
        set result=destination.%Save()
        
        Set yml = ##class(%File).%New("/tmp/"_source.FileName)
        Set tSC = yml.Open("RU")
        Set globalname = ""
        Set globalvalue = ""
        Set hasSubscripts = 0
        Set subscriptsList = []

        While (yml.AtEnd = 0) {
            Set line = yml.ReadLine(,.tSC)
            If $FIND(line, namespace_":") > 1 {
                set $namespace = namespace
            }

            If ($FIND(line, "    ") = 5) & ($FIND(line, "^") = 6) {
                Set globalname = $ZSTRIP(line,"<>W")
                Set globalname = $EXTRACT(globalname, 1, $LENGTH(globalname)-1)
            }

            If ($LENGTH(globalname) > 1) & ($FIND(line, "       value:") > 1) {
                Set globalvalue = $PIECE(line, ":", 2)
                Set globalvalue = $ZSTRIP(globalvalue,"<>W")
            } 

            If $FIND(line, "subscripts:") > 1 {
                Set hasSubscripts = 1
            }

            If (hasSubscripts = 1) & ($FIND(line, "- ^") > 1) {
                Set subscript = $EXTRACT(line, $FIND(line, "- "), $LENGTH(line))
                Do subscriptsList.%Push(subscript)
            }

            if $$$ISERR(tSC) { 
                do $system.Status.DisplayError(tSC) 
            }
        }

        Set @globalname = globalvalue

        Set iter = subscriptsList.%GetIterator()
        While iter.%GetNext(.key, .value) { 
            Set subName = $PIECE(value, ":", 1)
            Set subValue = $PIECE(value, ":", 2)
            Set @subName = $ZSTRIP(subValue,"<>W")
        }

        Set %response.Headers("Access-Control-Allow-Origin")="*"
        Set %response.ContentType = ..#YAMLCONTENTTYPE
        Set %response.Status = "200"
        Set tSC=$$$OK
   
    //returns error message to the user
    } Catch e {
        Set tSC=e.AsStatus()
        Set %response.Status = "500"
        Set pOutput = tSC
    }
 
    Quit tSC
}

/// Delete a global
ClassMethod DeleteGlobal(namespace As %String, globalname As %String) As %Status
{
	#dim tSC As %Status = $$$OK
    
    Try {
        
        Set $NAMESPACE = namespace

        Kill @globalname
        
    } Catch ex {
        Set tSC=ex.AsStatus()
    }

    Quit tSC
}

/// Set the global with a simple value from the parameter globalvalue
ClassMethod SetGlobalWithValue(namespace As %String, globalname As %String) As %Status
{
	#dim tSC As %Status = $$$OK
    
    Try {
        Set $NAMESPACE = namespace

        If $EXTRACT(globalname,1) '= "^" {
            Set globalname = "^"_globalname
        }

        set @globalname = %request.Data("globalvalue", 1)
        
    } Catch ex {
        Set tSC=ex.AsStatus()
    }

    Quit tSC
}

/// Get swagger documentation to the this API
ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/iris-global-yaml"
  Set swagger.info.title = "API for the InterSystems IRIS Globals editor using YAML"
  Set swagger.info.version = "1.0.0"
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

/// Support method to get global subscripts list
ClassMethod GetSubscriptsList(globalname As %String) As %DynamicArray
{
    
    Set list = []

    Try {
        
        Set globalRef = globalname
        
        If globalRef '= "" {
            Do list.%Push(globalRef) 
        }
        
        For { 
            Set globalRef=$QUERY(@globalRef)
            
            If globalRef '= "" {
                Do list.%Push(globalRef) 
            }
            
            Quit:globalRef=""
        }   
    
    }
    Catch ex {
        Set list = []
    }

    Return list
}

}
