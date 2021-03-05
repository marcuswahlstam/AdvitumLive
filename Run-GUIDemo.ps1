<#
This is a demo PowerShell script to display a simple WPF GUI.
Created by: Marcus Wahlstam, Advitum AB
Date: 2021-03-05
#>


#==================================
# Load Assemblies
#==================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

#======================================
# Load XML (generated in Visual Studio)
#======================================
$inputXML = @"
<Window x:Name="mainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Advitum_Live_Demo"
        Title="Advitum Live Demo" Height="444" Width="561" WindowStyle="SingleBorderWindow">
    <Grid Background="#FF1A59FF">
        <Label x:Name="lblHeader" Content="Demo-app Advitum Live" HorizontalAlignment="Center" Margin="0,42,0,0" VerticalAlignment="Top" Foreground="White" FontSize="36" FontWeight="Bold"/>
        <Label x:Name="lblNumber" Content="&lt;nummer&gt;" HorizontalAlignment="Center" Margin="0,294,0,0" VerticalAlignment="Top" FontSize="24" Foreground="White"/>
        <Button x:Name="btnGenerate" Content="Generera ett nummer" HorizontalAlignment="Center" Margin="0,202,0,0" VerticalAlignment="Top" Background="{x:Null}" BorderBrush="White" Foreground="White" FontSize="20" IsDefault="True" Padding="5,1,5,1" UseLayoutRounding="False" BorderThickness="2,2,2,2"/>
        <Button x:Name="btnClose" Content="Stäng" Margin="0,0,30,30" Background="{x:Null}" BorderBrush="White" Foreground="White" Padding="5,1,5,1" HorizontalAlignment="Right" Width="46" Height="24" VerticalAlignment="Bottom"/>

    </Grid>
</Window>
"@

# Replace elements that Powershell can't handle 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:Name",'Name'

# Read XML
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $XAML)

# Load XML
try
{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch
{
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}

#==================================
# Load XML Objects In PowerShell
# Creates PS variables with prefix "WPF"
#==================================
$XAML.SelectNodes("//*[@Name]") | foreach {
    try 
    {
        Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop
    }
    catch
    {
        throw "Could not set variable for $($_.Name)"
    }
}


#==================================
# Set WPF properties and actions
#==================================
# Add text to label "lblNumber"
$WPFlblNumber.Content = "Klicka på knappen för att generera ett nummer"

# Add click action to button "btnGenerate"
$WPFbtnGenerate.add_Click({
    $WPFlblNumber.Content = Get-Random -Minimum 0 -Maximum 100
})

# Add click action to button "btnClose"
$WPFbtnClose.add_Click({
    $Form.Close()
})

#==================================
# Show GUI
#==================================

# Uncomment next line to display created PS GUI Variables
#Get-Variable wpf*

# Show GUI
$Form.ShowDialog() | Out-Null
