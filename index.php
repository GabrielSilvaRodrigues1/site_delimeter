<?php
// Executa o comando docker-compose up -d
$output = shell_exec('docker-compose up -d 2>&1');
echo "<pre>$output</pre>";

// Redireciona o usuário para o public/index.php
header('Location: public/index.php');
exit;
?>