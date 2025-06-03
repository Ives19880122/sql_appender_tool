# SQL Generate Tool

## 專案簡介
SQL Generate Tool 是一個用於添加 SQL 檔案的標頭與尾部的工具，基於 Java 和 Spring Boot 開發。此工具支援自訂 JRE 並包含多種執行方式。

## 功能
- 添加 SQL 檔案的標頭與尾部。
- 支援 JSON 格式的輸入檔案。
- 使用 Maven 打包工具與自訂 JRE。
- 提供批次檔案與 PowerShell 腳本執行。

## 快速開始

### 1. 環境需求
- **Java 21** 或以上版本。
- **Maven** 3.8 或以上版本。

### 2. 建置專案
執行以下指令以建置專案：
```bash
mvn clean package
```

### 3. 執行工具
- 修改powershell腳本 `run.ps1`
  批量轉換: 將 `$jsonInput` 變數設置為 JSON 檔案的完整路徑。
  單筆轉換: 根據需求修改腳本中的傳統參數（如 `$serialNum`、`$filePath` 等）。
- windows下執行 `run.bat` 腳本