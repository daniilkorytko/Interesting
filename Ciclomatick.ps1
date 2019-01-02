## Script for calculatng cyclomatic difficulties



Param(
    [string]$InputUriFile = "https://raw.githubusercontent.com/daniilkorytko/Interesting/master/Test1.txt"
)


$comment =$false

$cycleCount = 0
$maxCyclomaticDifficult = 0
$mediumCyclomaticDifficult = 0
$arrayOfParagraphs = @()

$inputText = ((Invoke-WebRequest -Uri $InputUriFile).content).split("`n")

#delete comments
for($line=0; $line -lt $inputText.Count; $line++){
   
    if($comment -eq $true){
        if($inputText[$line] -match "\*\/.*"){
            $comment = $false
            }
        $inputText[$line] = ""
    }
    else{
        if($inputText[$line] -match "\/\*.*"){

            if($inputText[$line] -notmatch "\*\/.*"){
                 $comment = $true
            }
            $inputText[$line] = ""
        }
        if($inputText[$line] -match ".*(//.*)"){
            $inputText[$line] = $inputText[$line].Replace($Matches[1],"")
        }
    }
}



 #separation for paragraphs
for($line=0; $line -lt $inputText.Count; $line++){
   
    $charText = $inputText[$line].tochararray()

    for($element=0; $element -lt $charText.Count; $element++)
    {
        if($charText[$element] -eq "`{"){
            $cycleCount++

            if($cycleCount -eq 2){
                $beginParagrapf = $line

            }
        }
        if($charText[$element] -eq "`}"){
            $cycleCount--
            if($cycleCount -eq 1){

                $paragraph = [ordered]@{
                    begin = $beginParagrapf
                    end = $line
                    cyclomaticDifficult = 1
                }

            $arrayOfParagraphs += $paragraph
            }
        }
    }
}


#calculate the Cyclomatic Difficulties
for($paragraph = 0;$paragraph -lt $arrayOfParagraphs.Count ;$paragraph++){
    
    $beginParagraph = $arrayOfParagraphs[$paragraph].begin
    $endParagraph = $arrayOfParagraphs[$paragraph].end

    #calculate the Cyclomatic Difficulties for each paragraphs
    for($line=$beginParagraph; $line -lt $endParagraph; $line++)
    {

        if($inputText[$line] -match "while "){$arrayOfParagraphs[$paragraph].cyclomaticDifficult++}
        if($inputText[$line] -match "for "){$arrayOfParagraphs[$paragraph].cyclomaticDifficult++}
        if($inputText[$line] -match "if "){$arrayOfParagraphs[$paragraph].cyclomaticDifficult++}
        if($inputText[$line] -match "case: "){$arrayOfParagraphs[$paragraph].cyclomaticDifficult++}
        if($inputText[$line] -match "default: "){$arrayOfParagraphs[$paragraph].cyclomaticDifficult++}
        if($inputText[$line] -match "\?"){$arrayOfParagraphs[$paragraph].cyclomaticDifficult++}
    
    }
    #calculate the maximum of Cyclomatic Difficulties 
    if($arrayOfParagraphs[$paragraph].cyclomaticDifficult -gt $maxCyclomaticDifficult){
        $maxCyclomaticDifficult = $arrayOfParagraphs[$paragraph].cyclomaticDifficult

    }
    #calculate the average of Cyclomatic Difficulties 
    $mediumCyclomaticDifficult += $arrayOfParagraphs[$paragraph].cyclomaticDifficult


}

$mediumCyclomaticDifficult /= $arrayOfParagraphs.Count

Write-Host "The most complex function has a cyclomatic complexity value of $maxCyclomaticDifficult` while the median is $mediumCyclomaticDifficult" 
