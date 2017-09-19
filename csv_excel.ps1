﻿$Date = (get-date -format "dd.MM.yyyy")

$csv = Join-Path "***"
$xls = Join-Path "***"

$xl = new-object -comobject excel.application
$xl.visible = $false
$Workbook = $xl.workbooks.open($csv)
$Worksheets = $Workbooks.worksheets

$Workbook.SaveAs($XLS,1)
$Workbook.Saved = $True

$xl.Quit()
