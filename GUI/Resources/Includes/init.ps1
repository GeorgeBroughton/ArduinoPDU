# sticking all the includes and framework addins in here because i don't want things super cluttered.

# Adds a function from Kernel32.dll and user32.dll to get the console window and hide it.
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

# Uses the pointer just generated to hide the console window.
[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | out-null

# Creates an icon extractor we can use to pull icons from exe files and all sorts of other fun stuff
$code = @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;

namespace System
{
	public class IconExtractor
	{

	 public static Icon Extract(string file, int number, bool largeIcon)
	 {
	  IntPtr large;
	  IntPtr small;
	  ExtractIconEx(file, number, out large, out small, 1);
	  try
	  {
	   return Icon.FromHandle(largeIcon ? large : small);
	  }
	  catch
	  {
	   return null;
	  }

	 }
	 [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
	 private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);

	}
}
"@

# Adds the icon extractor to the System.Drawing assembly.
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing
# Needed for making error messages
Add-Type -AssemblyName PresentationFramework
# Needed for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
# Adds the System.Drawing assembly.
Add-Type -AssemblyName System.Drawing
# Needed for the File, Options menus
Add-Type -AssemblyName presentationCore

# Makes the windows forms not look like shit.
[System.Windows.Forms.Application]::EnableVisualStyles()