@echo off
chcp 65001 >nul
echo ====================================
echo   后端配置检查和修复工具
echo ====================================
echo.

:: 检查 application.yml 是否存在
cd /d "%~dp0lab-items-backend\src\main\resources"

if not exist "application.yml" (
    echo ❌ 配置文件不存在
    pause
    exit /b 1
)

echo ✅ 找到配置文件 application.yml
echo.

:: 显示当前数据库配置
echo 当前数据库配置:
findstr /C:"url:" application.yml
findstr /C:"username:" application.yml
findstr /C:"password:" application.yml
echo.

:: 提示用户修改密码
echo ====================================
echo   请修改数据库密码
echo ====================================
echo.
echo 1. 用记事本打开 application.yml
echo 2. 找到 spring.datasource.password
echo 3. 将密码改为你的 MySQL root 密码
echo 4. 保存文件
echo.
pause

:: 启动记事本
notepad application.yml

echo.
echo ====================================
echo   现在启动后端服务...
echo ====================================
echo.

cd /d "%~dp0lab-items-backend"

echo 清理旧的编译...
call mvn clean -q

echo 编译项目...
call mvn compile -q
if %errorlevel% neq 0 (
    echo ❌ 编译失败
    pause
    exit /b 1
)
echo ✅ 编译成功
echo.

echo 启动后端服务...
echo 提示：服务启动后会打开新窗口，请在新窗口查看日志
echo.
timeout /t 3 /nobreak >nul

start "后端服务" cmd /k "cd /d %~dp0lab-items-backend && call mvn spring-boot:run"

echo.
echo ====================================
echo   后端服务已启动
echo ====================================
echo.
echo 请等待 30 秒让服务完全启动...
echo 启动后请访问：http://localhost:8080/api/swagger-ui.html
echo.
echo 按任意键继续...
pause >nul

echo.
echo 正在打开 Swagger UI...
start http://localhost:8080/api/swagger-ui.html

echo.
echo 如果页面无法访问，请检查：
echo 1. 后端服务窗口是否有错误信息
echo 2. 数据库密码是否正确
echo 3. MySQL 服务是否启动
pause
