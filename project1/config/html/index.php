<?php
	ini_set('error_reporting', E_ALL);
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    header("Content-Type: text/html; utf-8");

//============================================================================================================================================================================

	define("CONNECT_BD", "mysql:host=192.168.90.14; dbname=project1");
    define("LOGIN_BD", "root");
    define("PASS_BD", "123456");
    
    try
    {
        $db = new PDO(CONNECT_BD, LOGIN_BD, PASS_BD, array( PDO:: MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8'));
    }
    catch(PDOException $e)
    {
        exit ("<h1 style='color:red'>ERR_000</h1>");
    }
	
//=============================================================== PHP ========================================================================================================

$sms = "";
$text_header = "";
$text_out = "";
$text_header_in = "";
$text_out_in = "";

if (isset($_POST["text_header_in"]) && isset($_POST["text_out_in"]))
{
	$text_header_in = $_POST['text_header_in'];
    $text_out_in = $_POST['text_out_in'];

	$result = $db->exec("INSERT INTO text_entries (text_header, text_out) VALUES ('{$text_header_in}','{$text_out_in}')");
	if (!$result) 
	{
		exit (basename(__FILE__, ".php")."_".__LINE__);
	} 
	else 
	{
		$sms = "Отправлено в базу!";
		$text_header_in = "";
		$text_out_in = "";
	}
}

//=============================================================== HTML =======================================================================================================
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="utf-8" />
    <title>Project1</title>
    <meta name="robots" content="noindex, nofollow" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
    <meta http-equiv="Cache-Control" content="no-cache" />
    <meta http-equiv="Cache-Control" content="private" />
    <meta http-equiv="Cache-Control" content="max-age=0, proxy-revalidate" />

	<style>
		.input-submit {
			margin: 10px 0 0px 0;
		}

		.text-header{
			border: 1px solid rgba(200, 200, 200, 0.8);
			background-repeat: no-repeat;   /*Убираем повтор изображения*/   
			background-position: 4px;   /*Позиционируем*/   
			outline: none;   /*убираем стандартную обводку браузера*/   
			-moz-border-radius: 3px;   /*закругляем углы для Mozilla*/  
			-webkit-border-radius: 3px;   /*закругляем углы для Chrome, Safari*/   
			border-radius: 3px;   /*закругляем углы для остальных браузеров*/  
			padding: 5px 5px 5px 5px;   /*отступ слева от ввода, чтобы текст не был на картинке(выбирать по размеру картинки)*/  
			height: 30px;   /*высота строки ввода*/   
			width: 400px;
			font-size: 1.2em;
		}

		.text-header:focus{
			border: 1px solid rgba(100, 100, 100, 0.8);
		}

		textarea {
			border: 1px solid rgba(200, 200, 200, 0.9);
			resize: none;   /* Запрещаем изменять размер */
			width: 400px;
			height: 100px;
			padding: 5px;
			outline: none;
			outline-offset: 0;
			-moz-appearance: none;
			border-radius: 3px;
			font: 16px 'Trebuchet MS', Arial, Calibri, sans-serif, 'Trebuchet MS', Helvetica, 'Comic Sans MS';
			margin-top: 10px;
		}

		textarea:focus {
			border: 1px solid #969696;
		}

		.knopka {
			font-size: 0.8em;
			position: relative;
			color: #fff;
			padding: 12px 12px 12px 12px;
			display: inline-block;
			text-align: center;
			text-decoration: none;
			border-radius: 1px;
			border: none;
			outline: none;
			transition: 0.1s;
			background-color: #3EBE3E;
			cursor: pointer;
		}

		.knopka:hover {
			transition: 0.1s;
			background-color: green;
		}
	</style>
    
</head>
<body>



<?php
$sql = "SELECT * FROM text_entries";
$result = $db->query($sql);
if (!$result)
{
	exit (basename(__FILE__, ".php")."_".__LINE__);
}
else
{
	$array = $result->fetchALL(PDO::FETCH_ASSOC);

	if (empty($array))
	{
		echo "Пусто!";
	}
	else
	{
		foreach ($array as $value)
		{
			$id = $value['id'];
			$text_header = $value['text_header'];
			$text_out = $value['text_out'];

			echo "{$id}: {$text_header} - {$text_out}<br>";
		}
	}
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "
<h1 class='nazv'></h1>
<div class='sms'>{$sms}</div>
<div class='form'>
	<form action='./' autocomplete='off' method='post' enctype='multipart/form-data'>
		<div class='input-submit'><input type='text' name='text_header_in' class='text-header' value='{$text_header_in}' ></div>
		<div class='textarea'><textarea required='required' maxlength='240' name='text_out_in'>{$text_out_in}</textarea></div>
		<div class='input-submit'><input class='knopka' type='submit' name='submit' value='&#10004; ОТПРАВИТЬ' /></div>
	</form>
</div>";
	
?>



</body>
</html>