#!/usr/bin/env php
#
<?php
$scriptConfig = [
    'filePath'=>'/www/backup/database',
];
if (empty($scriptConfig['filePath'])) {
    exit("请配置备份文件的路径!");
}
// compressFile();
sendBackupFileToEmail();
exit();


function sendBackupFileToEmail()
{
    $message = "Line 1\r\nLine 2\r\nLine 3";
    $headers = 'From: suhanyujie@126.com' . "\r\n" .
        'Reply-To: suhanyujie@126.com' . "\r\n" .
        'X-Mailer: PHP/' . phpversion();

    $isOk = mail("suhanyujie@126.com","My Subject", $message, $headers);
    var_dump($isOk);
}

function achieveBackupFile()
{
    global $scriptConfig;
    $filePath = $scriptConfig['filePath'];
    foreach (new DirectoryIterator($filePath) as $fileInfo) {
        if($fileInfo->isDot()) continue;
        // 只有文件才会备份
        if ($fileInfo->isFile()) {
            // 只备份符合文件名的文件
            $pattern = "@[a-zA-Z]_[a-zA-Z]@";
        }
        echo $fileInfo->getFilename() . "<br>\n";
    }

}

function compressFile()
{
    global $scriptConfig;
    $filePath = $scriptConfig['filePath'];
    $gzFileName = "/tmp/backup_".date("YmdHis").".zip";
    $cmd = "zip {$gzFileName} -R {$filePath}";
    exec($cmd);
}







