<?php

	session_start();
	
	if (!isset($_SESSION['ipDb']) || $_SESSION['ipDb'] == "")
	{
		$ipDbStart = "192.168.90.15";
	}
	else
	{
		$ipDbStart = $_SESSION['ipDb'];
	}

	$CONNECT_BD = "mysql:host={$ipDbStart}; dbname=project1";
	define("LOGIN_BD", "root");
	define("PASS_BD", "123456");

	try
	{
		$db = new PDO($CONNECT_BD, LOGIN_BD, PASS_BD, array( PDO:: MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8'));
	}
	catch(PDOException $e)
	{
		//echo $e->getMessage();
		//exit ("<h1 style='color:red'>ERR_000</h1>");
		
		if (isset($_SESSION['ipDb']) && $_SESSION['ipDb'] == "192.168.90.15")
		{
			$_SESSION['ipDb'] = "192.168.90.16";
		}
		elseif (isset($_SESSION['ipDb']) && $_SESSION['ipDb'] == "192.168.90.16")
		{
			$_SESSION['ipDb'] = "192.168.90.15";
		}
		else
		{
			$_SESSION['ipDb'] = "192.168.90.16";
		}

		$ipDbStart = $_SESSION['ipDb'];
		$CONNECT_BD = "mysql:host={$ipDbStart}; dbname=project1";
		
		try
		{
			$db = new PDO($CONNECT_BD, LOGIN_BD, PASS_BD, array( PDO:: MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8'));
		}
		catch(PDOException $e)
		{
			echo $e->getMessage();
			exit ("<h1 style='color:red'>ERR_000</h1>");
		}
	}
	
?>