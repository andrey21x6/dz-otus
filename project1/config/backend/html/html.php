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
	<link rel="stylesheet" href="style.css" />
</head>
<body>

	<?php
	
	if ($switchDb == "192.168.90.15")
	{
		echo "<h1 style='color:green'>1 - <span style='color:green'>1</span></h1>";
	}
	else
	{
		echo "<h1 style='color:green'>1 - <span style='color:red'>2</span></h1>";
	}

	//---------------------------------------------- Вывод из таблицы ------------------------------------------------------------

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

				echo "
				<div class='out-div'>
					<h3>{$id}. {$text_header}</h3>
					<p>{$text_out}</p>
				</div>";
			}
		}
	}

	//---------------------------------------------- Форма отправки -------------------------------------------------------------

	echo "
	<h1 class='nazv'></h1>
	<div class='sms'>{$sms}</div>
	<div class='form'>
		<form action='./' autocomplete='off' method='post' enctype='multipart/form-data'>
			<div class='input-submit'><input type='text' name='text_header_in' class='text-header' value='{$text_header_in}' ></div>
			<div class='textarea'><textarea required='required' maxlength='240' name='text_out_in'>{$text_out_in}</textarea></div>
			<div class='input-submit'><input class='knopka' type='submit' name='submit' value='&#10004; ОТПРАВИТЬ' /></div>
		</form>
	</div>
	<div class='input-submit'><a href='./?clear'>Clear table</a></div>";

	?>

</body>
</html>