<?php
	ini_set('error_reporting', E_ALL);   //Выводит все ошибки
    ini_set('display_errors', 1);   //...
    ini_set('display_startup_errors', 1);   //...
    header("Content-Type: text/html; utf-8");   //utf-8   |||   windows-1251

	echo "<h1>OK</h1>";
	//phpinfo();
	
	
	
	$connection = mysqli_connect('192.168.90.14', 'root', '123456', 'test1');
	if (!$connection) {
		die('Ошибка соединения');
	}
	echo 'Успешно соединились 1';
	
	
	
	//$mysqli = new mysqli('192.168.90.14', 'root', '123456', 'test1');
	//if ($mysqli -> connect_error) {
	  //printf("Соединение не удалось: %s\n", $mysqli -> connect_error);
	  //exit();
	//};
	//echo 'Успешно соединились 2';
	
?>