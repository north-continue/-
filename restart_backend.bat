@echo off
echo ========================================
echo 正在停止占用 8080 端口的进程...
echo ========================================

:: 查找并终止占用 8080 端口的进程
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080') do (
    echo 发现进程 PID: %%a
    taskkill /F /PID %%a
)

echo.
echo ========================================
echo 启动后端服务...
echo ========================================

cd /d %~dp0lab-items-backend
mvn spring-boot:run

pause
