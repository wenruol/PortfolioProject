Attribute VB_Name = "Module1"
Sub pt()
'Declare Variables
Dim PSheet As Worksheet
Dim DSheet As Worksheet
Dim PCache As PivotCache
Dim PTable As PivotTable
Dim PRange As Range
Dim LastRow As Long
Dim LastCol As Long


'Insert a New Blank Worksheet
On Error Resume Next
Application.DisplayAlerts = False
Worksheets("PivotTable").Delete
Sheets.Add After:=ActiveSheet
ActiveSheet.Name = "PivotTable"
Application.DisplayAlerts = True
Set PSheet = Worksheets("PivotTable")
Set DSheet = Worksheets("Data")

'Define Data Range
LastRow = DSheet.Cells(Rows.Count, 1).End(xlUp).Row
LastCol = DSheet.Cells(1, Columns.Count).End(xlToLeft).Column
Set PRange = DSheet.Cells(1, 1).Resize(LastRow, LastCol)
'Define Pivot Cache
Set PCache = ActiveWorkbook.PivotCaches.Create _
(SourceType:=xlDatabase, SourceData:=PRange). _
CreatePivotTable(TableDestination:=PSheet.Cells(2, 2), _
TableName:="PayrollPivotTable")

'Insert Blank Pivot Table
Set PTable = PCache.CreatePivotTable _
(TableDestination:=PSheet.Cells(1, 1), TableName:="PayrollPivotTable")

'Insert Row Fields
With ActiveSheet.PivotTables("PayrollPivotTable").PivotFields("Location")
.Orientation = xlRowField
.Position = 1
.Function = xlSum

End With

'Insert column Field
Dim i As Integer
For i = 1 To 32
    With ActiveSheet.PivotTables("PayrollPivotTable").PivotFields(Worksheets("Fields").Cells(i, 1).Value)
    .Orientation = xlDataField
    .Position = i
    .Function = xlSum
    .NumberFormat = "#,##0"
    .Name = Worksheets("Fields").Cells(i, 1).Value
    End With
Next i


'Insert Data Field
'With ActiveSheet.PivotTables("PayrollPivotTable").PivotFields("E-DTAmount")
'.Orientation = xlDataField
'.Position = 3
'.Function = xlSum
'.NumberFormat = "#,##0"
'.Name = "E-DTAmount"
'End With

Dim pf As PivotField

PTable.ManualUpdate = True
    For Each pf In ActiveSheet.PivotTables("PayrollPivotTable").DataFields
      pf.Function = xlSum
    Next pf
PTable.ManualUpdate = False

'Format Pivot
TableActiveSheet.PivotTables("PayrollPivotTable").ShowTableStyleRowStripes = TrueActiveSheet.PivotTables("PayrollPivotTable").TableStyle2 = "PivotStyleMedium9"
Worksheets("Table").Activate
End Sub

Sub PTtranspose()
Worksheets("Table").Range("A2:I34").ClearContents

Dim i As Integer
For i = 1 To 9
    Worksheets("PivotTable").Range("B" & i + 2, "AH" & i + 2).copy
'Worksheets("PivotTable").Range("B3:AH3").copy
    Worksheets("Table").Cells(2, i).PasteSpecial xlPasteValues, Transpose:=True
Next i

'Worksheets("PivotTable").Range("B4:AH4").copy
'Worksheets("Table").Range("B2").PasteSpecial xlPasteValues, Transpose:=True

'Worksheets("PivotTable").Range("B5:AH5").copy
'Worksheets("Table").Range("C2").PasteSpecial xlPasteValues, Transpose:=True

'Worksheets("PivotTable").Range("B6:AH6").copy
'Worksheets("Table").Range("D2").PasteSpecial xlPasteValues, Transpose:=True

'Worksheets("PivotTable").Range("B7:AH7").copy
'Worksheets("Table").Range("E2").PasteSpecial xlPasteValues, Transpose:=True

'Worksheets("PivotTable").Range("B8:AH8").copy
'Worksheets("Table").Range("F2").PasteSpecial xlPasteValues, Transpose:=True

'Worksheets("PivotTable").Range("B9:AH9").copy
'Worksheets("Table").Range("G2").PasteSpecial xlPasteValues, Transpose:=True

'Worksheets("PivotTable").Range("B10:AH10").copy
'Worksheets("Table").Range("H2").PasteSpecial xlPasteValues, Transpose:=True

'Worksheets("PivotTable").Range("B11:AH11").copy
'Worksheets("Table").Range("I2").PasteSpecial xlPasteValues, Transpose:=True

'Worksheets("Table").Range("A1").PasteSpecial.PasteSpecial xlPasteFormats
End Sub

Sub ImportData()


Dim wb2 As Workbook
Dim Sheet As Worksheet
Dim FileToOpen As Variant

Dim Yr As String

Yr = Year(Now)
Application.DisplayAlerts = False
If Sheets(ThisWorkbook.Sheets.Count).Name = "Data" Then
    On Error Resume Next
    Sheets("Data").Delete
End If
Application.DisplayAlerts = True

ChDrive "C:"
ChDir "C:\Users\wlin\Downloads"

FileToOpen = Application.GetOpenFilename _
(Title:="Please choose the Data Export File from your FlashDrive", _
FileFilter:="Report Files *.csv (*.csv),")

If FileToOpen = False Then
    MsgBox "No File Specified.", vbExclamation, "ERROR"
    Exit Sub
Else
    Set wb2 = Workbooks.Open(Filename:=FileToOpen)

    wb2.Worksheets(1).copy After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count)
    
    'save these 2 lines for later use ---bj
    'wb2.SaveAs "C:\Users\wlin\Downloads\PayrollCompleted\" & Yr & "\" & wb2.Name
    'Kill "C:\Users\wlin\Downloads\PayrollCompleted\" & Yr & "\" & wb2.Name
    Set FileToOpen = Nothing
    wb2.Close SaveChanges:=False
    
End If

If Sheets(ThisWorkbook.Sheets.Count).Cells(1, 1) <> "Co" Then
    MsgBox ("Please Check Data Export File!")
Else
    Sheets(ThisWorkbook.Sheets.Count).Name = "Data"
    Sheets("Table").Activate
    MsgBox ("File imported successfully!")
End If


End Sub


Sub ExportDataFluA()

Dim wb1 As Workbook
Dim wb2 As Workbook
Dim Sheet As Worksheet
Dim FileToOpen As Variant

Set wb1 = ActiveWorkbook
ChDrive "M:"
ChDir "M:\OpenELIS\Worksheets"
FileToOpen = Application.GetOpenFilename _
(Title:="Please choose the Exported OE Worksheet File from The OpenELIS/Worksheets Folder", _
FileFilter:="Report Files *.xls (*.xls),")

If FileToOpen = False Then
    MsgBox "No File Specified.", vbExclamation, "ERROR"
    Exit Sub
Else
    Set wb2 = Workbooks.Open(Filename:=FileToOpen)

    'Now, copy results from wb1:
    wb1.Sheets(1).Range("D45", "D" & NumOfwells * 4 + 35 - 4).copy

    'Now, paste to y worksheet:
    wb2.Sheets("Worksheet").Range("J2").PasteSpecial

    'Now, copy results from wb1:
    wb1.Sheets(1).Range("D49").copy

    'Now, paste to y worksheet:
    wb2.Sheets("Worksheet").Range("J5").PasteSpecial

    
    'Now, copy ct results from wb1:
    wb1.Sheets(1).Range("D53", "D" & NumOfwells * 4 + 44).copy

    'Now, paste to y worksheet:
    wb2.Sheets("Worksheet").Range("J6").PasteSpecial
    
    'Close wb2:
    wb2.Close
    Set FileToOpen = Nothing
    Sheets(1).Activate
    
End If


End Sub

