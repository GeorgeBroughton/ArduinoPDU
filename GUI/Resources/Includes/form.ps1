
# -- Form Initialization --

# Produces the main window you see

$Form                 = New-Object system.Windows.Forms.Form                       # How the form is created.
$Form.MinimumSize     = '384,177'                                                  # Form minimum size (Width x height)
#$Form.AutoSize        = $true
$Form.ClientSize      = '384,177'
$Form.StartPosition   = "CenterScreen"                                             # This determines where the form opens up.
$Form.text            = "PDU Control Tool Alpha 9.2.3"                             # Main Window title.
$Form.SizeGripStyle   = 'hide'                                                     # Seems to do fucking nothing, but i guess we'll keep it in, incase microsoft want to fix their garbage.
$Form.Icon            = [System.IconExtractor]::Extract("shell32.dll", 12, $false) # Uses the chippo icon from shell32.dll.
$Form.ShowInTaskbar   = $true                                                      # Allows you to hide the icon from the taskbar, we're keeping it though.

# Toolbar under the titlebar. Contains things like File, Options and Help. Note the indentation. If something's indented below here, it means it's an object you get to from the thing above.

$MenuBar      = New-Object System.Windows.Forms.MenuStrip # Menu strip object initialization.
#$MenuBar.Dock = [System.Windows.Forms.DockStyle]::Top

  # File menu

  $Menu_File      = New-Object System.Windows.Forms.ToolStripMenuItem # File menu object initialization.
  $Menu_File.Font = $Settings.Font                                    # Grabs the font value from the settings file. If left undefined, this defaults to the system font.
  $Menu_File.Text = "&File"                                           # The text you see on the File button.

    # Connect button

    $Menu_Connect              = New-Object System.Windows.Forms.ToolStripMenuItem          # Connect button object initialization.
    $Menu_Connect.Text         = "&Connect"                                                 # The text you see on the Connect button.
    $Menu_Connect.Font         = $Settings.Font                                             # Grabs the font value from the settings file. If left undefined, this defaults to the system font.
    $Menu_Connect.Image        = [System.IconExtractor]::Extract("setupapi.dll", 16, $true) # The icon that shows next to the button. In this case, it's a USB cable.
    $Menu_Connect.ShortcutKeys = "F5"                                                       # The shortcut key that runs the code attached to the button. See the *.Add_Click line below for details.
    $Menu_Connect.Add_Click({ConnPDU})                                                      # The function that is run when the button is pressed. In this case, it re-runs the PDU connect function.
    
    # Reload button

    $Menu_Reload              = New-Object System.Windows.Forms.ToolStripMenuItem          # Reload button object initialization.
    $Menu_Reload.Text         = "&Reload Settings"                                         # The text you see on the Reload Settings button.
    $Menu_Reload.Font         = $Settings.Font                                             # Grabs the font value from the settings file. If left undefined, this defaults to the system font.
    $Menu_Reload.Image        = [System.IconExtractor]::Extract("shell32.dll", 238, $true) # The icon that shows next to the button. In this case, the code is disabled because the refresh icon doesn't seem to be available in the windows files.
    $Menu_Reload.ShortcutKeys = "F6"                                                       # The shortcut key that runs the code attached to the button. See the *.Add_Click line below for details.
    $Menu_Reload.Add_Click({                                                               # The function that is run when the Reload Settings button is pressed. Here, code is just dumped straight in, not referencing functions elsewhere. Not much of a problem though. This is generally frowned upon because if you need to run this elsewhere, then you can't really do so, but this was only created for debugging. I have no intention of keeping it.

      $script:Settings = (Get-content -Raw -Path $savepath | ConvertFrom-Json) # Loads the settings from the settings file.

      RefreshIcons
      RefreshPinStats

    })
    
    # Exit button

    $Menu_Exit              = New-Object System.Windows.Forms.ToolStripMenuItem          # Exit button object initialization.
    $Menu_Exit.Text         = "&Exit"                                                    # The text you see on the Exit button.
    $Menu_Exit.Font         = $Settings.Font                                             # Grabs the font value from the settings file. If left undefined, this defaults to the system font.
    $Menu_Exit.Image        = [System.IconExtractor]::Extract("shell32.dll", 131, $true) # The icon that shows to next to the Exit button.
    $Menu_Exit.ShortcutKeys = "Alt, F4"                                                  # The shortcut key that runs the code attached to the button. See the *.Add_Click line below for details.
    $Menu_Exit.Add_Click({$Form.Close()})                                                # The function that is run when the Exit button is pressed. Here, it just closes the form. The rest of the code in main.ps1 after $Form.ShowDialog() is then run, gracefully closing the program.

  $Menu_File.DropDownItems.AddRange(@($Menu_Connect,$Menu_Reload,$Menu_Exit)) # Adds all the buttons we just defined to the File drop down menu.

  # Options menu

  $Menu_Options      = New-Object System.Windows.Forms.ToolStripMenuItem # Options button object initialization.
  $Menu_Options.Text = "&Options"                                        # The text you see on the Options button.
  $Menu_Options.Font = $Settings.Font                                    # Grabs the font value from the settings file. If left undefined, this defaults to the system font.

    # Always on top button
    
    $Menu_Options_AlwaysOnTop         = New-Object System.Windows.Forms.ToolStripMenuItem # Always on Top button object initialization.
    $Menu_Options_AlwaysOnTop.Text    = "&Always On Top"                                  # The text you see on the Always on Top button.
    $Menu_Options_AlwaysOnTop.Font    = $Settings.Font                                    # Grabs the font value from the settings file. If left undefined, this defaults to the system font.
    $Menu_Options_AlwaysOnTop.Add_Click({                                                 # The function that is run when the Always on Top button is pressed. See below for details.
      if ($Menu_Options_AlwaysOnTop.Checked -eq $true) {                                  # Checks if the button is already checked.
        $Menu_Options_AlwaysOnTop.Checked = $false                                        # If it is, it clears the check in the box.
        $Form.TopMost = $false                                                # Then, it disables always on top for the form.
      } else {                                                                # 
        $Menu_Options_AlwaysOnTop.Checked = $true                             # If it wasn't ticked, then it checks the box.
        $Form.TopMost = $true                                                 # Then, it enables always on top for the form.
      }
    })
    
  # Add above menu items to the toolbar link

  $Menu_Options.DropDownItems.AddRange(@($Menu_Options_AlwaysOnTop)) # Adds the options menu items to the Options drop down menu.

  # Profile menu

  $Menu_Profile      = New-Object System.Windows.Forms.ToolStripMenuItem # Profile button object initialization.
  $Menu_Profile.Text = "&Profile"                                        # The text you see on the Profile button.
  $Menu_Profile.Font = $Settings.Font                                    # Grabs the font value from the settings file. If left undefined, this defaults to the system font.

    # Profiles loaded from profiles.json
    
    foreach ( $buttonproperty in $Settings.Profiles.PSObject.Properties ) { # This iterates through the settings file to create a new button for each profile there is configured in there.
      $Menu_Profile_Button = New-Object System.Windows.Forms.ToolStripMenuItem    # Specified profile button object initialisation
      $Menu_Profile_Button.Text = $buttonproperty.Name                            # Button text that is specified in the profile config.
      $Menu_Profile_Button.Name = $buttonproperty.Name                            # Button name, generated from the profile name. (this is different to the text that shows on it)
      [void]$Menu_Profile.DropDownItems.Add($Menu_Profile_Button)                 # Adds the button to the menu.
      $Menu_Profile_Button.Add_Click({                                            # Produces a function for the button that turns the specifed set of pins off and on.
        if ($this.Checked -eq $true) {
          foreach ( $pinproperty in $Settings.Profiles.($this.Name).Pins ) {
            SendPDU -PinNumber $pinproperty -Value (1 - $Settings.Profiles.($this.Name).checkedvalue)
          }
          $this.Checked = $false
        } else {
          foreach ( $pinproperty in $Settings.Profiles.($this.Name).Pins ) {
            SendPDU -PinNumber $pinproperty -Value $Settings.Profiles.($this.Name).checkedvalue
          }
          $this.Checked = $true
        }
    })
}

  # Help menu item

  $Menu_Help         = New-Object System.Windows.Forms.ToolStripMenuItem
  $Menu_Help.Text    = "&Help"
  $Menu_Help.Font    = $Settings.Font

    # About menu item

    $Menu_Help_About              = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_Help_About.Image        = [System.Drawing.SystemIcons]::Information
    $Menu_Help_About.Text         = "&About"
    $Menu_Help_About.Font         = $Settings.Font
    $Menu_Help_About.ShortcutKeys = "F1"
    $Menu_Help_About.Add_Click({
      About
    })

  $Menu_Help.DropDownItems.AddRange(@($Menu_Help_About))

$Form.MainMenuStrip = $MenuBar

$MenuBar.Items.AddRange(@($Menu_File,$Menu_Options,$Menu_Profile,$Menu_Help))

$StatusBar                 = New-Object System.Windows.Forms.StatusStrip

$StatusBar_Text            = New-Object System.Windows.Forms.ToolStripStatusLabel
$StatusBar_Text.AutoSize   = $true
$StatusBar_Text.Text       = "Ready"

$StatusBar_WinSize            = New-Object System.Windows.Forms.ToolStripStatusLabel
$StatusBar_WinSize.AutoSize   = $true
$StatusBar_WinSize.Text       = "Size " + $Form.width + " x " + $Form.Height
$StatusBar_WinSize.Dock       = [System.Windows.Forms.DockStyle]::Right

[void]$StatusBar.Items.AddRange(@($StatusBar_Text,$StatusBar_WinSize))

# The lines of duct tape that hold this form together are below.

$ToolTip = New-Object System.Windows.Forms.ToolTip

if ($script:port) {$array = ($script:EndPin..$script:StartPin)}

$LayoutPanel_Main               = New-Object System.Windows.Forms.FlowLayoutPanel
$LayoutPanel_Main.FlowDirection = "LeftToRight"
$LayoutPanel_Main.WrapContents  = $true
$LayoutPanel_Main.AutoScroll    = $true
$LayoutPanel_Main.AutoSize      = $true
$LayoutPanel_Main.Dock          = [System.Windows.Forms.DockStyle]::fill

ForEach($button in $array){
  $PDUButton                       = New-Object System.Windows.Forms.Button
  $PDUButton.Name                  = $button
  $PDUButton.Size                  = New-Object System.Drawing.Size(40,40)
  $PDUButton.BackgroundImageLayout = "none"
  $PDUButton.BackgroundImage       = [System.IconExtractor]::Extract($Settings.Ports.($button).Icon.File,$Settings.Ports.($button).Icon.ID,$true)
  
  # sets the color
  if ( [int]$(CheckPDU -PinNumber $PDUButton.Name) -eq 1 ) {
    $PDUButton.BackColor = '#E1E1E1' 
  } else {
    $PDUButton.BackColor = '#FF0000'
  }
  
  $PDUButton.Add_Click({
    if ( [int]$(TogglePDU -PinNumber $this.Name) -eq 1 ) {
      $this.BackColor = '#E1E1E1'
    } else {
      $this.BackColor = '#FF0000'
    }
  })

  $PDUButton.Add_MouseHover({
    $ToolTip.SetToolTip($this,$Settings.Ports.($this.name).Tooltip)
  })
  $LayoutPanel_Main.Controls.Add($PDUButton);
}

$Form.controls.AddRange(@($LayoutPanel_Main,$MenuBar,$StatusBar))

function form_resize() {
  $StatusBar_WinSize.Text = "Size " + $Form.width + " x " + $Form.Height
}

# Spawns the about box

function About {
    $Form.TopMost = $false
    #$StatusBar_Text.Text = "About"
    # About Form Objects
    $AboutForm           = New-Object System.Windows.Forms.Form
    $AboutForm_Exit      = New-Object System.Windows.Forms.Button
    $AboutForm_Image     = New-Object System.Windows.Forms.PictureBox
    $AboutForm_Name      = New-Object System.Windows.Forms.Label
    $AboutForm_Text      = New-Object System.Windows.Forms.Label

    # About Form
    $AboutForm.AcceptButton  = $AboutForm_Exit
    $AboutForm.CancelButton  = $AboutForm_Exit
    $AboutForm.ClientSize    = "350, 110"
    $AboutForm.ControlBox    = $false
    $AboutForm.ShowInTaskBar = $true
    $AboutForm.StartPosition = "CenterParent"
    $AboutForm.Text          = "About"
    $AboutForm.Add_Load($AboutForm_Load)

    # About PictureBox
    #$AboutForm_Image.ImageLocation = $PSScriptRoot + "\..\images\aboutlogo.png"
    $AboutForm_Image.Image         = [System.IconExtractor]::Extract("shell32.dll", 12, $true)
    $AboutForm_Image.SizeMode      = 'zoom'
    $AboutForm_Image.Location      = "40, 15"
    $AboutForm_Image.Size          = "48, 48"
    $AboutForm_Image.SizeMode      = "StretchImage"
    $AboutForm.Controls.Add($AboutForm_Image)

    # About Name Label
    $AboutForm_Name.Font     = New-Object Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Bold)
    $AboutForm_Name.Location = "100, 20"
    $AboutForm_Name.Size     = "200, 18"
    $AboutForm_Name.Text     = $Form.text
    $AboutForm.Controls.Add($AboutForm_Name)

    # About Text Label
    $AboutForm_Text.Location = "100, 40"
    $AboutForm_Text.Size     = "300, 30"
    $AboutForm_Text.Text     = "I know this is a piece of shit."
    $AboutForm.Controls.Add($AboutForm_Text)

    # About Exit Button
    $AboutForm_Exit.Location = "135, 70"
    $AboutForm_Exit.Text     = "OK"
    $AboutForm.Controls.Add($AboutForm_Exit)

    [void]$AboutForm.ShowDialog()
    $Form.TopMost = $Settings.AlwaysOnTop
    #$StatusBar_Text.Text = "Ready"
}

# simple form resize redirection to a function because it needs to be resized when first opened too. No point writing it twice.
$Form.Add_Resize({
  form_resize
})

# Default form settings

  # Always on top

    $Form.TopMost = $Settings.AlwaysOnTop
    $Menu_Options_AlwaysOnTop.Checked = $Settings.AlwaysOnTop