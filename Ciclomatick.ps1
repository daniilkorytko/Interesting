

$testText = Get-Content -Path C:\Work\PS\Cuclomatick\Test2.txt

$cilcDifficult=1
$mediumCiclomatickDiff=1
$maxCiclomatickDiff = 1


$charText = $testText.ToCharArray()
$otkrivskobka=0
$zakrivskobka=0
$ciclCount = 0

$defaultCiclCount = 0

$massiveNezavicFunction = @()


for($nomerstroki=0; $nomerstroki -lt $testText.Count; $nomerstroki++){
    #разделение на параграфы

    if($testText[$nomerstroki] -match "\*"){continue;}
    $charText = $testText[$nomerstroki].ToCharArray()

    for($nomerElementa=0; $nomerElementa -lt $charText.Count; $nomerElementa++)
    {

        if($charText[$nomerElementa] -eq "`{"){$otkrivskobka++;$ciclCount++}
        if($charText[$nomerElementa] -eq "`}"){$zakrivskobka++;$ciclCount--}

        if((($ciclCount - $DefaultCiclCount) -eq 2) -and ($ciclCount -eq 2)){
            $beginParagrapf = $nomerstroki

            $defaultCiclCount=2

        }
        if((($ciclCount - $DefaultCiclCount) -eq -1) -and ($ciclCount -eq 1)){

            $Paragrapf = [ordered]@{
            Begin = $beginParagrapf
            End = $nomerstroki
            CiclomatickDiff = $cilcDifficult
            }

            $defaultCiclCount=0
            $massiveNezavicFunction += $Paragrapf

        }

    }

}

for($nomerParagrapha = 0;$nomerParagrapha -lt $massiveNezavicFunction.Count ;$nomerParagrapha++){
    
    $beginParagraph = $massiveNezavicFunction[$nomerParagrapha].begin
    $endParagraph = $massiveNezavicFunction[$nomerParagrapha].end

    ##подсчет цикломатической сложности для каждого параграфа
    for($nomerstroki=$beginParagraph; $nomerstroki -lt $endParagraph; $nomerstroki++)
    {

        if($testText[$nomerstroki] -match "while "){$massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff++}
        if($testText[$nomerstroki] -match "for "){$massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff++}
        if($testText[$nomerstroki] -match "if "){$massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff++}
        if($testText[$nomerstroki] -match "case: "){$massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff++}
        if($testText[$nomerstroki] -match "default: "){$massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff++}
        if($testText[$nomerstroki] -match "\?"){$massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff++}
    
    }
    #определение максимальной цикломатической сложности
    if($massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff -gt $maxCiclomatickDiff){
        $maxCiclomatickDiff = $massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff

    }
    #определение средней цикломатической сложности
    $mediumCiclomatickDiff += $massiveNezavicFunction[$nomerParagrapha].CiclomatickDiff


}

$mediumCiclomatickDiff /= $massiveNezavicFunction.Count

Write-Host "The most complex function has a cyclomatic complexity value of $maxCiclomatickDiff` while the median is $mediumCiclomatickDiff" 