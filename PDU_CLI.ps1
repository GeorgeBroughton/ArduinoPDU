class PDU {

    hidden [System.IO.Ports.SerialPort]$Device
    [int]$StartPin
    [int]$EndPin
    [string]$Port

    [PDU] Connect () {
        if ($This.Device) {$This.Device.close()}
        ForEach( $Port in $([System.IO.Ports.SerialPort]::getPortnames())) {
            try {
                $This.Device = new-Object System.IO.Ports.SerialPort $Port,9600,None,8,one
                $This.Device.ReadTimeout = 500;
                $This.Device.WriteTimeout = 500;
                $This.Device.DtrEnable = "true"

                $This.Device.open()
                $This.Device.WriteLine("?")
                $LineRead = $This.Device.ReadLine()
                if ($LineRead.split(":")[0] -match "BS_PDU_MK2") {
                    $This.Port = $Port
                    $This.StartPin = $LineRead.split(":")[1].split(",")[0]
                    $This.EndPin = $LineRead.split(":")[1].split(",")[1]
                    return $This
                }
                $This.Device.close()
            }
            Catch {
                $This.Device.close()
                Continue
            }
        }
        return $This
    }

    [void] Disconnect () {
        $This.Device.DiscardInBuffer()
        $This.Device.close()
    }

    [int] SetV ([Int]$PinNumber,[bool]$Value) {
        try {
            if ($This.Device) {
                $This.Device.DiscardInBuffer()
                $This.Device.WriteLine("S$PinNumber,$Value")
                return $This.Device.ReadLine()
            }
            return "Not Connected!"
        }
        catch {
            return "Not Connected!"
        }
    }

    [void] Set ([Int]$PinNumber,[bool]$Value) {
        try {
            if ($This.Device) {
                $This.Device.DiscardInBuffer()
                $This.Device.WriteLine("S$PinNumber,$Value")
            }
        }
        Catch {
            continue
        }
    }

    [int] Get ([Int]$PinNumber) {
        try {
            if ($This.Device) {
                $This.Device.DiscardInBuffer()
                $This.Device.WriteLine("G$PinNumber")
                return $This.Device.ReadLine()
            }
            return "Not Connected!"
        }
        catch {
            return "Not Connected!"
        }
    }

    [void] Toggle ([Int]$PinNumber) {
        $This.Device.DiscardInBuffer()
        $This.Set($PinNumber,(1 - [int]$($This.Get($PinNumber))))
        return
    }
    
    [int] ToggleV ([Int]$PinNumber) {
        $This.Device.DiscardInBuffer()
        return $This.SetV($PinNumber,(1 - $This.Get($PinNumber)))
    }

}

class DeskPDU : PDU {

    [void] Hubs ([bool]$Value) {
        $This.Set(13,$Value)
        $This.Set(10,$Value)
        return
    }
    
    [void] Monitors ([bool]$Value) {
        $This.Set(15,$Value)
        $This.Set(14,$Value)
        $This.Set(12,$Value)
        $This.Set(11,$Value)
        return
    }
    
    [void] Fans ([bool]$Value){
        $This.Set(6,$Value)
        return
    }
    
    [void] SolderingIron ([bool]$Value) {
        $This.Set(1,$value)
        return
    }

    [void] Oscilloscope ([bool]$Value) {
        $This.Set(2,$value)
        return
    }

}

<#
$PDU = [PDU]::New()
$PDU.Connect()
$PDU.Set(0,1)
$PDU.Set(0,0)
$PDU.SetV(0,1)
$PDU.SetV(0,0)
$PDU.Toggle(0)
$PDU.Get(0)
$PDU.ToggleV(0)
$PDU.Disconnect()
#>

<#
$PDU = [DeskPDU]::New()
$PDU.Connect()
$PDU.Set(0,1)
$PDU.Set(0,0)
$PDU.SetV(0,1)
$PDU.SetV(0,0)
$PDU.Toggle(0)
$PDU.Get(0)
$PDU.ToggleV(0)
$PDU.Hubs(0)
$PDU.Hubs(1)
$PDU.Monitors(0)
$PDU.Monitors(1)
$PDU.Fans(0)
$PDU.Fans(1)
$PDU.SolderignIron(0)
$PDU.SolderignIron(1)
$PDU.Oscilloscope(0)
$PDU.Oscilloscope(1)
$PDU.Disconnect()
#>