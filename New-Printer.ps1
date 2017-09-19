[CmdletBinding()]
Param
(
[Alias("Path")]
[Parameter(Mandatory=$False,Position=0)]
[String]$Fichier
)

if($Fichier){
    Import-Csv -Path $Fichier -Delimiter ";" | % {
    $Name = $_.Host
    $PortName = $_.Port
    $Driver = $_.Driver
    $Server = $_.Serveur
    $Agence = $_.Location

    $PortExiste = (Get-PrinterPort).Name -contains $PortName
    if (!$PortExiste)
        {
        Add-PrinterPort -Name $Name -PrinterHostAddress $Name
        }
    Add-Printer -Name $Name -DriverName $Driver -PortName $PortName -Shared -ShareName $Name -ComputerName $Server -Location $Agence
    }
    }
    else 
        {
        $Name = Read-Host -Prompt 'Entrez le nom de l`imprimante à créer:'
        $PortName = Read-Host -Prompt 'Entrez le nom du port associé:'
        $Driver = Read-Host -Prompt 'Entrez le nom du driver:'
        $Server = Read-Host -Prompt 'Entrez le nom du serveur d`impression:'
        $Agence = Read-Host -Prompt 'Entrez la location de l`imprimante:'
        $PortExiste = (Get-PrinterPort).Name -contains $PortName
        if (!$PortExiste)
            {
            Add-PrinterPort -Name $Name -PrinterHostAddress $Name
            }
        Add-Printer -Name $Name -DriverName $Driver -PortName $PortName -Shared -ShareName $Name -ComputerName $Server -Location $Agence
        }