#!/usr/bin/env php
<?php
/**
 * Created by PhpStorm.
 * User: suhanyu
 * Date: 18/12/26
 * Time: 上午11:26
 */
$configArr = parse_ini_file(dirname(dirname(__FILE__)).'/.env.ini');
//需要打包的项目名
$objName = $configArr['objName'] ?? '';
//本地的配置仓库
$configRegistry = $configArr['configRegistry'] ?? '';
//拉取配置仓库中的最新代码
$objConfDir = "$configRegistry";
exec("cd {$objConfDir};/www/common/someShell/pullOrigin.sh;");
echo "----------------------------------------\n";
echo "更新配置仓库的配置 完成！\n";
if (empty($configRegistry) || empty($objName)) {
    throw new \Exception("请在配置文件中配置configRegistry/objName选项！", 17);
}
//要发布的环境：dev、test、pre、prod
$env = $argv[1] ?? 'dev';
$envEnum = ['dev','test','pre','prod'];
$envEnumStr = implode('、', $envEnum);
if (!in_array($env, $envEnum)) {
    throw new \Exception("请设置要部署的环境：{$envEnumStr}。", 17);
}
//常量的定义
//临时目录
define('TEMP_DIR', '/tmp/tarsScript');
//临时目录中暂存项目的目录名
define('TEMP_TARS_OBJ_DIR_NAME', 'tarsObj');

$tempDir = TEMP_DIR;
$tempTarsObjDirName = TEMP_TARS_OBJ_DIR_NAME;
$tempObjDirName = "{$tempDir}/{$tempTarsObjDirName}";
exec("mkdir -p {$tempObjDirName}");
exec("rm -rf {$tempDir}/*.tar.gz");
$relatePath = "{$env}/conf";
$confPath = "{$configRegistry}/{$objName}/{$relatePath}";
if (!is_dir($confPath)) {
    throw new \Exception("无效的配置文件路径:{$confPath}", 17);
}
checkCurrentDir();
initTempDir();
//获取当前路径
exec("pwd",$res);
$currentDir = $res[0];
//打包到临时目录
$fileName = date('YmdHis')."tar.gz";
exec("rm -rf src/*.tar.gz");
exec("cd src && composer deploy");
exec("ls src/*.tar.gz",$output);
$gzFilePath = $gzFilename = $output[0];
if (empty($gzFilePath)) {
    throw new \Exception("没有找到打包好的文件，请检查！", 49);
}
$gzFilename = pathinfo($gzFilename, PATHINFO_BASENAME);
exec("mv {$gzFilePath} {$tempDir}/");
echo "打包文件名是：{$gzFilename}\n";

$cmd = <<<CMD1
cd {$tempDir};
chmod 755 {$gzFilename};
tar zxf {$gzFilename} -C {$tempObjDirName}/;
CMD1;
$output = [];
exec($cmd,$output);

$output = [];
exec("cd {$tempDir} && ls {$tempObjDirName}/", $output);

if (empty($output[0])) {
    throw new \Exception("当前目录下没有项目文件夹！", 55);
}
$objDir = $output[0];
$output = [];
exec("pwd", $output);
$output = [];
exec("ls -al", $output);
$serverName = getServerName("{$tempDir}/{$tempTarsObjDirName}/{$objDir}");
$configPath = "{$tempObjDirName}/{$serverName}/src/conf/";
if (!is_dir($configPath)) {
    throw new \Exception("打包的项目中配置文件夹无效:{$configPath}！", 49);
}

//移动配置文件夹下的所有配置文件
$dirObj = new FilesystemIterator($confPath);
foreach ($dirObj as $oneFile) {
    if (is_dir($oneFile)) {
        continue;
    }
    $curFile = $oneFile->getPathname();
    $output = [];
    exec("cp $curFile $configPath",$output);
    echo "- 完成配置文件的拷贝:{$curFile}\n";
}

//调整好对应环境的配置文件后，打包文件
exec("mv {$tempDir}/{$gzFilename} {$tempDir}/tmp_{$gzFilename}");
$newTgzFile = $gzFilename;
$tgzFile = "{$tempDir}".DIRECTORY_SEPARATOR.$newTgzFile;
$phar = new \PharData($tgzFile);
$phar->compress(\Phar::GZ);
$phar->buildFromDirectory($tempObjDirName);

//移动到原始的项目目录src下
exec("rm -rf src/*.tar.gz");
exec("mv $tgzFile src/");

//清理目录
clearTempDir();

//结束输出
exit("\033[32m文件夹配置文件调整完毕！\033[0m\n");

/**
 * --------------------------------华丽的分割线：以下是函数定义-------------------------------------------------------------------------
 */

//初始化临时目录
function initTempDir($defaultDir=TEMP_DIR):void
{
    if (!is_dir($defaultDir)) {
        exec("mkdir -p $defaultDir");
    }
}

//清理临时目录下的文件
function clearTempDir():void
{
    $tempDir = TEMP_DIR;
    if (empty($tempDir)) {
        throw new \Exception("临时目录为空！", 48);
    }
    exec("rm -rf {$tempDir}/*");
}

/**
 * 验证当前文件夹是否是tars相关项目的文件夹
 * - 特征1：包含scripts tars src等目录
 */
function checkCurrentDir(): void
{
    exec("pwd",$res);
    $currentDir = $res[0];
    $dirObj = new FilesystemIterator($currentDir);
    $dirEnum = ['scripts','tars','src'];
    $dirArr = [];
    foreach ($dirObj as $file) {
        $curFile = $file->getFilename();
        $dirArr[] = $curFile;
    }
    foreach ($dirEnum as $k=>$dirName) {
        if (!in_array($dirName, $dirArr)) {
            throw new \Exception("当前目录可能不是tars项目目录，缺少文件夹：{$dirName}。", 59);
        }
    }
}

//根据jce.proto.php 获取服务名
function getServerName($tarsPHPRoot='')
{
    $jceProtoFile = $tarsPHPRoot . DIRECTORY_SEPARATOR . 'tars' . DIRECTORY_SEPARATOR . 'tars.proto.php';
    if (!is_file($jceProtoFile)) {
        echo "文件不存在：{$jceProtoFile}\n";
        exit();
    }
    $jceProto         = require_once $jceProtoFile;
    $serverName       = $jceProto['serverName'];

    return $serverName;
}
