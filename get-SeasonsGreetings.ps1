<#
    Season's Greetings
    https://itknowledgeexchange.techtarget.com/powershell/seasons-greetings/
#>

(77, 101, 114, 114, 121, 32, 67, 104, 114, 105, 115, 116, 109, 97, 115, 32, 97, 110, 100, 32, 97, 32, 72, 97, 112, 112, 121, 32, 78, 101, 119, 32, 89, 101, 97, 114 | ForEach-Object { [char][byte]$psitem }) -join ""