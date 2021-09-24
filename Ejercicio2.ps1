<#
 .SYNOPSIS
  El script que permite renombrar los archivos de una colección de fotos. Los nombres de sus archivos deben tener el siguiente formato: “yyyyMMdd_HHmmss.jpg” y se renombra con el siguiente formato: “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”. Se considera como cena cualquier foto de comida hecha después de las 19hs.
 .DESCRIPTION
  Se renombrara los archivos.
 .PARAMETER Directorio
  (Parámetro obligatorio) Path del directorio donde se encuentra las fotos.
 .PARAMETER Dia
  Dia de la semana a la cual no se le cambiara el nombre.
 .EXAMPLE 
  \Ejercicio2.ps1 -Directorio '.\Imagenes ejemplo'
 .EXAMPLE 
  \Ejercicio2.ps1 -Directorio '.\Imagenes ejemplo' -Dia LUnes
#>
Param(
    [Parameter(HelpMessage="Es el directorio donde se encuentran las imágenes.",
              Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({if(Test-Path $_){$true}else{Throw "Error: Directorio invalido"}})]
    [string]$Directorio,
    [Parameter(HelpMessage="Es el nombre de un día para el cual no se quieren renombrar los archivos. Los valores posibles para este parámetro son los nombres de los días de la semana (sin 
tildes.")]
    [ValidateScript({if($_.ToLower() -eq 'lunes' -or $_.ToLower() -eq 'martes' -or $_.ToLower() -eq 'miercoles' -or $_.ToLower() -eq 'jueves' -or $_.ToLower() -eq 'viernes' -or $_.ToLower() -eq 'viernes' -or $_.ToLower() -eq 'sabado' -or $_.ToLower() -eq 'doming'){$true}else{Throw "Error: Dia invalido"}})]
    [string]$Dia
)

Get-ChildItem $Directorio -Include "*.jpg" -Recurse -Force |
where{$_.Name -match '[0-9]{8}_[0-9]{6}.jpg'}|
foreach{
    $nameFile=[System.IO.Path]::GetFileNameWithoutExtension($_)
    $culture=[Globalization.cultureinfo]::GetCultureInfo(“es-ES”)
    $fecha=[datetime]::ParseExact($nameFile,"yyyyMMdd_HHmmss",$culture)
    $comida = if(($fecha.Hour) -ge 19){"cena"}else{"almuerzo"}
    $dayOfWeek=(Get-Date $fecha).ToString('dddd')

    if($Dia -ne ''){
        switch ($Dia.ToLower()){
            'sabado'{$Dia="sábado"}
            'miercoles'{$Dia="miércoles"}
            default{$Dia=$Dia.ToLower()}
        }
    }
    if($Dia -ne $dayOfWeek){
        Rename-Item $_.FullName "$((Get-Date $fecha).ToString('dd-MM-yyyy')) $($comida) del $($dayOfWeek).jpg"
    }
}