<#
Function name: IsRecordAlreadyStored
Description: Takes as an input a hash value and checks if it is already stored on the Malware Repository  
Function calls: -
Input: $hash
Output: $true/$false
#>

function IsRecordAlreadyStored() {
	param(
        [Parameter( Mandatory = $True)] [string]$hash
    )

   $CurrentPath= (Get-Location).path
   $DBPath = $CurrentPath+"\MalwareRepository.db"
   $Database = [LiteDB.LiteDatabase]::new($DBPath)
   $Collection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)
   
   $Entry = "Hash ="+ "'"+$hash+"'" 
   $Result = $Collection.Find($Entry) 
   
  if (($Result |Out-String) -eq ""   ) {
	$Database.Dispose()
	return $false
  }
  else {
	$Database.Dispose()
	return $true   
  }

  
}



<#
Function name: BuildRecordScript
Description: Takes as an input an array of strings (layers) and creates a DB record
Function calls: Get-ObfuscationType
Input: $ObfuscationLayers, $MalwareType, $Actions, $Hash
Output: $Record
#>

function BuildRecordScript() {
	param(
        [Parameter( Mandatory = $True)] [string[]] $ObfuscationLayers,
		[Parameter( Mandatory = $True)] [string]  $MalwareType,
		[Parameter( Mandatory = $False)] [string] $Actions,
        [Parameter( Mandatory = $True)] [string] $Hash
		
	)
	
   $Record  = New-Object System.Collections.Generic.List[System.Object]
   $Original = $ObfuscationLayers[0] 
   
   $NumberOfLayers = $ObfuscationLayers.Count  
   $LastLayerIndex = $NumberOfLayers - 1 
   
   $Plainscript =    $ObfuscationLayers[$LastLayerIndex]
   
   
   $Base64LayersCount = 0
   $StringBasedLayersCount = 0
   $EncodedLayersCount = 0
   $CompressedLayersCount = 0

   ForEach ($layer in $ObfuscationLayers){
            
			if ( $layer  -ne $Plainscript ) {
			  $ObfuscationType =  GetObfuscationType $layer
			 
			  switch ( $ObfuscationType ) {
                               "Base64"        { $Base64LayersCount++      }
                               "String-Based"  { $StringBasedLayersCount++ }
	                           "Encoded"       { $EncodedLayersCount++     }
							   "Compressed"    { $CompressedLayersCount++  }
               }
			 
            }
    }

	$DownloadPath = " "
	$ItemsInvoked = " "
	$Sleep = " "
	$ProcessStarted = " "
    
	$DownloadPathPattern = [regex]  "and\ssave\sto\:(.){1,}"
	$ItemsInvokedPattern = [regex]  "to\sinvoke\s(.){1,}"
	$SleepPattern = [regex]         "to\ssleep\sfor\s(.){1,}"
	$ProcessStartedPattern = [regex] "to\sexecute\sthe\sprocess\s(.){1,}"
	
	$DownloadPathMatches =  $DownloadPathPattern.matches($Actions)
	$ItemsInvokedMatches =  $ItemsInvokedPattern.matches($Actions)
	$SleepMatches =  $SleepPattern.matches($Actions)
	$ProcessStartedMatches = $ProcessStartedPattern.matches($Actions)
	
	
		
    foreach ($match in  $DownloadPathMatches )  { $DownloadPath += ($match.value).replace("and save to:" , "") }
    foreach ($match in  $ItemsInvokedMatches )  { $ItemsInvoked += ($match.value).replace("to invoke ", "")    }
	foreach ($match in  $SleepMatches )         { $Sleep += ($match.value).replace("to sleep for ","").replace("seconds","s")  }
	foreach ($match in  $ProcessStartedMatches ){ $ProcessStarted += ($match.value).replace("to execute the process ","") }
    
	
	

    $Record.Add($Original)
    $Record.Add($Plainscript)
	$Record.Add($Base64LayersCount)
	$Record.Add($StringBasedLayersCount)
	$Record.Add($EncodedLayersCount)
	$Record.Add($CompressedLayersCount)
	$Record.Add($MalwareType)
	$Record.Add($DownloadPath)
	$Record.Add($ItemsInvoked)
	$Record.Add($Sleep)
	$Record.Add($ProcessStarted)
	$Record.Add($Hash)
	
	
	
	return $Record
}


<#
Function name: BuildRecordUrl
Description: Takes as an input a string ( url ), its status and a hash value and creates a DB record
Function calls: 
Input: $Url , $Status , Hash 
Output: $Record
#>

function BuildRecordUrl() {
	param(
        [Parameter( Mandatory = $True)] [string]$Url,
        [Parameter( Mandatory = $True)] [string]$Status,
		[Parameter( Mandatory = $True)] [string]$Hash
	)
	
   $Record  = New-Object System.Collections.Generic.List[System.Object]
   
   
   $Status = $Status.replace($Url,"").replace(" -  ","").replace("[ 0 ] Cannot connect to:","cannot connect") 
 
    $Record.Add($Url)
    $Record.Add($Status)
	$Record.Add($Hash)
	
	
	return $Record
}


<#
Function name: BuildRecordShellcode
Description: Takes as an input a string ( shellcode info) and a hash value and creates a DB record
Function calls: 
Input: $ShellcodeInfo , $Hash 
Output: $Record
#>

function BuildRecordShellcode() {
	param(
        [Parameter( Mandatory = $True)] [string]$ShellcodeData,
		[Parameter( Mandatory = $True)] [string]$Hash
	)
	
   $Record  = New-Object System.Collections.Generic.List[System.Object]
   
   $String = ($ShellcodeData.replace("`r`n","")) |Out-String
  
   $pattern = [regex] "uid\=7\&pid\=152\)\:[A-Fa-f0-9]{8,}Execution"
   $matches = $pattern.matches($String)
   
   $HexString = ($matches[0]).Value
   $HexString = $HexString.replace("uid=7&pid=152):","").replace("Execution","")
   
 
    $Record.Add($HexString)
	$Record.Add($Hash)
	
	
	return $Record
}




<#
Function name: StoreRecordScript
Description: Takes as an input an array of strings (record script) and stores it on the Malware Repository
Function calls: -
Input:$Record
Output: -
#>

function StoreRecordScript() {
	param(
        [Parameter( Mandatory = $True)] [string[]]$Record
    )
	
	
  $CurrentPath= (Get-Location).path
  $DBPath = $CurrentPath+"\MalwareRepository.db"
  $Database = [LiteDB.LiteDatabase]::new($DBPath)
  $Collection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)

   
   
  $BsonDocument = [LiteDB.BsonDocument]::new()   
   
   
  $BsonDocument["Original"]    =  $Record[0]
  $BsonDocument["Plainscript"] =  $Record[1]
  $BsonDocument["Base64"]      =  $Record[2]  
  $BsonDocument["StringBased"] =  $Record[3]
  $BsonDocument["Encoded"]     =  $Record[4]
  $BsonDocument["Compressed"]  =  $Record[5]
  $BsonDocument["Type"]        =  $Record[6]
  $BsonDocument["Download"]    =  $Record[7]
  $BsonDocument["Invoke"]      =  $Record[8]
  $BsonDocument["Sleep"]       =  $Record[9]
  $BsonDocument["Execute"]     =  $Record[10]
  $BsonDocument["Hash"]        =  $Record[11] 

  $null = $Collection.Insert($BsonDocument)
  $Database.Dispose()
 
  return
}



<#
Function name: StoreRecordUrl
Description: Takes as an input an array of strings (record url) and stores it on the Malware Repository
Function calls: -
Input:$Record
Output: -
#>

function StoreRecordUrl() {
	param(
        [Parameter( Mandatory = $True)] [string[]]$Record
    )
	
	
  $CurrentPath= (Get-Location).path
  $DBPath = $CurrentPath+"\MalwareRepository.db"
  $Database = [LiteDB.LiteDatabase]::new($DBPath)
  $Collection = $Database.GetCollection("URLs",[LiteDB.BsonAutoId]::Int64)

   
   
  $BsonDocument = [LiteDB.BsonDocument]::new()   
   
   
  $BsonDocument["Url"]       =  $Record[0]
  $BsonDocument["Status"]    =  $Record[1]
  $BsonDocument["Hash"]      =  $Record[2]  
 

  $null = $Collection.Insert($BsonDocument)
  $Database.Dispose()
 
  return
}



<#
Function name: StoreRecordShellcode
Description: Takes as an input an array of strings (record shellcode) and stores it on the Malware Repository
Function calls: -
Input:$Record
Output: -
#>

function StoreRecordShellcode() {
	param(
        [Parameter( Mandatory = $True)] [string[]]$Record
    )
	
	
  $CurrentPath= (Get-Location).path
  $DBPath = $CurrentPath+"\MalwareRepository.db"
  $Database = [LiteDB.LiteDatabase]::new($DBPath)
  
  $Collection = $Database.GetCollection("Shellcodes",[LiteDB.BsonAutoId]::Int64)

  $BsonDocument = [LiteDB.BsonDocument]::new()   
      
  $BsonDocument["HexString"] =  $Record[0]
  $BsonDocument["Hash"]      =  $Record[1]  
 
  $null = $Collection.Insert($BsonDocument)
  $Database.Dispose()
 
  return
}


<#
Function name: UpdateRecordScript
Description: Takes as an input a hash value, some malware info, and updates the associated record on the Malware Repository
Function calls: -
Input:$Record
Output: -
#>

function UpdateRecordScript() {
	param(
        [Parameter( Mandatory = $True)] [string]$Hash,
		[Parameter( Mandatory = $True)] [string]$MalwareType,
        [Parameter( Mandatory = $True)] [string[]]$ObfuscationLayers
	)
	
	
  $CurrentPath= (Get-Location).path
  $DBPath = $CurrentPath+"\MalwareRepository.db"
  $DBArg = "Filename='"+$DBPath+"';ReadOnly='$false'"
  $Database = [LiteDB.LiteDatabase]::new($DBArg)
  $Collection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)

  $Entry = "Hash ="+ "'"+$Hash+"'" 
  $id = (($Collection.Find($Entry)).Value[0]).RawValue
  $Result = $Collection.FindById($id)
  
  $NumberOfLayers = $ObfuscationLayers.Count  
  $LastLayerIndex = $NumberOfLayers - 1 
  $Plainscript =    $ObfuscationLayers[$LastLayerIndex]
   
   
   $Base64LayersCount = 0
   $StringBasedLayersCount = 0
   $EncodedLayersCount = 0
   $CompressedLayersCount = 0

   ForEach ($layer in $ObfuscationLayers){
            
			if ( $layer  -ne $Plainscript ) {
			  $ObfuscationType =  GetObfuscationType $layer
			 
			  switch ( $ObfuscationType ) {
                               "Base64"        { $Base64LayersCount++      }
                               "String-Based"  { $StringBasedLayersCount++ }
	                           "Encoded"       { $EncodedLayersCount++     }
							   "Compressed"    { $CompressedLayersCount++  }
               }
			 
            }
    }


  
   $Result["Plainscript"] = $Plainscript
   $Result["Base64"]      = $Base64LayersCount
   $Result["StringBased"] = $StringBasedLayersCount
   $Result["Encoded"]     = $EncodedLayersCount
   $Result["Compressed"]  = $CompressedLayersCount
   $Result["Type"]        = $MalwareType
   $null = $Collection.Update($Result)  

   $Database.Dispose()
 
  return
}


<#
Function name: UpdateRecordUrl
Description: Takes as an input an array of strings (record url) and updates it on the Malware Repository
Function calls: -
Input:$Record
Output: -
#>

function UpdateRecordUrl() {
	param(
        [Parameter( Mandatory = $True)] [string[]]$Record
    )
	
	
  $CurrentPath= (Get-Location).path
  $DBPath = $CurrentPath+"\MalwareRepository.db"
  $DBArg = "Filename='"+$DBPath+"';ReadOnly='$false'"
  $Database = [LiteDB.LiteDatabase]::new($DBArg)
  $Collection = $Database.GetCollection("URLs",[LiteDB.BsonAutoId]::Int64)

  $Hash = $Record[2]
  $Entry = "Hash ="+ "'"+$Hash+"'" 
  $Find = $Collection.Find($Entry)
  
  if( ($Find |Out-String) -ne ""  ) {
  $id = ($Find.Value[0]).RawValue
  $Result = $Collection.FindById($id)
  
  $Result["Url"]    = $Record[0]
  $Result["Status"] = $Record[1]
  $null = $Collection.Update($Result) 
  
  }
  
  else { 
  
     $BsonDocument = [LiteDB.BsonDocument]::new()   
     $BsonDocument["Url"]       =  $Record[0]
     $BsonDocument["Status"]    =  $Record[1]
     $BsonDocument["Hash"]      =  $Record[2]  
     $null = $Collection.Insert($BsonDocument)
  
  }
  

  
  $Database.Dispose()
 
  return
}

<#
Function name: UpdateRecordShellcode
Description: Takes as an input an array of strings (record shellcode) and updates it on the Malware Repository
Function calls: -
Input:$Record
Output: -
#>

function UpdateRecordShellcode() {
	param(
        [Parameter( Mandatory = $True)] [string[]]$Record
    )
	
	
  $CurrentPath= (Get-Location).path
  $DBPath = $CurrentPath+"\MalwareRepository.db"
  $DBArg = "Filename='"+$DBPath+"';ReadOnly='$false'"
  $Database = [LiteDB.LiteDatabase]::new($DBArg)
  $Collection = $Database.GetCollection("Shellcodes",[LiteDB.BsonAutoId]::Int64)

  $Hash = $Record[1]
  $Entry = "Hash ="+ "'"+$Hash+"'"
  $Find = $Collection.Find($Entry)
  
  if( ($Find |Out-String) -ne ""  ) {
     $id = ($Find.Value[0]).RawValue
     $Result = $Collection.FindById($id)
     $Result["HexString"]    = $Record[0] 
     $null = $Collection.Update($Result) 
  
   }
   
   else { 
      
    $BsonDocument = [LiteDB.BsonDocument]::new()   
    $BsonDocument["HexString"] =  $Record[0]
    $BsonDocument["Hash"]      =  $Record[1]  
    $null = $Collection.Insert($BsonDocument)
    
  }

  
  $Database.Dispose()
 
  return
}

