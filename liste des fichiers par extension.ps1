Get-ChildItem -Recurse -Path "d:\" -Include *.mp3,*.mp4,*.avi -ErrorAction silentlycontinue | ForEach {
#    Write-Progress -activity "Fichiers Multimédia" -Status $_.FullName
    $extension = $_.name.split(".")[-1]
    $size = “{0:N2}” -f ($_.Length/1mb) #Affichage 10000 -> 10 000
    $logfile = ".\logs\" + $extension + ".csv"
    $present = Test-Path -Path $logfile
        if ( $present -ne "true") {
            Write-host "Création de $logfile"
            $resfile = New-Item -ItemType file -Path $logfile -Force
            Add-Content -Path $logfile -Value "Nom;Chemin;Taille"
            Add-Content -Path $logfile -Value "$($_.name );$($_.DirectoryName);$($size)"
        }
        Else {
            Add-Content -Path $logfile -Value "$($_.name );$($_.DirectoryName);$($size)"
        }
}