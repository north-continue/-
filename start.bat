@echo off
chcp 65001 >nul
echo ====================================
echo   实验室物品管理平台 - 启动脚本
echo ====================================
echo.

:: 检查 Java 环境
echo [1/4] 检查 Java 环境...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未检测到 Java 环境，请先安装 JDK 17+
    pause
    exit /b 1
)
echo ✅ Java 环境检查通过

:: 检查 Node.js 环境
echo [2/4] 检查 Node.js 环境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未检测到 Node.js 环境，请先安装 Node.js 18+
    pause
    exit /b 1
)
echo ✅ Node.js 环境检查通过

:: 检查 MySQL 环境
echo [3/4] 检查 MySQL 环境...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  未检测到 MySQL 命令行工具，请确保 MySQL 已启动
) else (
    echo ✅ MySQL 环境检查通过
)

:: 检查 Redis 环境
echo [4/4] 检查 Redis 环境...
redis-cli ping >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Redis 未启动或无法连接，请确保 Redis 服务运行正常
) else (
    echo ✅ Redis 环境检查通过
)

echo.
echo ====================================
echo   开始启动服务...
echo ====================================
echo.

:: 启动后端
echo [后台] 启动后端服务...
cd /d "%~dp0lab-items-backend"
start "后端服务" cmd /k "mvn spring-boot:run"
timeout /t 3 /nobreak >nul

:: 启动前端
echo [后台] 启动前端服务...
cd /d "%~dp0lab-items-frontend"
start "前端服务" cmd /k "npm run dev"

echo.
echo ====================================
echo   服务启动中...
echo ====================================
echo.
echo 📱 前端地址：http://localhost:3000
echo 🔧 后端地址：http://localhost:8080/api
echo 📖 API 文档：http://localhost:8080/api/swagger-ui.html
echo.
echo 默认账号：
echo   管理员：admin / 123456
echo   实验室管理员：labadmin / 123456
echo.
echo 按任意键查看进程状态...
pause >nul

tasklist | findstr "java"
tasklist | findstr "node"

echo.
echo ✅ 所有服务已启动！
echo 请手动关闭此窗口不会停止服务
pause
