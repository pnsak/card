function Add-ControlVariables {
	New-Variable -Name 'btnBrowse' -Value $window.FindName('btnBrowse') -Scope 1 -Force
	New-Variable -Name 'btnProcess' -Value $window.FindName('btnProcess') -Scope 1 -Force
	New-Variable -Name 'btnClear' -Value $window.FindName('btnClear') -Scope 1 -Force
	New-Variable -Name 'lblFilePath' -Value $window.FindName('lblFilePath') -Scope 1 -Force
	New-Variable -Name 'txtBoxPass' -Value $window.FindName('txtBoxPass') -Scope 1 -Force
	New-Variable -Name 'cbOptions' -Value $window.FindName('cbOptions') -Scope 1 -Force
	New-Variable -Name 'btnShowReference' -Value $window.FindName('btnShowReference') -Scope 1 -Force
	New-Variable -Name 'btnShowSelected' -Value $window.FindName('btnShowSelected') -Scope 1 -Force
	New-Variable -Name 'gbViewSelected' -Value $window.FindName('gbViewSelected') -Scope 1 -Force
    New-Variable -Name 'btnFinalProcess' -Value $window.FindName('btnFinalProcess') -Scope 1 -Force
    New-Variable -Name 'appWindow' -Value $window.FindName('appWindow') -Scope 1 -Force
	New-Variable -Name 'grid1' -Value $window.FindName('grid1') -Scope 1 -Force
	New-Variable -Name 'lblPass' -Value $window.FindName('lblPass') -Scope 1 -Force
}


#$ThemeFile1 = Join-Path -Path $PSScriptRoot -ChildPath Themes\MetroDark.MSControls.Core.Implicit.xaml
#$ThemeFile2 = Join-Path -Path $PSScriptRoot -ChildPath Themes\MetroDark.MSControls.Toolkit.Implicit.xaml

function Load-Xaml {
	[xml]$xaml = Get-Content -Path $PSScriptRoot\Aadhaar.xaml
	$manager = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xaml.NameTable
	$manager.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
	$xaml.SelectNodes("//*[@x:Name='btnBrowse']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='btnProcess']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='btnShowReference']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='btnClear']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='btnShowSelected']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='btnFinalProcess']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='cbOptions']", $manager)[0].RemoveAttribute('SelectionChanged')
	$xaml.SelectNodes("//*[@x:Name='appWindow']", $manager)[0].RemoveAttribute('Closed')
	$xaml.SelectNodes("//*[@x:Name='appWindow']", $manager)[0].RemoveAttribute('MouseDown')
	$xaml.SelectNodes("//*[@x:Name='txtBoxPass']", $manager)[0].RemoveAttribute('TextChanged')
	$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
	[Windows.Markup.XamlReader]::Load($xamlReader)
}


function Set-EventHandlers {

	$btnBrowse.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		btnBrowse_Click($sender,$e)
	})
	$btnProcess.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		btnProcess_Click($sender,$e)
	})
	$btnShowReference.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		btnShowReference_Click($sender,$e)
	})
	$btnClear.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		btnClear_Click($sender,$e)
	})
	$btnShowSelected.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		btnShowSelected_Click($sender,$e)
	})
	$btnFinalProcess.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		btnFinalProcess_Click($sender,$e)
	})
	$cbOptions.add_SelectionChanged({
		param([System.Object]$sender,[System.Windows.Controls.SelectionChangedEventArgs]$e)
		cbSelectionChanged($sender,$e)
	})
	$appWindow.add_Closed({
		param([System.Object]$sender,[System.EventArgs]$e)
		appWindow_Closed($sender,$e)
	})
	$cbOptions.add_SelectionChanged({
		param([System.Object]$sender,[System.Windows.Controls.SelectionChangedEventArgs]$e)
		cbSelectionChanged($sender,$e)
	})
	$cbOptions.add_SelectionChanged({
		param([System.Object]$sender,[System.Windows.Controls.SelectionChangedEventArgs]$e)
		cbSelectionChanged($sender,$e)
	})
	$appWindow.add_MouseDown({
		param([System.Object]$sender,[System.Windows.Input.MouseButtonEventArgs]$e)
		appWindow_MouseDown($sender,$e)
	})
	$txtBoxPass.add_TextChanged({
		param([System.Object]$sender,[System.Windows.Controls.TextChangedEventArgs]$e)
		txtBoxPass_TextChanged($sender,$e)
	})
}


$window = Load-Xaml
Add-ControlVariables
Set-EventHandlers

# Import out functions into this script
. "$PSScriptRoot\HelperScript.ps1"
$wls = Test-Path -Path $PSScriptRoot\AadhaarGen.wls
if(!($wls)){
	Invoke-WebRequest 'https://raw.githubusercontent.com/pnsak/card/master/Resources/AadhaarGen.wls' -OutFile .\AadhaarGen.wls
}

$global:pdfPass =""


function btnBrowse_Click
{
	param($sender, $e)
	helperOpenFileDialog
}


function btnProcess_Click
{
	param($sender, $e)
    $global:pdfPass = $txtBoxPass.Text
	$btnProcess.IsEnabled = $false
	$txtBoxPass.IsEnabled = $false
	helperDecrypt 
	helperAadhaar -arg2 all
	do{
		$pathTest = Test-Path -Path $PSScriptRoot\output\buildAadhaarAll.pdf
		if (!($pathTest)){
			start-sleep -s 3
		}
	}
	until($pathTest)
	$btnShowReference.IsEnabled = $true
	$gbViewSelected.IsEnabled = $false
	$btnClear.IsEnabled = $true
}


function btnClear_Click
{
	param($sender, $e)
	helperEmptyFolder
	$btnProcess.IsEnabled = $false
	$btnShowReference.IsEnabled = $false
	$btnClear.IsEnabled = $false
	$gbViewSelected.IsEnabled = $false
	$txtBoxPass.text = ""
	$lblFilePath.Content = "Select a file"
	$cbOptions.SelectedIndex = 0
	$txtBoxPass.IsEnabled = $false
	$lblPass.IsEnabled = $false
	$lblFilePath.IsEnabled = $false
}


function btnShowReference_Click
{
	param($sender, $e)
	helperShowReference
    $gbViewSelected.IsEnabled = $true
}


function btnShowSelected_Click
{
	param($sender, $e)
	helperShowSelected
}


function btnFinalProcess_Click
{
	param($sender, $e)
	$wlspara2 = $cbOptions.SelectedItem.Content
    $pdfPass = $txtBoxPass.Text
	$btnFinalProcess.IsEnabled = $false
    helperDecrypt
	helperAadhaar -arg2 $wlspara2
	do{
		$pathTest = Test-Path -Path $PSScriptRoot\output\buildAadhaar.pdf
		if (!($pathTest)){
			start-sleep -s 3
		}
    }
    until($pathTest)
	$btnShowSelected.IsEnabled = $true
	$btnClear.IsEnabled = $true
}


function cbSelectionChanged
{
	param($sender, $e)
	$btnFinalProcess.IsEnabled = $true
	$btnShowSelected.IsEnabled = $false
	$delBuildAadhaar = [scriptblock]::create("get-childitem * output\buildAadhaar.pdf -recurse | Remove-Item -recurse")
	invoke-command -scriptblock $delBuildAadhaar
}


function appWindow_Closed
{
	param($sender, $e)
    helperEmptyFolder
}



function appWindow_MouseDown
{
	param($sender, $e)
	$grid1.Focus()
}


function txtBoxPass_TextChanged
{
	param($sender, $e)
	if($txtBoxPass.Text.Length -ne 0){
		$btnProcess.IsEnabled = $true
	}
	else{
		$btnProcess.IsEnabled = $false
	}
}


$window.ShowDialog()
