@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ====================================
echo   后端问题诊断和修复工具
echo ====================================
echo.

cd /d "%~dp0lab-items-backend"

:: ==================== 步骤 1：检查 Java 版本 ====================
echo [1/6] 检查 Java 版本...
java -version > temp_java.txt 2>&1
findstr /C:"version" temp_java.txt
for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do set JAVA_VER=%%i
echo.

:: 检查是否为 Java 17
echo !JAVA_VER! | findstr /C:"17" >nul
if errorlevel 1 (
    echo ⚠️  警告：检测到 Java 版本不是 17
    echo    项目需要 Java 17，当前版本：!JAVA_VER!
    echo.
) else (
    echo ✅ Java 版本正确：!JAVA_VER!
)
del temp_java.txt
echo.

:: ==================== 步骤 2：清理 Maven 缓存 ====================
echo [2/6] 清理 Maven 缓存和旧编译...
call mvn clean -q
if errorlevel 1 (
    echo ⚠️  Maven clean 失败，继续执行...
) else (
    echo ✅ 清理完成
)
echo.

:: ==================== 步骤 3：检查配置文件 ====================
echo [3/6] 检查配置文件...
if not exist "src\main\resources\application.yml" (
    echo ❌ 配置文件不存在！
    pause
    exit /b 1
)

echo ✅ 配置文件存在
echo.

:: 显示数据库配置
echo 当前数据库配置:
findstr /C:"url:" src\main\resources\application.yml
findstr /C:"username:" src\main\resources\application.yml
findstr /C:"password:" src\main\resources\application.yml
echo.

:: ==================== 步骤 4：测试数据库连接 ====================
echo [4/6] 测试数据库连接...
set /p MYSQL_PWD="请输入 MySQL root 密码："
echo.

mysql -u root -p%MYSQL_PWD% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo ❌ MySQL 连接失败！
    echo    请检查：
    echo    1. MySQL 服务是否启动
    echo    2. 密码是否正确
    echo    3. 数据库是否存在
    pause
    exit /b 1
)

echo ✅ MySQL 连接成功
echo.

:: 检查数据库
mysql -u root -p%MYSQL_PWD% -e "USE lab_items_management;" >nul 2>&1
if errorlevel 1 (
    echo ⚠️  数据库 lab_items_management 不存在
    echo    正在创建数据库...
    mysql -u root -p%MYSQL_PWD% < ../database_simple.sql
    if errorlevel 1 (
        echo ❌ 数据库创建失败
        pause
        exit /b 1
    )
    echo ✅ 数据库创建成功
) else (
    echo ✅ 数据库存在
)
echo.

:: ==================== 步骤 5：编译项目 ====================
echo [5/6] 编译项目...
echo 这可能需要几分钟，请耐心等待...
echo.

call mvn clean compile -X > compile_log.txt 2>&1
if errorlevel 1 (
    echo ❌ 编译失败！
    echo.
    echo 查看错误日志 (最后 50 行):
    echo ====================================
    powershell -Command "Get-Content compile_log.txt -Tail 50"
    echo ====================================
    echo.
    echo 完整日志已保存到：compile_log.txt
    pause
    exit /b 1
)

echo ✅ 编译成功！
del compile_log.txt
echo.

:: ==================== 步骤 6：启动服务 ====================
echo [6/6] 启动后端服务...
echo.
echo 提示：服务将在后台启动，请在新窗口查看启动日志
echo.
timeout /t 3 /nobreak >nul

start "后端服务" cmd /k "cd /d %~dp0lab-items-backend && call mvn spring-boot:run"

echo.
echo ====================================
echo   后端服务已启动
echo ====================================
echo.
echo 请等待 30 秒让服务完全启动
echo 启动后请访问：http://localhost:8080/api/swagger-ui.html
echo.
echo 按任意键打开浏览器测试...
pause >nul

start http://localhost:8080/api/swagger-ui.html

echo.
echo ====================================
echo   故障排查提示
echo ====================================
echo.
echo 如果服务启动失败，请检查：
echo 1. 后端服务窗口的错误信息
echo 2. MySQL 服务是否正常运行
echo 3. 端口 8080 是否被占用
echo 4. application.yml 中的密码是否正确
echo.
echo 常见错误解决：
echo - 端口占用：netstat -ano ^| findstr :8080 然后 taskkill /F /PID ^<进程 ID^>
echo - 密码错误：修改 application.yml 中的 password
echo - 数据库不存在：执行 database_simple.sql
echo.
pause
