[Console]::OutputEncoding = [text.encoding]::UTF8
[Console]::InputEncoding = [text.encoding]::UTF8

# 設定 Java 執行參數與檔案路徑
$jarPath = ".\sql_generate.jar"
$jsonInput = "C:/紀錄文件/資料分析人員/包版資料/20250602/SQL/inputFile.json"

# 使用 JSON 陣列方式執行
Start-Process -NoNewWindow -FilePath "java" -ArgumentList "-Dfile.encoding=UTF-8", "-jar", $jarPath, "--inputFile=`"$jsonInput`""

# 或使用傳統參數方式（取消註解以下區塊以使用）
<#
$serialNum = "01"
$filePath = "/stsdat/FDC/dat/ibe/"
$caseNum = "114-IBE-00005-00014"
$fileName = "調整統計表"
$userName = "N210661"
$sqlFileName = "qry_ibe_1.sql"
$sqlFilePath = "C:\紀錄文件\資料分析人員\包版資料\20250602\SQL"

Start-Process -NoNewWindow -FilePath "java" -ArgumentList `
??? "-Dfile.encoding=UTF-8", `
??? "-jar", $jarPath, `
??? "--serialNum=$serialNum", `
??? "--filePath=$filePath", `
??? "--caseNum=$caseNum", `
??? "--fileName=$fileName", `
??? "--userName=$userName", `
??? "--sqlFileName=$sqlFileName", `
??? "--sqlFilePath=`"$sqlFilePath`""
#>


$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


# 備註說明（僅供參考）
# serialNum: "4"
# filePath: 執行輸出路徑
# caseNum: CQ單串接碼 年度-系統別-流水編碼 ex:114-IBE-00004-00012
# fileName: 檔案顯示名稱 限制50Bytes varchar ex:表2-19. 綜所稅結算申報分居件數
# userName: 財稅內網帳號 ex:N107719
# sqlFileName: 要執行的SQL名稱 ex:ibe_qry_separate_1.sql
# inputSqlFile: 轉換資料輸入路徑
# outputSqlFile: 轉換資料輸出路徑
