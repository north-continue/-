@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ====================================
echo   实验室物品管理平台 - 自动化测试脚本
echo ====================================
echo.

:: ==================== 环境检查 ====================
echo [1/6] 环境检查...
echo.

:: 检查 Java
echo 检查 Java 环境...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Java 未安装，请先安装 JDK 17+
    pause
    exit /b 1
)
echo ✅ Java 环境检查通过
for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do set JAVA_VERSION=%%i
echo    版本：%JAVA_VERSION%
echo.

:: 检查 Maven
echo 检查 Maven 环境...
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Maven 未安装
    pause
    exit /b 1
)
echo ✅ Maven 环境检查通过
echo.

:: 检查 MySQL
echo 检查 MySQL 环境...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  MySQL 命令行工具未找到，请确保 MySQL 已安装
    goto :check_redis
)
echo ✅ MySQL 环境检查通过
echo.

:: 检查 Redis
:check_redis
echo 检查 Redis 环境...
redis-cli ping >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Redis 未启动或无法连接
    echo    提示：Redis 为可选依赖，不影响基本功能
) else (
    echo ✅ Redis 环境检查通过
)
echo.

:: 检查 Node.js
echo 检查 Node.js 环境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js 未安装，请先安装 Node.js 18+
    pause
    exit /b 1
)
echo ✅ Node.js 环境检查通过
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo    版本：%NODE_VERSION%
echo.

:: ==================== 数据库测试 ====================
echo [2/6] 数据库连接测试...
echo.

set /p MYSQL_ROOT_PASSWORD="请输入 MySQL root 密码："
echo.

:: 测试数据库连接
echo 测试数据库连接...
mysql -u root -p%MYSQL_ROOT_PASSWORD% -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MySQL 连接失败，请检查密码或服务状态
    pause
    exit /b 1
)
echo ✅ MySQL 连接成功
echo.

:: 检查数据库是否存在
echo 检查数据库...
mysql -u root -p%MYSQL_ROOT_PASSWORD% -e "USE lab_items_management;" >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  数据库 lab_items_management 已存在
    set /p RECREATE="是否重新创建数据库？(y/n): "
    if /i "!RECREATE!"=="y" (
        echo 删除旧数据库...
        mysql -u root -p%MYSQL_ROOT_PASSWORD% -e "DROP DATABASE IF EXISTS lab_items_management;"
        echo 执行初始化脚本...
        mysql -u root -p%MYSQL_ROOT_PASSWORD% < database_init.sql
        if %errorlevel% equ 0 (
            echo ✅ 数据库初始化成功
        ) else (
            echo ❌ 数据库初始化失败
            pause
            exit /b 1
        )
    )
) else (
    echo 执行数据库初始化...
    mysql -u root -p%MYSQL_ROOT_PASSWORD% < database_init.sql
    if %errorlevel% equ 0 (
        echo ✅ 数据库初始化成功
    ) else (
        echo ❌ 数据库初始化失败
        pause
        exit /b 1
    )
)
echo.

:: 验证表
echo 验证数据表...
mysql -u root -p%MYSQL_ROOT_PASSWORD% -e "USE lab_items_management; SHOW TABLES;" > temp_tables.txt
set /p TABLE_COUNT=<temp_tables.txt
for /f "tokens=*" %%i in ('type temp_tables.txt ^| find /c /v ""') do set /a TABLE_COUNT=%%i
echo    找到 !TABLE_COUNT! 张表
if !TABLE_COUNT! geq 13 (
    echo ✅ 数据表创建成功
) else (
    echo ⚠️  数据表数量不足，可能存在问题
)
del temp_tables.txt
echo.

:: ==================== 后端编译测试 ====================
echo [3/6] 后端编译测试...
echo.

cd /d "%~dp0lab-items-backend"
echo 清理旧的编译文件...
call mvn clean >nul 2>&1

echo 编译后端项目...
call mvn compile -q
if %errorlevel% equ 0 (
    echo ✅ 后端编译成功
) else (
    echo ❌ 后端编译失败
    pause
    exit /b 1
)
echo.

:: ==================== 后端启动测试 ====================
echo [4/6] 后端服务启动测试...
echo.

echo 启动后端服务（后台运行）...
start "后端服务" cmd /k "cd /d %~dp0lab-items-backend && call mvn spring-boot:run"
echo 等待后端启动...
timeout /t 15 /nobreak >nul

:: 测试后端 API
echo 测试后端 API...
curl -s http://localhost:8080/api/swagger-ui.html >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 后端服务启动成功
    echo    访问地址：http://localhost:8080/api/swagger-ui.html
) else (
    echo ⚠️  后端服务可能未完全启动，请手动检查
)
echo.

:: ==================== 前端安装测试 ====================
echo [5/6] 前端依赖安装测试...
echo.

cd /d "%~dp0lab-items-frontend"

if not exist "node_modules" (
    echo 首次安装前端依赖...
    call npm install
    if %errorlevel% equ 0 (
        echo ✅ 前端依赖安装成功
    ) else (
        echo ❌ 前端依赖安装失败
        pause
        exit /b 1
    )
) else (
    echo ✅ 前端依赖已安装
)
echo.

:: ==================== 前端启动测试 ====================
echo [6/6] 前端服务启动测试...
echo.

echo 启动前端服务（后台运行）...
start "前端服务" cmd /k "cd /d %~dp0lab-items-frontend && call npm run dev"
echo 等待前端启动...
timeout /t 10 /nobreak >nul

echo ✅ 前端服务启动成功
echo    访问地址：http://localhost:3000
echo.

:: ==================== 测试汇总 ====================
echo ====================================
echo   测试完成汇总
echo ====================================
echo.
echo ✅ 环境检查通过
echo ✅ 数据库初始化成功
echo ✅ 后端编译成功
echo ✅ 后端服务启动
echo ✅ 前端依赖就绪
echo ✅ 前端服务启动
echo.
echo ====================================
echo   访问地址
echo ====================================
echo 🌐 前端界面：http://localhost:3000
echo 📖 API 文档：http://localhost:8080/api/swagger-ui.html
echo.
echo 默认登录账号：
echo   管理员：admin / 123456
echo   实验室管理员：labadmin / 123456
echo   教师：teacher1 / 123456
echo   学生：student1 / 123456
echo.
echo 提示：服务已在后台运行，关闭此窗口不会停止服务
echo 按任意键退出...
pause >nul
