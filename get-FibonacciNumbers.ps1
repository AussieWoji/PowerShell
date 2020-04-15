# LINK
# https://itknowledgeexchange.techtarget.com/powershell/fibonacci-series/

function new-fibonacci {
    param (
        [int]$numberofelements = 10
    )

    ## first 2 elements

    $ell1 = 1
    $ell1

    $ell2 = 1
    $ell2

    $i = 2
    while ($i -lt $numberofelements) {
        $elnext = $ell1 + $ell2
        $elnext

        $i++
        $ell2 = $ell1
        $ell1 = $elnext
    }
}

Clear-Host
#new-fibonacci
new-fibonacci -numberofelements 75
