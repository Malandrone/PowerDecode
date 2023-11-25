<#
Function name: GetScriptFromFile 
Description: Receives as input a file path and returns its content
Function calls: GetFileEncoding, CreateLog, UpdateLog
Input:  $InputFile
Output: $ObfuscatedScript
#>
function GetScriptFromFile() {
	param(
        [Parameter(
			Mandatory = $True)]
        [PSObject[]]$InputFile
    )
	
    $Hash = ((Get-FileHash $InputFile).Hash);
	CreateLog $Hash;
	
	try {
		$FileEncoding = GetFileEncoding $InputFile
		if($FileEncoding -eq "ascii") {
			$FileContent = Get-Content $InputFile -ErrorAction Stop
		}
		else {
			$FileContent = Get-Content $InputFile -Encoding UTF8 -ErrorAction Stop
		}
	}
			
	    
    catch {
		throw "Error reading: '$($InputFile)'"
	}
	
	if ( (($FileContent -match '@"') -and ($FileContent -match '"@'))   -or (($FileContent -match "@'") -and ($FileContent -match "@'")) -or( ($FileContent|Out-String).toLower() -match "function" ) ){
		$ObfuscatedScript = $FileContent | Out-String
		UpdateLog ("[GetScriptFromFile]: Loaded file with hash:  "+$Hash+" file content:     "+$ObfuscatedScript );
		
		}
	else {
		  foreach($line in $FileContent) {
		    $ObfuscatedScript += $line
	        }
			
			if (!(GoodSyntax $ObfuscatedScript)) {
				$ObfuscatedScript = $FileContent | Out-String
			}
	
		UpdateLog ("[GetScriptFromFile]: Loaded (reducing it to one line) file with hash:  "+$Hash+" file content:     "+$ObfuscatedScript );
	}
	
	return $ObfuscatedScript
}

<#
Function name: GetFileEncoding
Description: Receives as input an object and returns a string representing the text encoding type (ascii or utf8 )
Function calls: UpdateLog
Input:  $InputObject 
Output: "ascii"/"utf8"
#>
function GetFileEncoding() {
	param(
        [Parameter(
			Mandatory = $True)]
        [PSObject[]]$InputObject
    )
	
	[byte[]]$Bytes = Get-Content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $InputObject
	
	if($Bytes[0] -eq 0xef -and $Bytes[1] -eq 0xbb -and $Bytes[2] -eq 0xbf) {
		UpdateLog ("[GetFileEncoding]: utf8  ");
		return "utf8"
	}
	else {
		UpdateLog ("[GetFileEncoding]: ascii  ");
		return "ascii"
	}
}

<#
Function name: DisplayDialogWindowFile
Description: Displays a dialog window to set the input file path
Function calls: 
Input:  -
Output: $InputFile
#>
function DisplayDialogWindowFile() {
	
   Add-Type -AssemblyName System.Windows.Forms
   $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
   $null = $FileBrowser.ShowDialog()
   $InputFile = $FileBrowser.FileName
   
  return $InputFile	
	
}

<#
Function name: DisplayDialogWindowFolder
Description: Displays a dialog window to set the input folder path
Function calls: 
Input:  -
Output: $InputFolder
#>
function DisplayDialogWindowFolder() {
	
   Add-Type -AssemblyName System.Windows.Forms
   $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
   $null = $FolderBrowser.ShowDialog()
   $InputFolder = $FolderBrowser.SelectedPath
   
  return $InputFolder	
	
}

<#
Function name: UpdateReport
Description: Receives a data string as input and stores it in a report file    
Function calls: -
Input: $data
Output: -
#>
function UpdateReport() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$data 
    )


    $ReportFileName = "PowerDecode_2020_Malware_Analysis_Temp_Report"
    $ReportOutFile =  [System.IO.Path]::GetTempPath() + $ReportFileName +".txt" 
    
    
    $Report = Get-Content $ReportOutFile  
	$Report += $data
    $Report | Out-File $ReportOutFile 


return 

}