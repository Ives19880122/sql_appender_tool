[Console]::OutputEncoding = [text.encoding]::UTF8
[Console]::InputEncoding  = [text.encoding]::UTF8

$jarPath    = "./lib/sql_generate.jar"
$jrePath    = "./jre/bin/java.exe"
$configPath = Join-Path $PSScriptRoot "config.json"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class NativeMethod {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, string lParam);
}
"@

function Set-PlaceholderText($ctrl, $text) {
    [NativeMethod]::SendMessage($ctrl.Handle, 0x1501, [IntPtr]::Zero, $text)
}

# ── 載入設定 ──────────────────────────────────────────
$cfg = @{ filePath = ""; caseNum = ""; userName = ""; rows = @() }
if (Test-Path $configPath) {
    $loaded = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $cfg.filePath = "$($loaded.filePath)"
    $cfg.caseNum  = "$($loaded.caseNum)"
    $cfg.userName = "$($loaded.userName)"
    if ($loaded.rows) { $cfg.rows = $loaded.rows }
}

# ── 建立主表單 ─────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = "SQL 產生器"
$form.StartPosition   = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox     = $false
$form.MinimizeBox     = $false

$lblW = 160
$txtX = 172
$txtW = 420
$y    = 12
$rowH = 32

# 共用欄位
function New-SharedRow($labelText, $value) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = "${labelText}："
    $lbl.Location  = New-Object System.Drawing.Point(8, $script:y)
    $lbl.Size      = New-Object System.Drawing.Size($script:lblW, 22)
    $lbl.TextAlign = "MiddleRight"

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Location  = New-Object System.Drawing.Point($script:txtX, $script:y)
    $txt.Size      = New-Object System.Drawing.Size($script:txtW, 22)
    $txt.Text      = $value

    $form.Controls.AddRange(@($lbl, $txt))
    $script:y += $script:rowH
    return $txt
}

$txtFilePath = New-SharedRow "輸出路徑 (filePath)" $cfg.filePath
$txtCaseNum  = New-SharedRow "案件代碼 (caseNum)"  $cfg.caseNum
$txtUserName = New-SharedRow "帳號 (userName)"     $cfg.userName

# 分隔線
$sep = New-Object System.Windows.Forms.Panel
$sep.Location  = New-Object System.Drawing.Point(8, ($y + 2))
$sep.Size      = New-Object System.Drawing.Size(604, 1)
$sep.BackColor = [System.Drawing.Color]::Silver
$form.Controls.Add($sep)
$y += 12

# ── 工具列 ────────────────────────────────────────────
$btnScan = New-Object System.Windows.Forms.Button
$btnScan.Text     = "掃描資料夾"
$btnScan.Location = New-Object System.Drawing.Point(8, $y)
$btnScan.Size     = New-Object System.Drawing.Size(90, 26)

$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text     = "新增"
$btnAdd.Location = New-Object System.Drawing.Point(104, $y)
$btnAdd.Size     = New-Object System.Drawing.Size(56, 26)

$btnDel = New-Object System.Windows.Forms.Button
$btnDel.Text     = "刪除選取"
$btnDel.Location = New-Object System.Drawing.Point(166, $y)
$btnDel.Size     = New-Object System.Drawing.Size(72, 26)

$form.Controls.AddRange(@($btnScan, $btnAdd, $btnDel))
$y += 34

# ── DataGridView ──────────────────────────────────────
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location              = New-Object System.Drawing.Point(8, $y)
$grid.Size                  = New-Object System.Drawing.Size(604, 220)
$grid.AllowUserToAddRows    = $false
$grid.AllowUserToDeleteRows = $false
$grid.SelectionMode         = "FullRowSelect"
$grid.RowHeadersWidth       = 24
$grid.ColumnHeadersHeightSizeMode = "DisableResizing"
$grid.AutoSizeColumnsMode   = "None"

$colSerial = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colSerial.Name       = "serialNum"
$colSerial.HeaderText = "序號"
$colSerial.Width      = 50

$colDispName = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colDispName.Name       = "fileName"
$colDispName.HeaderText = "顯示名稱"
$colDispName.Width      = 140

$colFile = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colFile.Name       = "sqlFileName"
$colFile.HeaderText = "SQL 檔名"
$colFile.Width      = 160

$colPath = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colPath.Name       = "sqlFilePath"
$colPath.HeaderText = "SQL 資料夾"
$colPath.Width      = 230

$null = $grid.Columns.Add($colSerial)
$null = $grid.Columns.Add($colDispName)
$null = $grid.Columns.Add($colFile)
$null = $grid.Columns.Add($colPath)

foreach ($row in $cfg.rows) {
    $null = $grid.Rows.Add("$($row.serialNum)", "$($row.fileName)", "$($row.sqlFileName)", "$($row.sqlFilePath)")
}

$form.Controls.Add($grid)
$y += 228

# ── 底部按鈕 ──────────────────────────────────────────
$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text         = "取消"
$btnCancel.Location     = New-Object System.Drawing.Point(462, ($y + 8))
$btnCancel.Size         = New-Object System.Drawing.Size(70, 28)
$btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text     = "全部執行"
$btnRun.Location = New-Object System.Drawing.Point(540, ($y + 8))
$btnRun.Size     = New-Object System.Drawing.Size(76, 28)

$form.Controls.AddRange(@($btnCancel, $btnRun))
$form.CancelButton = $btnCancel
$form.ClientSize   = New-Object System.Drawing.Size(624, ($y + 46))

# ── 事件：掃描資料夾 ──────────────────────────────────
$btnScan.Add_Click({
    $fb = New-Object System.Windows.Forms.FolderBrowserDialog
    $fb.Description  = "請選擇 SQL 檔案所在資料夾"
    $fb.SelectedPath = "C:\紀錄文件\資料分析人員\包版資料"
    if ($fb.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { return }

    $folder = $fb.SelectedPath
    $files  = Get-ChildItem -Path $folder -Filter "*.sql" -File |
              Where-Object { $_.DirectoryName -eq $folder } |
              Sort-Object Name

    if ($files.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "未在此資料夾找到 .sql 檔案。", "提示", "OK", "Information")
        return
    }

    $grid.Rows.Clear()
    $i = 1
    foreach ($f in $files) {
        $dispName = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
        $null = $grid.Rows.Add(("{0:D2}" -f $i), $dispName, $f.Name, $folder)
        $i++
    }
})

# ── 事件：新增 ────────────────────────────────────────
$btnAdd.Add_Click({
    $idx    = $grid.Rows.Count
    $serial = "{0:D2}" -f ($idx + 1)
    $null = $grid.Rows.Add($serial, "", "", "")
    $grid.CurrentCell = $grid.Rows[$idx].Cells["fileName"]
    $grid.BeginEdit($true)
})

# ── 事件：刪除選取 ────────────────────────────────────
$btnDel.Add_Click({
    $selected = @($grid.SelectedRows)
    if ($selected.Count -eq 0) { return }
    foreach ($row in $selected) {
        $grid.Rows.Remove($row)
    }
    for ($i = 0; $i -lt $grid.Rows.Count; $i++) {
        $grid.Rows[$i].Cells["serialNum"].Value = "{0:D2}" -f ($i + 1)
    }
})

# ── 事件：全部執行 ────────────────────────────────────
$script:runData = $null

$btnRun.Add_Click({
    foreach ($pair in @(
        @($txtFilePath, "輸出路徑 (filePath)"),
        @($txtCaseNum,  "案件代碼 (caseNum)"),
        @($txtUserName, "帳號 (userName)")
    )) {
        if ([string]::IsNullOrWhiteSpace($pair[0].Text)) {
            [System.Windows.Forms.MessageBox]::Show(
                "請填寫「$($pair[1])」欄位。", "欄位不完整", "OK", "Warning")
            $pair[0].Focus()
            return
        }
    }
    if ($grid.Rows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "SQL 清單為空，請先掃描資料夾或新增項目。", "清單為空", "OK", "Warning")
        return
    }

    $rows = @()
    foreach ($row in $grid.Rows) {
        $rows += @{
            serialNum   = "$($row.Cells['serialNum'].Value)"
            fileName    = "$($row.Cells['fileName'].Value)"
            sqlFileName = "$($row.Cells['sqlFileName'].Value)"
            sqlFilePath = "$($row.Cells['sqlFilePath'].Value)"
        }
    }

    @{
        filePath = $txtFilePath.Text.Trim()
        caseNum  = $txtCaseNum.Text.Trim()
        userName = $txtUserName.Text.Trim()
        rows     = $rows
    } | ConvertTo-Json -Depth 3 | Set-Content $configPath -Encoding UTF8

    $script:runData = @{
        filePath = $txtFilePath.Text.Trim()
        caseNum  = $txtCaseNum.Text.Trim()
        userName = $txtUserName.Text.Trim()
        rows     = $rows
    }

    $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Close()
})

# ── Placeholder ───────────────────────────────────────
$form.Add_Shown({
    Set-PlaceholderText $txtFilePath "ex: /stsdat/FDC/dat/ibe/"
    Set-PlaceholderText $txtCaseNum  "ex: 114-IBE-00004-00012"
    Set-PlaceholderText $txtUserName "ex: N210661"
})

# ── 顯示表單 ──────────────────────────────────────────
if ($form.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "已取消，未執行。"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# ── 建立 input.json 並執行一次 JAR ───────────────────
$filePath = $script:runData.filePath
$caseNum  = $script:runData.caseNum
$userName = $script:runData.userName

$jsonLines = $script:runData.rows | ForEach-Object {
    [PSCustomObject]@{
        serialNum   = $_.serialNum
        filePath    = $filePath
        caseNum     = $caseNum
        fileName    = $_.fileName
        userName    = $userName
        sqlFileName = $_.sqlFileName
        sqlFilePath = $_.sqlFilePath
    } | ConvertTo-Json -Compress
}
$inputJson = Join-Path $PSScriptRoot "input.json"
$jsonContent = "[" + ($jsonLines -join ",") + "]"
[System.IO.File]::WriteAllText($inputJson, $jsonContent, [System.Text.Encoding]::UTF8)

Write-Host "執行 SQL 產生器（共 $($script:runData.rows.Count) 筆）..."

Start-Process -NoNewWindow -Wait -FilePath $jrePath -ArgumentList `
    "-Dfile.encoding=UTF-8", `
    "-jar", $jarPath, `
    "--inputFile=`"$inputJson`""

Remove-Item $inputJson -ErrorAction SilentlyContinue

Write-Host "執行完成，按任意鍵關閉..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
