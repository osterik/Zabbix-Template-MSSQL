# Скрипт для авто-обнаружения баз данных MSSQL для мониторинга в Zabbix
# основан на скрипте Антона Голубкина из "Template MS SQL 2012" 
# https://share.zabbix.com/databases/microsoft-sql-server/template-ms-sql-2012
# Script to auto-discover MSSQL databases for Zabbix monitoring
# based on Anton Golubkin script from "Template MS SQL 2012" at 
# https://share.zabbix.com/databases/microsoft-sql-server/template-ms-sql-2012

#Задаем переменные для подключение к MSSQL. 
#We define the variables for connecting to MSSQL.
$SQLServer = "localhost"
#Создаем подключение к MSSQL ...
#Create a connection to MSSQL ...
#...используем "Проверку подлинности SQL Server", надо указать логин и пароль
#...use "SQL Server Authentication", we need to specify the username and password
#$connectionString = "Server = $SQLServer; User ID = sa; Password = P@ssWord;"

#...или "Проверку подлинности Windows"
#...or "Windows Authentication"
$connectionString = "Server = $SQLServer; Integrated Security = True;"

#Пропускать указанные базы данных
#Ignore specified databases
$DB_to_skip =  "master", "tempdb", "model", "msdb"

#==============================================================================
#Обычно нет необходимости редактировать код ниже этой линии
#There is usually no need to edit the code below this line

#функция для приведения к формату который понимает zabbix 
#the function is to bring to the format understands zabbix
function convertto-encoding ([string]$from, [string]$to){
	begin{
		$encfrom = [system.text.encoding]::getencoding($from)
		$encto = [system.text.encoding]::getencoding($to)
	}
	process{
		$bytes = $encto.getbytes($_)
		$bytes = [system.text.encoding]::convert($encfrom, $encto, $bytes)
		$encto.getstring($bytes)
	}
}
 
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

#Создаем запрос непосредственно к MSSQL
#Create a request directly to MSSQL
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand  
$SqlCmd.CommandText = "SELECT name FROM  sysdatabases"
$SqlCmd.Connection = $Connection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) > $null
$Connection.Close()

#Получили список баз. Записываем в переменную.
#We get a list of databases. Write to the variable.
$basename = $DataSet.Tables[0]

#Передаём дальше только те названия баз, которые не указаны в списке $DB_to_skip
#Pass on only the names of databases, which are not specified in the list $DB_to_skip
$dbsToZabbix = @() #empty array
foreach ($name in $basename)
{
    if (-not ($DB_to_skip -contains $name.name))
        {
        $dbsToZabbix += $name.name
        }
}

#Парсим и передаем список баз в zabbix. В последней строке нужно вывести имя бызы без запятой в конце. 
#Parse and pass a list of databases in zabbix. In the last line need to display the database name without a comma at the end.
$idx = 1
$sComma = ","
write-host "{"
write-host " `"data`":[`n"
foreach ($dbToZabbix in $dbsToZabbix)
{
    if ($idx -eq $dbsToZabbix.Count) #это последняя стройка / this is the last line
        {
        $sComma = ""
        }
    $line= "{ `"{#DBNAME}`" : `"" + $dbToZabbix + "`" }" + $sComma | convertto-encoding "cp866" "utf-8"
    write-host $line
    $idx++;
}

write-host
write-host " ]"
write-host "}"
