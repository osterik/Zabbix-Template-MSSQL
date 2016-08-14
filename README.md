# Zabbix-Template-MSSQL

Microsoft SQL Server 2012 monitoring. For English and Russian version. With LLD. Сhecked in 2.4.8 and 3.0.0
Based on Anton Golubkin's "Template MS SQL 2012" at 
https://share.zabbix.com/databases/microsoft-sql-server/template-ms-sql-2012


# Changelog
* Добавлена возможность указывать списко баз данных, которых надо пропускать при LLD, параметр $DB_to_skip в SQLBaseName_To_Zabbix.ps1 
* Добавлен {HOST.NAME} к имени триггеров (когда приходит сообщение, понятно, к какому из серверов оно относится)
* Добавлен комплексный экран по мотивам "Top 10 SQL Server Counters for Monitoring SQL Server Performance" (http://www.databasejournal.com/features/mssql/article.php/3932406/Top-10-SQL-Server-Counters-for-Monitoring-SQL-Server-Performance.htm)
* Шаблон для русского MSSQL.
* Исправлен триггер "Access Methods Page Splits / Sec" 

> {MS SQL 2012:perf_counter["\SQLServer:Access Methods\Page Splits/sec",30].last()}>
> {MS SQL 2012:perf_counter["\SQLServer:SQL Statistics\Batch Requests/sec",30].last()}/20

Насколько я могу догадаться, Anton Golubkin ориентировался на фразу "Ideally this counter should be less than 20% of the batch requests per second." Но получилось, что триггер срабатывает, когда PageSplits > 5% Batch Requests. Что случается намного чаще :) Поменял на 20% (т.е. "/5")

# Как сделать шаблон для Express редакции

(или для случая, когда в системе установлено несколько экземпляров MSSQL)

1. Добавить шаблон от обычной версии в Zabbix
2. Переименовать или склонировать шаблон (например, добавив " Express" к названию)
3. Экспортровать только что созданный шаблон "хххх Express" и удалить его
4. Открыть экспортированный .xms в текстовом редакторе и заменить все вхождения "SQLServer:" на "MSSQL$SQLEXPRESS:". Если создаётся шаблон для экземпляра MSSQL с нестандарным именем - указать это имя. Посмотреть его можно при добавлении счётчиков в perfmon.exe
5. Сохранить и импортировать изменённый шаблон. При импорте снять отметки из колонки "Обновить существующее"


# English
* LLD : now you can skip some databases from LLD, check $DB_to_skip in SQLBaseName_To_Zabbix.ps1 
* Add "{HOST.NAME}" to trigger name
* Screen with "Top 10 SQL Server Counters for Monitoring SQL Server Performance" (http://www.databasejournal.com/features/mssql/article.php/3932406/Top-10-SQL-Server-Counters-for-Monitoring-SQL-Server-Performance.htm)
* Template for Russian MSSQL server
* Howto add Express server



