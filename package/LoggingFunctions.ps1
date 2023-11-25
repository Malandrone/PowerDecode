<#
Function name: CreateLog
Description: Takes as input a hash string and creates a log file on package\logs\ directory
Function calls:
Input: $FileHash
Output: -
#>
function CreateLog( ) {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$FileHash	
    )
    
if( $Settings[4]  -eq "Enabled"){	
    $timestamp = (Get-Date -Format "yyyy-MM-dd").toString();
	$pwd = (Get-Location).path
	$LogFilePath = $pwd+"\package\logs\"+"PowerDecode-Log-"+$timestamp+"-"+$FileHash+".log";
	
    if(!(Test-Path $LogFilePath)){
		(New-Item $LogFilePath)|Out-Null;
	}
	$LogFilePath > ([System.IO.Path]::GetTempPath() +"PowerDecode2023LogFilePath.txt");
}	
return
}

<#
Function name: UpdateLog
Description: Takes a data string as input and performs logs update
Function calls:
Input: $data
Output: -
#>
function UpdateLog( ) {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$data
    )

if( $Settings[4]  -eq "Enabled"){	
    $LogFilePath = Get-Content ([System.IO.Path]::GetTempPath() +"PowerDecode2023LogFilePath.txt") 
    $Logs = Get-Content $LogFilePath  ;
    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").toString();
	$Logs += ($timestamp + " : "+$data+"`n") ;
    $Logs | Out-File $LogFilePath  ;
}
return 
}