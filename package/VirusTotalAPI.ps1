<#
Function name: GetVirusTotalReport 
Description: Takes as an input a hash and a VirusTotal API key and search VirusTotal for a file hash.  
Function calls: -
Input: $hash , $VTApiKey
Output: $VTReport
#>

function GetVirusTotalReport {
    
        param (
		[Parameter(Mandatory=$true)] [string]$hash ,
		[Parameter(Mandatory=$true)] [string]$VTApiKey
		)

    ## Set TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


                
    ## Submit the hash!
        $VTbody = @{resource = $hash; apikey = $VTApiKey}
        try{	
		$VTresult = Invoke-RestMethod -Method GET -Uri 'https://www.virustotal.com/vtapi/v2/file/report' -Body $VTbody
        }
		catch {
			Write-Host "Cannot get VirusTotal rating. Please insert a valid API key on settings menu" -Foregroundcolor red
		}

    ## Calculate percentage if there is a result
        if ($VTresult.positives -ge 1) {
            $VTpct = (($VTresult.positives) / ($VTresult.total)) * 100
            $VTpct = [math]::Round($VTpct,2)
        }
                    
	    else {
            $VTpct = 0
        }
        ## Custom Object for data output
            $VTReport =    [PSCustomObject]@{
                        
						resource    = $VTresult.resource
                        scan_date   = $VTresult.scan_date
                        positives   = $VTresult.positives
                        total       = $VTresult.total
                        permalink   = $VTresult.permalink
                        percent     = $VTpct
                    }
                    
        return $VTReport
             
            
    }

  
