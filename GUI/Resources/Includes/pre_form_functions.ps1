# This file holds a bunch of functions for various things this application does.
# All of which you see here, will be replaced with a class.

function ConnPDU() {
  if ($script:port) {$script:port.close()}
  ForEach($script:portlist in $([System.IO.Ports.SerialPort]::getportnames())) {
    try {
      $script:port = new-Object System.IO.Ports.SerialPort $portlist,9600,None,8,one
      $script:port.ReadTimeout = 500;
      $script:port.WriteTimeout = 500;
      $script:port.DtrEnable = "true"
      Write-Debug "Checking for PDU on port $portlist"
      $script:port.open()
        $script:port.WriteLine("?")
        $LineRead = $script:port.ReadLine()
        if ($LineRead.split(":")[0] -match "BS_PDU_MK2") { 
          Write-Debug "PDU found on $portlist"
          Write-Debug "Starts at pin $($LineRead.split(":")[1].split(",")[0])"
          $script:StartPin = $LineRead.split(":")[1].split(",")[0]
          Write-Debug "Ends at pin $($LineRead.split(":")[1].split(",")[1])"
          $script:EndPin = $LineRead.split(":")[1].split(",")[1]
          return $portlist
        }
      $script:port.close()
    }

    Catch {
      continue
    }
  }
}

function SendPDU() {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory=$True)][Int][ValidateRange(0,127)]$PinNumber,
    [parameter(Mandatory=$True)][int][ValidateRange(0,1)]$Value
  )

    try { if ($script:port) {
      $script:port.WriteLine("S$PinNumber,$Value")
      Write-Debug "Sent S$PinNumber,$Value"
      $retval = $script:port.ReadLine()
      Write-Debug "Returned $retval"
      return $retval
    }}

    catch [TimeoutException] {
[System.Windows.MessageBox]::Show("An error occurred. Here's a stack trace:
$($_.ScriptStackTrace)",'Warning','Ok','Warning')
    }
}

function CheckPDU() {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory=$True)][Int][ValidateRange(0,127)]$PinNumber
  )
    
    try { if ($script:port) {
      $script:port.WriteLine("G$PinNumber")
      Write-Debug "Sent G$PinNumber"
      $retval = $script:port.ReadLine()
      Write-Debug "Returned $retval"
      return $retval
    }}

    catch [TimeoutException] {
[System.Windows.MessageBox]::Show("An error occurred. Here's a stack trace:
$($_.ScriptStackTrace)",'Warning','Ok','Warning')
    }
}

function TogglePDU() {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory=$True)][Int][ValidateRange(0,127)]$PinNumber
  )
    Write-Debug "Toggling $PinNumber"
    $retval = (SendPDU -PinNumber $PinNumber -Value (1 - [int]$(CheckPDU -PinNumber $PinNumber)))
    Write-Debug "Returned $retval"
  return $retval
}