$choruses = Get-ChildItem -Path "~/Dropbox/Songbook/Choruses"
$rhonda = Get-ChildItem -Path "~/Dropbox/Songbook/Songs from Rhonda Palmer"
$unknown = Get-ChildItem -Path "~/Dropbox/Songbook/Unknown"
$combined = ($choruses + $rhonda + $unknown).FullName

$titles = foreach ($item in $combined) {
    Get-Content $item | Where-Object {$_ -like "{title:*"}
}

$titles | Group-Object
