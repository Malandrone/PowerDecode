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
   
   $String = ($ShellcodeData.replace("`n","")) |Out-String
   
   $pattern = [regex] "uid\=7\&pid\=152\)\:[A-Fa-f0-9]{8,}##########"
   $matches = $pattern.matches($String)
   
   $HexString = ($matches[0]).Value
   $HexString = $HexString.replace("uid=7&pid=152):","").replace("##########","")
   
   
   $pattern = [regex]  "\n[0-9a-f]{6,6}\s(.{1,})"
   $matches = $pattern.matches($ShellcodeData)
   
   $Actions = "-"
   if($matches.count -gt 0) {
	    $Actions = ""
		foreach ($match in $matches) {
        $Actions += ($match.value) | Out-String
        }
   }
   
   
   $Record.Add($HexString)
   $Record.Add($Actions)
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
  $BsonDocument["Actions"]   =  $Record[1]
  $BsonDocument["Hash"]      =  $Record[2]  
 
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

  $Hash = $Record[2]
  $Entry = "Hash ="+ "'"+$Hash+"'"
  $Find = $Collection.Find($Entry)
  
  if( ($Find |Out-String) -ne ""  ) {
     $id = ($Find.Value[0]).RawValue
     $Result = $Collection.FindById($id)
     $Result["HexString"]  = $Record[0]
     $Result["Actions"]    = $Record[1]	 
     $null = $Collection.Update($Result) 

   
   }
   
   else { 
      
    $BsonDocument = [LiteDB.BsonDocument]::new()   
    $BsonDocument["HexString"] =  $Record[0]
	$BsonDocument["Actions"]   =  $Record[1]  
    $BsonDocument["Hash"]      =  $Record[2]  
    $null = $Collection.Insert($BsonDocument)
    
  }

  
  $Database.Dispose()
 
  return
}


<#
Function name: ScriptQuery 
Description: Reads a file path from user input and performs a query on the Malware Repository database to retrieve the associated record. Results are displayed.
Function calls: -
Input:-
Output: -
#>

function ScriptQuery {
    param( )

Clear-Host
PrintLogo

Write-Host "Select input file path (file type must be .txt or .ps1)." 
$InputFilePath = DisplayDialogWindowFile

if ( $InputFilePath -eq ""){
 Write-Host "No file uploaded" -ForegroundColor red
 pause
 return
}

$Hash = ((Get-FileHash $InputFilePath).Hash)

$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$Collection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)

$Entry = "Hash ="+ "'"+$Hash+"'" 
$Result = $Collection.Find($Entry)

$Original = $Result.RawValue["Original"].RawValue
$Plainscript = $Result.RawValue["Plainscript"].RawValue

Clear-Host
PrintLogo

 if (($Result |Out-String) -eq ""   ) {
	
	Write-Host "No records found" -ForegroundColor red
	$Database.Dispose()
	pause
  }
  else {
	
	Write-Host "Records found:" -ForegroundColor green
	Write-Host "Original script:" -ForegroundColor yellow
	Write-Host $Original
	Write-Host "Deobfuscated script:" -ForegroundColor yellow
	Write-Host $Plainscript
	$Database.Dispose()
    pause	
  }



return  
}


<#
Function name: UrlQuery 
Description: Reads a URL from user input and performs a query on the Malware Repository database to retrieve the associated record. Results are displayed.
Function calls: -
Input:-
Output: -
#>

function UrlQuery {
    param( )

Clear-Host
PrintLogo

Write-Host "Insert URL"
$InputUrl = Read-Host

$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$URLsCollection = $Database.GetCollection("URLs",[LiteDB.BsonAutoId]::Int64)

$Entry = "Url ="+ "'"+$InputUrl+"'" 
$URLResult = $URLsCollection.Find($Entry)


Clear-Host
PrintLogo

 if (($URLResult |Out-String) -eq ""   ) {
	
	Write-Host "No records found" -ForegroundColor red
	$Database.Dispose()
	pause
  }
  else {
	
	Write-Host "Record found:" -ForegroundColor green
	
	$i =0
	foreach ( $result in $URLResult) {
		
		if($i -eq "0"){
	    $OutputUrl = $result.RawValue["Url"].RawValue
        $Status    = $result.RawValue["Status"].RawValue
	    Write-Host "URL: "$OutputUrl"          Status: "$Status	
		Write-Host "`nFollowing malicious scripts connect to it:`n" -ForegroundColor yellow
        }

        $Hash = $result.RawValue["Hash"].RawValue
		
		$PSscriptsCollection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)
        $Entry = "Hash ="+ "'"+$Hash+"'" 
        $ScriptResult = $PSScriptsCollection.Find($Entry)
        $Plainscript = $ScriptResult.RawValue["Plainscript"].RawValue
		
		Write-Host "Script" ($i+1)"- Hash value: "$Hash  -ForegroundColor yellow
		Write-Host $Plainscript
	$i++
	}
	
	
	$Database.Dispose()
    pause	
  }



return  
}


<#
Function name: ShellcodeQuery
Description: Reads a shellcode (hex string) from user input and performs a query on the Malware Repository database to retrieve the associated record. Results are displayed.
Function calls: -
Input:-
Output: -
#>

function ShellcodeQuery {
    param( )

Clear-Host
PrintLogo

Write-Host "Insert Shellcode"
$InputShellcode = Read-Host

$InputShellcode = ($InputShellcode.replace(" ","")).toLower()

$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$ShellcodesCollection = $Database.GetCollection("Shellcodes",[LiteDB.BsonAutoId]::Int64)

$Entry = "Hexstring ="+ "'"+$InputShellcode+"'" 
$ShellcodeResult = $ShellcodesCollection.Find($Entry)


Clear-Host
PrintLogo

 if (($ShellcodeResult |Out-String) -eq ""   ) {
	
	Write-Host "No records found" -ForegroundColor red
	$Database.Dispose()
	pause
  }
  else {
	
	Write-Host "Record found:" -ForegroundColor green
	
	$i =0
	foreach ( $result in $ShellcodeResult) {
		
		if($i -eq "0"){
	    $OutputShellcode = $result.RawValue["Hexstring"].RawValue
	    Write-Host "`nShellcode: " -ForegroundColor yellow
		Write-Output $OutputShellcode
		
		$Actions = $result.RawValue["Actions"].RawValue
		Write-Host "`nActions: " -ForegroundColor yellow
		Write-Output $Actions
		
		Write-Host "`nFollowing malicious scripts inject it:`n" -ForegroundColor yellow	
		
        }

        $Hash = $result.RawValue["Hash"].RawValue
		
		$PSscriptsCollection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)
        $Entry = "Hash ="+ "'"+$Hash+"'" 
        $ScriptResult = $PSScriptsCollection.Find($Entry)
        $Plainscript = $ScriptResult.RawValue["Plainscript"].RawValue
		
		Write-Host "Script" ($i+1)"- Hash value: "$Hash  -ForegroundColor yellow
		Write-Host $Plainscript
	$i++
	}
	
	
	$Database.Dispose()
    pause	
  }



return  
}

<#
Function name: MalwareStatistics
Description: Performs some queries on the Malware Repository database and calculates statistics on stored data. Results are displayed.
Function calls: -
Input:-
Output: -
#>

function MalwareStatistics {
    param( )

Clear-Host
PrintLogo

$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$PSscriptsCollection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)
$URLsCollection = $Database.GetCollection("URLs",[LiteDB.BsonAutoId]::Int64)
$ShellcodesCollection = $Database.GetCollection("Shellcodes",[LiteDB.BsonAutoId]::Int64)

#Total malwares
$Entry = "_id > 0" 
$TotalResult = $PSscriptsCollection.Find($Entry)
$Totalcount = 0

foreach ($result in $TotalResult ) {
	$Totalcount++
}

#Fileless malwares
$Entry = "Type = 'file-less'" 
$FilelessResult = $PSscriptsCollection.Find($Entry)
$Filelesscount = 0

foreach ($result in $FilelessResult ) {
	$Filelesscount++
}

#Filebased malwares
$Entry = "Type = 'file-based'" 
$FilebasedResult = $PSscriptsCollection.Find($Entry)
$Filebasedcount = 0

foreach ($result in $FilebasedResult ) {
	$Filebasedcount++
}
#Fileless malwares
$Entry = "Type = 'file-less'" 
$FilelessResult = $PSscriptsCollection.Find($Entry)
$Filelesscount = 0

foreach ($result in $FilelessResult ) {
	$Filelesscount++
}


#Base64 obfuscation layers
$Entry = "Base64 > '0'" 
$Base64Result = $PSscriptsCollection.Find($Entry)


$Base64count = 0

foreach ($result in $Base64Result ) {
	$string = $result.RawValue["Base64"].RawValue
	
	$n= [int]$string 
	$Base64count = $Base64count + $n 
	
}

#String-based layers
$Entry = "StringBased > '0'" 
$StringBasedResult = $PSscriptsCollection.Find($Entry)


$StringBasedcount = 0

foreach ($result in $StringBasedResult ) {
	$string = $result.RawValue["StringBased"].RawValue
	
	$n= [int]$string 
	$StringBasedcount = $StringBasedcount + $n 
	
}

#Encoded layers count
$Entry = "Encoded > '0'" 
$EncodedResult = $PSscriptsCollection.Find($Entry)


$Encodedcount = 0

foreach ($result in $EncodedResult ) {
	$string = $result.RawValue["Encoded"].RawValue
	
	$n= [int]$string 
	$Encodedcount = $Encodedcount + $n 
	
}

#Compressed layers count
$Entry = "Compressed > '0'" 
$CompressedResult = $PSscriptsCollection.Find($Entry)


$Compressedcount = 0

foreach ($result in $CompressedResult ) {
	$string = $result.RawValue["Compressed"].RawValue
	
	$n= [int]$string 
	$Compressedcount = $Compressedcount + $n 
	
}

$FilebasedRate = [math]::Round(  (100*($Filebasedcount/$Totalcount)) ,2 )
$FilelessRate =  [math]::Round(     (100*($Filelesscount/$Totalcount)) , 2 ) 
$TotalLayersCount =  $Base64count + $StringBasedcount + $Encodedcount + $Compressedcount  
$Base64Rate =  [math]::Round(       (100*($Base64count/$TotalLayersCount)) , 2 )
$StringbasedRate =  [math]::Round(  (100*($StringBasedcount/$TotalLayersCount)) , 2 )
$EncodedRate =  [math]::Round(  (100*($Encodedcount/$TotalLayersCount)) , 2 )
$CompressedRate =  [math]::Round(   (100*($Compressedcount/$TotalLayersCount)) ,2 )


#URLs total count
$Entry = "_id > 0" 
$TotalResult = $URLsCollection.Find($Entry)


$UrlList = New-Object System.Collections.Generic.List[System.Object]
$UrlStatusList = New-Object System.Collections.Generic.List[System.Object]

foreach ($result in $TotalResult ) {
	$url    = $result.RawValue["Url"].RawValue
	$status = $result.RawValue["Status"].RawValue
	$UrlList.add($url)
	$UrlStatusList.add($url + " - "+$status )
	
}

$UrlChart =  $UrlStatusList | Group-Object | Sort-Object -Property Count -Descending | Select Count,Name
$UrlDistinctList = $UrlList | Group-Object | Sort-Object -Property Count -Descending | Select Name

$UrlsCount = $UrlChart.length


#Active URLs count [status:200]
$Entry = "Status = '[200: Url is Active]'" 
$ActiveResult = $URLsCollection.Find($Entry)

$ActiveUrlList = New-Object System.Collections.Generic.List[System.Object]

foreach ($result in $ActiveResult ) {
	$url    = $result.RawValue["Url"].RawValue
	$ActiveUrlList.add($url)
}

$ActiveUrlDistinctList = $ActiveUrlList | Group-Object | Sort-Object -Property Count -Descending | Select Name
$ActiveUrlsCount = $ActiveUrlDistinctList.length
$ActivityRate = [math]::Round(   (100*($ActiveUrlsCount/$UrlsCount)) ,2 )

#Offline URLs count [status:404]
$Entry = "Status = '[404: Not Found]'" 
$OfflineResult = $URLsCollection.Find($Entry)

$OfflineUrlList = New-Object System.Collections.Generic.List[System.Object]

foreach ($result in $OfflineResult ) {
	$url    = $result.RawValue["Url"].RawValue
	$OfflineUrlList.add($url)
}

$OfflineUrlDistinctList = $OfflineUrlList | Group-Object | Sort-Object -Property Count -Descending | Select Name
$OfflineUrlsCount = $OfflineUrlDistinctList.length
$OfflineRate = [math]::Round(   (100*($OfflineUrlsCount/$UrlsCount)) ,2 )


Write-Host "Malware Statistics:`n" -ForegroundColor yellow

Write-Host "Malware samples stored: " $Totalcount 
Write-Host "File-based malwares: " $Filebasedcount  "(" $FilebasedRate "%)"
Write-Host "File-less malwares: " $Filelesscount "(" $FilelessRate "%)"
Write-Host "Base64 obfuscation layers: " $Base64count "(" $Base64Rate "%)"
Write-Host "String-based obfuscation layers: " $StringBasedcount "(" $StringbasedRate "%)"
Write-Host "Encoded obfuscation layers: " $Encodedcount "(" $EncodedRate "%)"
Write-Host "Compressed obfuscation layers: " $Compressedcount "(" $CompressedRate "%)"
Write-Host "URLs stored: " $UrlsCount
Write-Host "Active URLs [status: 200]:" $ActiveUrlsCount "(" $ActivityRate "%)"
Write-Host "Offline URLs [status: 404]:" $OfflineUrlsCount "(" $OfflineRate "%)"
Write-Host "`n"


$Database.Dispose()
pause

return
}


<#
Function name: ExportAllOriginalScripts
Description: Exports all stored scripts from the MalwareRepository database to a folder specified in the user input   
Function calls: -
Input:-
Output: -
#>

function ExportAllOriginalScripts {
    param( )

Clear-Host
PrintLogo

Write-Host "Select output folder path"
$OutputFolderPath = DisplayDialogWindowFolder

if ( $OutputFolderPath -eq ""){
 Write-Host "No folder selected" -ForegroundColor red
 pause
 return
}

Clear-Host
PrintLogo

Write-Host "Exporting..."  -ForegroundColor yellow
$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$PSscriptsCollection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)

$Entry = "_id > 0" 
$TotalResult = $PSscriptsCollection.Find($Entry)

$n=1
foreach ($result in $TotalResult ) {
	$Original = $result.RawValue["Original"].RawValue
	$number = $n.toString()
	$OutputFilePath = $OutputFolderPath +"\"+$number+".txt"
	$Original | Out-File $OutputFilePath
    $n++	
}

$message = "All scripts have been exported on "+ $OutputFolderPath  
Write-Host $message -ForegroundColor green

$Database.Dispose()
pause

return
}


<#
Function name: ExportAllURLs
Description: Exports all stored URLs from the MalwareRepository database to a folder specified in the user input   
Function calls: -
Input:-
Output: -
#>

function ExportAllURLs {
    param( )

Clear-Host
PrintLogo

Write-Host "Select output folder path"
$OutputFolderPath = DisplayDialogWindowFolder

if ( $OutputFolderPath -eq ""){
 Write-Host "No folder selected" -ForegroundColor red
 pause
 return
}

Clear-Host
PrintLogo

Write-Host "Exporting..."  -ForegroundColor yellow
$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$URLsCollection = $Database.GetCollection("URLs",[LiteDB.BsonAutoId]::Int64)

$Entry = "_id > 0" 
$TotalResult = $URLsCollection.Find($Entry)


$UrlList = New-Object System.Collections.Generic.List[System.Object]

foreach ($result in $TotalResult ) {
	$url    = $result.RawValue["Url"].RawValue
	$status    = $result.RawValue["Status"].RawValue
	$UrlList.add($url + "   -   "+ $status)
}

$UrlRanking =  $UrlList | Group-Object | Sort-Object -Property Count -Descending | Select Count,Name


$OutputFilePath = $OutputFolderPath +"\MaliciousUrlsRanking.txt"
$UrlRanking | Out-File $OutputFilePath


$message = "All URLs have been exported on "+ $OutputFilePath  
Write-Host $message -ForegroundColor green

$Database.Dispose()
pause

return
}


<#
Function name: ExportAllShellcodes
Description: Exports all stored Shellcodes from the MalwareRepository database to a folder specified in the user input   
Function calls: -
Input:-
Output: -
#>

function ExportAllShellcodes {
    param( )

Clear-Host
PrintLogo

Write-Host "Select output folder path"
$OutputFolderPath = DisplayDialogWindowFolder

if ( $OutputFolderPath -eq ""){
 Write-Host "No folder selected" -ForegroundColor red
 pause
 return
}

Clear-Host
PrintLogo

Write-Host "Exporting..."  -ForegroundColor yellow
$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$PSscriptsCollection = $Database.GetCollection("Shellcodes",[LiteDB.BsonAutoId]::Int64)

$Entry = "_id > 0" 
$TotalResult = $PSscriptsCollection.Find($Entry)

$n=1
foreach ($result in $TotalResult ) {
	$Original = $result.RawValue["Hexstring"].RawValue
	$number = $n.toString()
	$OutputFilePath = $OutputFolderPath +"\"+$number+".txt"
	$Original | Out-File -Encoding ASCII $OutputFilePath
	
    $n++	
}

$message = "All shellcodes have been exported on "+ $OutputFolderPath  
Write-Host $message -ForegroundColor green

$Database.Dispose()
pause

return
}
