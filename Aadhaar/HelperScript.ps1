# Global variable
$global:pdfPath = ""


# OpenFileDialog box helper function
function helperOpenFileDialog
{   
    param($sender, $e)
    $OpenFileDialog = New-Object -TypeName Microsoft.Win32.OpenFileDialog
	$OpenFileDialog.Filter = "PDF files (*.pdf)|*.pdf"
	$result = $OpenFileDialog.ShowDialog()
	if($result -eq "Ok"){
		$lblFilePath.Content = $OpenFileDialog.SafeFileName
		$global:pdfPath = $OpenFileDialog.FileName
		$txtBoxPass.IsEnabled = $true
		$lblPass.IsEnabled = $true
		$lblFilePath.IsEnabled = $true
	}
	else{
		$lblFilePath.Content = "No file selected"
		$txtBoxPass.IsEnabled = $false
		$lblPass.IsEnabled = $false
		$lblFilePath.IsEnabled = $true
	}
}


# Decrypts Encrypted PDF
function helperDecrypt {
	param($sender, $e)
	$workingDir = Split-Path -Path $global:pdfPath
    $outputDir = Join-Path -Path $PSScriptRoot -ChildPath "aadhar_decrypted.pdf"
	qpdf.exe --password=$global:pdfPass --decrypt $global:pdfPath $outputDir
}


# Executes Wolfram Language Script
function helperAadhaar {
	param(
		 [String]$arg2
	)
	$arg1 = "aadhar_decrypted.pdf"
	$aadhaarGen = [ScriptBlock]::Create("Quiet.exe $PSScriptRoot\AadhaarGen.wls $arg1 $arg2")
	Invoke-Command -ScriptBlock $aadhaarGen
}


# Delete only selected generated files/folders in current directory except .exe,.wls
function helperEmptyFolder {
	param($sender, $e)
	$del1 = [scriptblock]::create("get-childitem * -include aadhar_decrypted.pdf,buildAadhaarAll.tex,buildAadhaar.tex,aadhar_decrypted.png -recurse | Remove-Item -recurse")
	$del2 = [scriptblock]::create("get-childitem * output -recurse | Remove-Item -recurse")
	$del3 = [scriptblock]::create("get-childitem * views -recurse | Remove-Item -recurse")
	invoke-command -scriptblock $del1
	invoke-command -scriptblock $del2
	invoke-command -scriptblock $del3
}


# Opens Reference PDF
function helperShowReference {
	$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "output\buildAadhaarAll.pdf"
    Invoke-Item $outputDir
}


# Opens Selected PDF
function helperShowSelected {
	$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "output\buildAadhaar.pdf"
    Invoke-Item $outputDir
}
