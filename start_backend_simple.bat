@echo off
chcp 65001 >nul
echo ====================================
echo   后端快速启动脚本
echo ====================================
echo.

cd /d "%~dp0lab-items-backend"

echo 步骤 1: 清理旧的编译文件...
call mvn clean -q
echo ✅ 清理完成
echo.

echo 步骤 2: 编译项目...
echo 正在编译，请稍候...
echo.

call mvn compile
if errorlevel 1 (
    echo.
    echo ❌ 编译失败！
    echo.
    echo ====================================
    echo   可能的原因和解决方案
    echo ====================================
    echo.
    echo 1. Java 版本不匹配
    echo    解决：确保使用 Java 17
    echo    检查：java -version
    echo.
    echo 2. Maven 依赖下载失败
    echo    解决：检查网络连接
    echo    或使用镜像：编辑 pom.xml
    echo.
    echo 3. 代码语法错误
    echo    解决：检查 Java 文件是否有错误
    echo.
    echo 按任意键查看完整错误信息...
    pause >nul
    
    echo.
    echo 正在重新编译并显示详细错误...
    call mvn compile -X
    pause
    exit /b 1
)

echo ✅ 编译成功！
echo.

echo 步骤 3: 启动后端服务...
echo.
echo 提示：服务启动后会打开新窗口
echo 请在新窗口查看启动日志
echo.
timeout /t 2 /nobreak >nul

start "后端服务" cmd /k "cd /d %~dp0lab-items-backend && call mvn spring-boot:run"

echo.
echo ====================================
echo   后端服务启动中...
echo ====================================
echo.
echo 请等待 30 秒，然后访问：
echo http://localhost:8084/api/swagger-ui.html
echo.
echo 按任意键打开浏览器测试...
pause >nul

start http://localhost:8084/api/swagger-ui.html

echo.
echo 如果页面无法访问，请检查后端服务窗口的日志
echo.
pause
