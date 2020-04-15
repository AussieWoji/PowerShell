# https://github.com/PowerShell/PowerShellGet/issues/107
function ProgressDemo {
  if (-not $GLOBAL:modules) {
    $GLOBAL:modules = find-module az.*
  }


  $parentid = Get-Random
  $childid = Get-Random

  function Write-MainProgress ($Message,$percentComplete) {
    Write-Progress -id $parentID -Activity 'Install-PSResource' -PercentComplete $percentComplete -Status $Message
  }

  function Write-SubProgress ($Activity,$Message,$percentComplete) {
    Write-Progress -id $childid -parentid $parentid -Activity $Activity -Status $Message -PercentComplete $percentComplete
  }

  Write-MainProgress "Finding and resolving dependencies for $($modules.count) modules" 1
  sleep 2
  Write-MainProgress "Downloading" 15
  $i=0
  $percentage = get-random 10
  while ($percentage -lt 100) {
    Write-MainProgress "Downloading" (15 + (35 * ($percentage/100)))
    Write-Subprogress -Activity "Downloading $($modules.count) modules" -Message ($modules.foreach{$_.name,$_.version -join ' '} -join ', ') -PercentComplete $percentage
    sleep 0.2
    $percentage += get-random 5
    $i++
  }

  $i=0
  foreach ($moduleitem in $modules) {
    Write-MainProgress "Installing" (50 + (40 * ($i/$modules.count)))
    $percentage = get-random 10
    while ($percentage -lt 100) {
      Write-Subprogress -Activity "Installing $($modules.count) modules to {{MODULEDESTINATION}}" -Message (@($moduleItem).foreach{$_.name,$_.version -join ' '} -join ', ') -PercentComplete $percentage
      $percentage += get-random 20
      sleep 0.1
    }
    $i++
  }
  Write-MainProgress "Verifying" 90
  Write-Subprogress -Activity "Verifying $($modules.count) modules were installed correctly" -Message 'Processing' 0
  sleep 3
  Write-Progress -id $parentid -Activity 'Done' -Completed
}