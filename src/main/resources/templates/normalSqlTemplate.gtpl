/**
 * Groovy Template for SQL Script Generation
 * This template will be processed by GStringTemplateEngine
 */


set newpage 0;
set space 0;
set linesize 500;
set pagesize 0;
set echo off;
set verify off;
set heading off;
set feedback off;


define serial_num = '${serialNum}'; -- ex: 1,2,3 or 01,02,03
define file_path = '${filePath}'; -- ex: '/stsdat/FDC/dat/ibe/'
define case_num = '${caseNum}'; -- ex: 114-IBE-00004-00012
define file_name = '${fileName}'; -- 報表名稱
define user_name = '${userName}';  -- 使用者帳號
define sql_file = '${sqlFileName}'; -- SQL檔案名稱
define output_file = '&file_path.&case_num.&serial_num.';

-- 有可能會要重複執行，先刪除可能存在的舊資料，參考CQ單編號編配case_num
-- 組合規則{年度}-{系統別}-CQ單尾碼
delete from ap_tax.jutt012 where case_num = '&case_num.' and serial_num = '&serial_num.';
commit;

--新增本次案件明細資料
insert into ap_tax.jutt012 values ( '&case_num.' , '&serial_num.', '&file_name.' , '&user_name.' ,'處理中', null, '&file_path.' , '&sql_file.' );
commit;

--指定輸出的絕對路徑，輸出SQL查詢結果
SPOOL &output_file..csv



/*
 * ↓↓↓ 請將 SQL 查詢語句插入下方區塊 ↓↓↓
 */
------------------------SQL開始------------------------

${appendSql}

------------------------SQL結束------------------------
/*
 * ↑↑↑ 請將 SQL 查詢語句插入上方區塊 ↑↑↑
 */



--產檔結束，關閉檔案
SPOOL OFF
--更新案件狀態為可下載
Update ap_tax.jutt012 set file_status='可下載' where case_num = '&case_num.' and serial_num = '&serial_num.';
commit;