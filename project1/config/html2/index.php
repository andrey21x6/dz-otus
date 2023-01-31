<?php
	ini_set('error_reporting', E_ALL);
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    header("Content-Type: text/html; utf-8");

//----------------------- Подключение к БД --------------------------

	require_once ("connect.php");
	
//---------------------------- PHP ----------------------------------

	require_once ("php.php");

//---------------------------- HTML ---------------------------------

	require_once ("html.php");

?>