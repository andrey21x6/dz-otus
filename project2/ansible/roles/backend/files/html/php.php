<?php

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
			//$sms = "Отправлено в базу!";
			$text_header_in = "";
			$text_out_in = "";
		}
	}

	if (isset($_GET["clear"]))
	{
		$sql = $db->exec("TRUNCATE `text_entries`");
		if (is_integer($sql))
		{
			//$sms = "Таблица очищена!";
		}
	}

?>