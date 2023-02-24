<?php
	//-------------------------------------------- Переменные --------------------------------------------
	
	$ipDb1 = "192.168.90.16";
	$ipDb2 = "192.168.90.15";

	//-------------------------------------------- Старт сессии --------------------------------------------

	session_start();
	
	if (isset($_SESSION['switchDb']))
	{
		$switchDb = $_SESSION['switchDb'];
	}
	else
	{
		$switchDb = $ipDb1;
	}

	//-------------------------------------------- Проверка доступности БД --------------------------------------------

	function _testHostDbPort_($domain){

		$starttime = microtime(true);
		$file      = @fsockopen($domain, 3306, $errno, $errstr, 0.2);   // 3306 - порт подключения ||| 0.2 - TimeOut подключения
		$stoptime  = microtime(true);
		$status    = 0;

		if (!$file) 
		{ 
			$status = -1;  // Не доступна!
		} 
		else 
		{
			fclose($file);
			$status = ($stoptime - $starttime) * 1000;
			$status = floor($status);
		}
		
		return $status;
	}

	//-------------------------------------------- Работа с переменными сессии --------------------------------------------

	if (_testHostDbPort_($switchDb) == -1)
	{
		if ($switchDb == $ipDb1)
		{
			$_SESSION['switchDb'] = $ipDb2;
		}
		elseif ($switchDb == $ipDb2)
		{
			$_SESSION['switchDb'] = $ipDb1;
		}
	}
	else
	{
		if (!isset($_SESSION['switchDb']) || $_SESSION['switchDb'] == "")
		{
			$_SESSION['switchDb'] = $ipDb1;
		}
		elseif (isset($_SESSION['switchDb']) && $_SESSION['switchDb'] == $ipDb1)
		{
			$switchDb = $ipDb2;
			
			if (_testHostDbPort_($switchDb) != -1)
			{
				$_SESSION['switchDb'] = $ipDb2;
			}
		}
		elseif (isset($_SESSION['switchDb']) && $_SESSION['switchDb'] == $ipDb2)
		{
			$switchDb = $ipDb1;
			
			if (_testHostDbPort_($switchDb) != -1)
			{
				$_SESSION['switchDb'] = $ipDb1;
			}
		}
	}
	
	if (isset($_SESSION['switchDb']))
	{
		$switchDb = $_SESSION['switchDb'];
	}
	
	//-------------------------------------------- Подключение к БД --------------------------------------------

	define("CONNECT_BD", "mysql:host={$switchDb}; dbname=project1");
	define("LOGIN_BD", "root");
	define("PASS_BD", "123456");
	
	// PDO:: ATTR_TIMEOUT => 2 - это атрибут TIMEOUT соединения с БД

	try
	{
		$db = new PDO(CONNECT_BD, LOGIN_BD, PASS_BD, array(PDO:: MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8', PDO:: ATTR_TIMEOUT => 2));
	}
	catch(PDOException $e)
	{
		echo $e->getMessage();
        exit ("<h1 style='color:red'>ERR_000</h1>");
	}
?>