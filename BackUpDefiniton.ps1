Param(

    [string]$TFSPublicUrl = "http://epbyminw7245t1/tfs",
    [string]$NameOfCollection = "DefaultCollection",
    [string]$NameOfProject = "",
    [string][ValidateSet("Build","Release","BuildAndRelease")]$TypeDefinition = "BuildAndRelease",
    [string]$MainPath = "C:\Work\PS\RepositoryForDefinition\"
    
)

function Get-BuildReleaseDefinition
{
  Param($AllDefinitionsURL,$PathForSave,
   [string][ValidateSet("Build","Release")]$Type)

  if(!(test-path -Path $PathForSave)){
    $folder = New-Item -Path $PathForSave -ItemType directory

  }
  Write-Host "Invoke WebRequest $AllDefinitionsURL"
  $allDefinitionsResponse = Invoke-WebRequest -UseDefaultCredentials -Uri "$AllDefinitionsURL" -ErrorAction SilentlyContinue

  $allDefinitionsContent = (ConvertFrom-Json $allDefinitionsResponse.Content).value

  $listOfSavingDefinition = Get-ChildItem -Path $PathForSave

  ForEach($definition in $allDefinitionsContent){

    $aimDefinitionURL = $definition.url
    Write-Host "Invoke WebRequest on $Type`: $($definition.name)"
    $aimDefinition = Invoke-WebRequest -UseDefaultCredentials -Uri $aimDefinitionURL
    $definitionContent = ConvertFrom-Json $aimDefinition

    $perem=0
    if($Type -eq "Build"){
        $date = $definition.createdDate
    }
    else{
        $date = $definition.modifiedOn
    }

    $date = (($date.Replace("T","I")).replace("Z","")).replace("`:","-")

    $name = $definitionContent.name

    #find same definition on the matching name abd date
    ForEach($savingDefinition in $listOfSavingDefinition){
        
        if($savingDefinition.BaseName -eq "[$date`]$name"){
            # if name and date is matching then 

            Write-Host "$type` Definition $name` on $date` has alredy exist" -BackgroundColor Green
            $perem=1
            break;
        }

    }
    
    if($perem -eq "0"){
        $definitionContent = ConvertTo-Json $definitionContent -Depth 10
        $file = New-Item -path $PathForSave -Name "[$date`]$name`.json" -ItemType "file" -Value $definitionContent
        Write-Host "Save new $type` definition $name` created in $date" -BackgroundColor Yellow -ForegroundColor Black
    }
  }
}


try{$tfsResponse = Invoke-WebRequest -UseDefaultCredentials -Uri "$TFSPublicUrl/$NameOfCollection" }
catch{
    Write-host "Error!!! The TFS Server on $TFSPublicUrl/$NameOfCollection is inreachble `n $($error[0].Exception.Message) `n $($error[0].ErrorDetails.Message)" -ForegroundColor Red
    break
}

if($NameOfProject -eq ""){

    $allProjectsURL = "$TFSPublicUrl/$NameOfCollection/_apis/projects/"
    $allProjectsResponse = Invoke-WebRequest -UseDefaultCredentials -Uri $allProjectsURL 
    $allProjectContent = (ConvertFrom-Json $allProjectsResponse.Content).value

    ForEach($project in $allProjectContent){

        $NameOfProject = $project.Name
        $pathForSave = "$MainPath$NameOfProject`\"
        $pathForSaveRelease = "$pathForSave`Release"
        $pathForSaveBuilds = "$pathForSave`Builds"

        $allBuildDefinitionsURL = "$TFSPublicUrl/$NameOfCollection/$NameOfProject/_apis/build/Definitions"
        $allReleaseDefinitionsURL = "$TFSPublicUrl/$NameOfCollection/$NameOfProject/_apis/release/Definitions"
        Write-host "Download project $NameOfProject"
        
        if($TypeDefinition -eq "Build"){

            Get-BuildReleaseDefinition -allDefinitionsURL $allBuildDefinitionsURL -pathForSave $pathForSaveBuilds -type Build
        }
        elseif($TypeDefinition -eq "Release"){
    
            Get-BuildReleaseDefinition -allDefinitionsURL $allReleaseDefinitionsURL -pathForSave $pathForSaveRelease -type Release
        }
        else{
            Get-BuildReleaseDefinition -allDefinitionsURL $allBuildDefinitionsURL -pathForSave $pathForSaveBuilds -type Build
            Get-BuildReleaseDefinition -allDefinitionsURL $allReleaseDefinitionsURL -pathForSave $pathForSaveRelease -type Release
        }

    }

}

else{

    try{
        $tfsResponse = Invoke-WebRequest -UseDefaultCredentials -Uri "$TFSPublicUrl/$NameOfCollection/$NameOfProject" 
    }
    catch{
        Write-host "Error!!! The TFS Server on $TFSPublicUrl/$NameOfCollection is inreachble `n $($error[0].Exception.Message) `n $($error[0].ErrorDetails.Message)" -ForegroundColor Red
    break
    }

    $pathForSave = "$MainPath$NameOfProject`\"
    $pathForSaveRelease = "$pathForSave`Release"
    $pathForSaveBuilds = "$pathForSave`Builds"


    $allBuildDefinitionsURL = "$TFSPublicUrl/$NameOfCollection/$NameOfProject/_apis/build/Definitions"
    $allReleaseDefinitionsURL = "$TFSPublicUrl/$NameOfCollection/$NameOfProject/_apis/release/Definitions"
    Write-host "Download project $NameOfProject"


    
    if($TypeDefinition -eq "Build"){

        Get-BuildReleaseDefinition -allDefinitionsURL $allBuildDefinitionsURL -pathForSave $pathForSaveBuilds -type Build
    }
    elseif($TypeDefinition -eq "Release"){
    
        Get-BuildReleaseDefinition -allDefinitionsURL $allReleaseDefinitionsURL -pathForSave $pathForSaveRelease -type Release
    }
    else{
        Get-BuildReleaseDefinition -allDefinitionsURL $allBuildDefinitionsURL -pathForSave $pathForSaveBuilds -type Build
        Get-BuildReleaseDefinition -allDefinitionsURL $allReleaseDefinitionsURL -pathForSave $pathForSaveRelease -type Release
    }
}