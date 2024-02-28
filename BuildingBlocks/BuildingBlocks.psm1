<#
    .Synopsis
        Tries to run a a command (scriptblock) until it succeeds
    .PARAMETER ScriptBlock
        The command / script to execute
    .PARAMETER Maximum
        The max amount of retries
    .PARAMETER DelaySec
        The wait time (seconds) between the attempts
    .EXAMPLE
        Invoke-BxRetryCommand -Maximum 3 -DelaySec 10 -ScriptBlock { Invoke-WebRequest -Uri "https://api.thecatapi.com/v1/images" } -Verbose
#>
function Invoke-BxRetryCommand {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Position = 1, Mandatory = $false)]
        [int]$Maximum = 3,

        [Parameter(Position = 2, Mandatory = $false)]
        [int]$DelaySec = 30
    )

    $Counter = 0

    do {
        $Counter++
        try {
            Write-Verbose "Retry-Command: Calling scriptblock ($Counter/$Maximum)"
            $ScriptBlock.Invoke()
            return
        }
        catch {
            Write-Error "Retry-Command ($Counter/$Maximum): Error => $($_.Exception.InnerException.Message)" -ErrorAction Continue
            if ($Counter -lt $Maximum) {
                Write-Verbose "Retry-Command: Trying again in $DelaySec seconds ($Counter/$Maximum)"
                Start-Sleep -Seconds $DelaySec
            }
            else {
                Write-Verbose "Retry-Command: Max tries reached ($Counter/$Maximum)"
                throw $_.Exception
            }
        }
    } while ($true)
}

<#
    .Synopsis
        Encodes a clear text string to base64
    .PARAMETER InputString
        The clear text string
    .EXAMPLE
        "Hello World" | ConvertTo-BxBase64
#>
function ConvertTo-BxBase64 {
    Param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [String]$InputString
    )

    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    return [System.Convert]::ToBase64String($Bytes)
}

<#
    .Synopsis
        Decodes a base64 string to clear text
    .PARAMETER InputString
        The base64 string
    .EXAMPLE
        "aGVsbG8gd29ybGQ=" | ConvertFrom-BxBase64
#>
function ConvertFrom-BxBase64 {
    Param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [String]$InputString
    )

    $DecodedBytes = [System.Convert]::FromBase64String($InputString)
    return [System.Text.Encoding]::Utf8.GetString($DecodedBytes)
}
