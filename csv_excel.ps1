$Date = (get-date -format "dd.MM.yyyy")

$csv = Join-Path "C:\Users\husseio011\Desktop\"
$xls = Join-Path "C:\Users\husseio011\Desktop\"

$xl = new-object -comobject excel.application
$xl.visible = $false
$Workbook = $xl.workbooks.open($csv)
$Worksheets = $Workbooks.worksheets

$Workbook.SaveAs($XLS,1)
$Workbook.Saved = $True

$xl.Quit()