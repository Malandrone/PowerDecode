#####################################
# Deobfuscation by Regex Functions  #
#####################################

function DeobfuscateByRegex 
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

       $OldScript = ''
       $NewScript = $Script

       While($OldScript -ne $NewScript)
       {
            $OldScript = $NewScript

            
            $NewScript  = ReplaceMultiLineEscapes($NewScript )
            $NewScript  = ReplaceNonEscapes($NewScript )
            $NewScript  = ReplaceQuotesFunctionName($NewScript )
            $NewScript  = CleanFunctionCalls($NewScript )
            $NewScript  = ReplaceParens($NewScript )
            $NewScript  = ReplaceFunctionParensWrappers($NewScript )
            $NewScript  = ConcatenateCleanup($NewScript )
            $NewScript  = ResolveStringFormats($NewScript )
            $NewScript  = ResolveReplaces($NewScript )
        }
        
        return $NewScript

    }



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



