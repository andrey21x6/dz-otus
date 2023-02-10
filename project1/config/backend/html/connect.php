<?php

	define("CONNECT_BD", "mysql:host=192.168.90.15; dbname=project1");
	define("LOGIN_BD", "root");
	define("PASS_BD", "123456");

	try
	{
		$db = new PDO(CONNECT_BD, LOGIN_BD, PASS_BD, array( PDO:: MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8'));
	}
	catch(PDOException $e)
	{
		echo $e->getMessage();
		exit ("<h1 style='color:red'>ERR_000</h1>");
	}
	
?>