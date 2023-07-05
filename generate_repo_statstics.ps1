# params
param([string]$source, [string]$destination)
#functions

function get-subfiles($source)
{
  $result = get-childitem $source -recurse | where {$_.PSIsContainer -eq $false}
  return $result
}

get-subfiles -source "C:\Users\ZLaP"

function file-HasExtension($file)
{
  return $file.extension.length -gt 1
}

function get-FileExtension($file)
{
  if(file-HasExtension($file))
  {
   $result = $file.extension.substring(1)
  }
  else{
   $result = ""
  }

  return $result
}

function get-destinationFilePath($destination, $file)
{
 if(file-HasExtension($file))  
 {
  $extension = get-FileExtension($file)
  $destinationFilePath =  $destination + "\" + $extension
 }
 else{
   $destinationFilePath = $destination
 }

 return $destinationFilePath
}
 
function copy-FilesByExtension($destination, $file)
{
   $destinationFilePath = get-destinationFilePath $destination $file
   if (!(Test-Path -path $destinationFilePath)) {New-Item $destinationFilePath -Type Directory}
   Copy-Item $file.FullName -Destination $destinationFilePath
} 

function delete-AllFiles($directory)
{
 Get-ChildItem -Path $directory -Recurse | foreach { $_.Delete()}
}

function get-statistics($folder)
{
 $subDir = get-childitem $folder | where {$_.PSIsContainer -eq $true}
 $result = [PSCustomObject]@{
    name     = ''
    totalSize = ''
    count    = ''
}
 
foreach($dir in $subDir)
{ 
 $stat = get-childitem $dir.FullName | Measure-object -property length -sum    
 $result.name = $dir.FullName  
 $result.totalSize = [Math]::Round($stat.sum/1MB, 2)
 $result.count = $stat.Count
 write-host $result
}
}
get-statistics "c:\destination"
# main
function main-process($destination, $source) {
 delete-AllFiles -directory $destination
 $files = get-subfiles -source $source
 foreach($file in $files)
 {
  copy-FilesByExtension -destination $destination -file $file
 }
 # get statics
 get-statistics -folder $destination
}
# main processing
main-process -destination "C:\destination" -source "c:\tmp"
