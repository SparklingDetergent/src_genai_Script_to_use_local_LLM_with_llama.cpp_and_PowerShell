# Param表示の共通関数。

# main処理 function

function WriteParameters {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FunctionName,

        [Parameter(Mandatory=$true)]
        [hashtable]$Parameters
    )

    Write-Verbose ("")

    # Write the name of the calling function
    Write-Verbose ("Function: {0}" -f $FunctionName)

    Write-Verbose ("")

    # Get the keys in ascending order
    $keys = $Parameters.Keys | Sort-Object

    # Use Write-Verbose to list the parameters in order
    foreach ($key in $keys) {
        # Check if the parameter is an array
        if ($Parameters[$key] -is [array]) {
            Write-Verbose ("    {0} = {1}" -f $key, $Parameters[$key])
            foreach ($value in $Parameters[$key]) {
                Write-Verbose ("        {0}" -f $value)
            }
        } else {
            Write-Verbose ("    {0} = {1}" -f $key, $Parameters[$key])
        }
    }

    Write-Verbose ("")

}
