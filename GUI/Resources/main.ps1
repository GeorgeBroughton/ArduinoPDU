
# This nukes the environment variables in PowersHell so that i can re-run the script in PowersHell ISE without wondering why half of it hasn't changed when i accidentally break something.
Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear(); Clear-Host

$DebugPreference = 'Continue'

Write-Debug "Running from $PSScriptRoot"
# Instead of dumping 20k lines of code into a single file and making it an unreadable mess, i've split it up and categorised them in the below documents that look like this: " . ("path to file")"
# Please note, the files MUST BE IN THIS ORDER. If they aren't, and say, functions is above form, then it'll open, but nothing will work. Nothing may even appear.

 . ($PSScriptRoot + "\includes\init.ps1")      # Initialisation stuff sits here. Arbitrary C code to extract icons from DLLs etc are there too.

# Load Settings from script location\Resources\Config\

$savepath = $PSScriptRoot + "\Config\Settings.json" # How the directory is set.
Write-Debug "Loading settings from $savepath"
try{ $script:Settings = (Get-content -Raw -Path $savepath | ConvertFrom-Json) }
Catch { [System.Windows.MessageBox]::Show("The settings file didn't load.",'Error','Ok','Error') }

Write-Debug "Loading pre_form_functions.ps1..."
 . ($PSScriptRoot + "\includes\pre_form_functions.ps1")  # Functions that need to exist pre-form-initialization go here. Main backend code. Shit like that.

Write-Debug "Connecting to PDU..."
[void](ConnPDU) # Connects to the PDU and sets script-wide variables for the attained information.

Write-Debug "Loading form data..."
 . ($PSScriptRoot + "\includes\form.ps1")                # Light winforms functions and initialization go here. If you want to change how the form looks, look no further than form.ps1 in the includes file.
Write-Debug "Loading post form functions..."
 . ($PSScriptRoot + "\includes\post_form_functions.ps1") # Functions that need to exist post-form-initialization go here.

Write-Debug "Setting form size parameters..."
form_resize # Calculates the winforms icon sizes and a bunch of other shit to do with element dimensions.
Write-Debug "Loading button icons... (Deprecated)"
RefreshIcons # Loads the icons for the buttons.

# Opens the form
Write-Debug "Showing dialog."
[void]$Form.ShowDialog()

#Write-Debug "Saving settings to $savepath"
#Write-Debug "Saving settings file to $savepath"
#Write-Debug "Saving is disabled in this version due to compliance issues."
#$script:Settings | ConvertTo-Json -Depth 100 -Compress | Out-File -FilePath $savepath

# Gracefully closes the port
if ($script:port) {$port.close()}

# Script end.