<#
Function name: DeobfuscateByRegex
Description: Receives as input a script and performs de-obfuscation applying a set of regular expressions
Function calls: GoodSyntax, ReplaceMultiLineEscapes, ReplaceNonEscapes, ReplaceQuotesFunctionName, CleanFunctionCalls, ReplaceParens, ReplaceFunctionParensWrappers, ConcatenateCleanup, ResolveStringFormats, ResolveReplaces
Input:  $Script 
Output: $NewScript
#>

function DeobfuscateByRegex 
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

      
	   $TempScript = ''
       $OldScript = ''
       $NewScript = $Script

       While( $NewScript -ne $OldScript )
       {
          
			$OldScript = $NewScript 
			
			$TempScript  = ResolveStringFormats($NewScript )
			if (GoodSyntax $TempScript ) { $NewScript = $TempScript  }
			
			$TempScript  = ResolveStringFormats2($NewScript )
			if (GoodSyntax $TempScript ) { $NewScript = $TempScript  }
			
			 
            $TempScript  = ReplaceMultiLineEscapes($NewScript)
            if ((GoodSyntax $TempScript)) { $NewScript = $TempScript  }
			
			$TempScript  = ReplaceNonEscapes($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript }
			
            $TempScript = ReplaceQuotesFunctionName($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			 $TempScript = ReplaceQuotesFunctionName2($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
            $TempScript = CleanFunctionCalls($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
            $TempScript = ReplaceParens($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
            $TempScript = ReplaceFunctionParensWrappers($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
            $TempScript = ConcatenateCleanup($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = ConcatenateCleanup2($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
            $TempScript = ResolveReplaces($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = ResolveReplaces2($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
        
		
		}
        
        return $NewScript

    }


<#
Function name: ReplaceQuotesFunctionName
Description: Removes <"> and <'> obfuscation characters from function names 
Function calls: -
Input:  $Script 
Output: $Script
#>

function ReplaceQuotesFunctionName
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
       $pattern = [regex]"[\.&](\`"|')[a-zA-Z0-9]+(\`"|')\("
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, $match.ToString().replace('"','').replace("'",""))
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }


function ReplaceQuotesFunctionName2
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

 
$regex = @"
[\&\.][\'\"](\s){0,}([A-Za-z0-9\-]){0,}(\s){0,}[\'\"]
"@

$pattern = [regex] $regex
     $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, $match.ToString().replace('"','').replace("'","").replace(".","").replace("&",""))
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }

<#
Function name: ReplaceQuotesFunctionName
Description: Removes <.&('...')> and <.&("...")> obfuscation characters from function names 
Function calls: -
Input:  $Script 
Output: $Script
#>

function ReplaceFunctionParensWrappers
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
       $pattern = [regex]"[\.&]\(('|`")[a-zA-Z-]+('|`")\)"
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, $match.ToString().replace('.','').replace('&','').replace("('",'').replace("')",'').replace('("','').replace('")',''))
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }




<#
Function name: CleanFunctionCalls
Description: Removes <"> , <'> and <`> obfuscation characters from function names 
Function calls: -
Input:  $Script 
Output: $Script
#>
function CleanFunctionCalls
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

       $pattern = [regex]"\.['`"][a-zA-Z0-9``]+['`"]"
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                $ReplacedValue = $match.ToString().replace('"','').replace("'",'')
                
                $Script = $Script.Replace($match, $ReplacedValue )
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }


<#
Function name: ReplaceParens
Description: Removes <(> and <)> obfuscation characters from function names 
Function calls: -
Input:  $Script 
Output: $Script
#>

function ReplaceParens
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
       $pattern = [regex]"[^a-zA-Z0-9.&(]\(\s*'[^']*'\)"
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, $match.ToString().replace('(','').replace(')',''))
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }


<#
Function name: ReplaceNonEscapes
Description: Removes obfuscation residuals 
Function calls: -
Input:  $Script 
Output: $NewScript
#>

function ReplaceNonEscapes
    {
        param(
            [Parameter(Mandatory=$True)]
            [char[]]$Script
        )

        $PrevChar = ''        
        $InScript = $false
        $CurrQuote = ''
        $ScriptQuotes = '"', "'"
        $CharIdxArray = @()

        for ($char=0; $char -lt $Script.Length; $char++){
            if($Script[$char] -in $ScriptQuotes -and -not $InScript){
                $CurrQuote = $Script[$char]
                $InScript = $true
            }
            elseif($Script[$char] -in $ScriptQuotes -and $InScript -and $Script[$char] -eq $CurrQuote  -and $PrevChar -ne '`'){
                $CurrQuote =''
                $InScript = $false
            }
            elseif($Script[$char] -eq '`' -and -not $InScript){
                $CharIdxArray += ,$char
            }

            $PrevChar = $Script[$char]
        }

        [System.Collections.ArrayList]$NewScript = $Script
        $IdxOffset = 0
        
        

        ForEach($idx in $CharIdxArray){
            $NewScript.RemoveAt($idx-$IdxOffset)
            $IdxOffset++
        }

    return $NewScript -join ''
}


<#
Function name: ReplaceMultiLineEscapes
Description: Removes multi line escape characters
Function calls: -
Input:  $Script 
Output: $Script
#>

function ReplaceMultiLineEscapes
    {
        param(
            [Parameter(Mandatory=$True)]
            [string]$Script
        )

        $pattern = [regex]'`\s*\r\n\s*'
        $matches = $pattern.Matches($Script)


        While ($matches.Count -gt 0){
            
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, ' ')
                }
            $matches = $pattern.Matches($Script) 
        }
    return $Script
}



<#
Function name: ResolveStringFormats
Description: Removes string-based reorder obfuscation not dependent on IEX  
Function calls: -
Input:  $Script 
Output: $Script
#>


function ResolveStringFormats
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

       $pattern = [regex]"\(`"({\d+})+`"\s*-[fF]\s*('[^']*',?)+\)"
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                $SolvedString = IEX($match)
               
                $Script = $Script.Replace($match, "'$($SolvedString)'")
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script
    }

function ResolveStringFormats2
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )


$regex= @"
(\(){0,}(\s){0,}[\"\'](\s){0,}(\{\d+\}){1,}(\s){0,}[\"\'](\s){0,}\-(\s){0,}[fF](.){0,}(\s){0,}(\)){0,}
"@

       $pattern = [regex] $regex
       $matches = $pattern.Matches($Script) 

     While ($matches.Count -gt 0){
            ForEach($match in $matches){
                $SolvedString = IEX($match)
               
                $Script = $Script.Replace($match, "'$($SolvedString)'")
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script
    }

<#
Function name: ResolveReplaces 
Description: Removes string-based replace obfuscation not dependent on IEX  
Function calls: -
Input:  $Script 
Output: $Script
#>

function ResolveReplaces
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

       $pattern = [regex]"\(?['`"][^'`"]+['`"]\)?\.(?i)replace\([^,]+,[^\)]+\)"
       $matches = $pattern.Matches($Script)

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                $SolvedString = IEX($match)
                $SolvedString = $SolvedString.replace("'","''")
                
                $Script = $Script.Replace($match, "'$($SolvedString)'")
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script
    }



function ResolveReplaces2
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

$regex = @"
["'](.*?)["'](\s{0,})\-([CcIi]{0,1})[Rr][Ee][Pp][Ll][Aa][Cc][Ee](\s{0,})\((.*?)\)
"@

       $pattern = [regex]  $regex
       $matches = $pattern.Matches($Script)

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                $SolvedString = IEX($match)
               
                
                $Script = $Script.Replace($match, "'$($SolvedString)'")
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script
    }

<#
Function name: ConcatenateCleanup 
Description: Removes string-based concatenating obfuscation not dependent on IEX  
Function calls: -
Input:  $Script 
Output: $Script
#>


function ConcatenateCleanup
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
     


      return $Script.Replace("'+'", "").Replace('"+"','')
    }


function ConcatenateCleanup2
   {
         param(
             [Parameter(
                Mandatory=$True,
                Valuefrompipeline = $True)]
            [String]$Script
         )
 $pattern1 = [regex] "'(\s){0,}\+(\s){0,}'"
 $matches = $pattern1.matches($Script)
 foreach ($match in $matches){
 $Script = $Script.replace( $match ,""  )
 }
 
 
 
$pattern2 = [regex] '"(\s){0,}\+(\s){0,}"'
$matches = $pattern2.matches($Script)
 foreach ($match in $matches){
 $Script = $Script.replace( $match ,""  )
 }
 
 return $Script
 }
