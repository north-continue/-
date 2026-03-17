# 快速启动指南

## 🚀 5 分钟快速运行项目

### 前置条件检查

确保您的计算机已安装以下软件：

- ✅ **JDK 17+** - [下载链接](https://adoptium.net/temurin/releases/)
- ✅ **Maven 3.8+** - [下载链接](https://maven.apache.org/download.cgi)
- ✅ **MySQL 8.0+** - [下载链接](https://dev.mysql.com/downloads/mysql/)
- ✅ **Redis 6.0+** - [下载链接](https://redis.io/download)
- ✅ **Node.js 18+** - [下载链接](https://nodejs.org/)

### 步骤 1️⃣：初始化数据库（2 分钟）

```bash
# 1. 启动 MySQL 服务
# Windows:
net start mysql

# Linux/Mac:
sudo systemctl start mysql

# 2. 登录 MySQL
mysql -u root -p

# 3. 执行初始化脚本
source /path/to/database_init.sql

# 4. 验证
USE lab_items_management;
SHOW TABLES;
```

### 步骤 2️⃣：配置 Redis（1 分钟）

```bash
# 1. 启动 Redis
# Windows (如果安装为服务):
net start redis

# Linux/Mac:
redis-server

# 2. 测试连接
redis-cli ping
# 应返回：PONG
```

### 步骤 3️⃣：启动后端服务（1 分钟）

```bash
# 1. 进入后端目录
cd lab-items-backend

# 2. 修改配置文件（如果需要）
# 编辑 src/main/resources/application.yml
# 修改数据库连接信息：
#   spring.datasource.username=root
#   spring.datasource.password=your_password

# 3. Maven 构建并启动
mvn clean install
mvn spring-boot:run

# 等待看到以下输出表示启动成功：
# ====================================
# 实验室物品管理平台启动成功！
# API 文档：http://localhost:8080/api/swagger-ui.html
# ====================================
```

### 步骤 4️⃣：启动前端服务（1 分钟）

打开**新的终端窗口**：

```bash
# 1. 进入前端目录
cd lab-items-frontend

# 2. 安装依赖（首次运行需要）
npm install

# 3. 启动开发服务器
npm run dev

# 等待看到以下输出表示启动成功：
# ➜  Local:   http://localhost:3000/
# ➜  Network: use --host to expose
```

### 步骤 5️⃣：访问系统

打开浏览器访问：

- 🌐 **前端界面**: http://localhost:3000
- 📖 **API 文档**: http://localhost:8080/api/swagger-ui.html

**默认登录账号：**

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 系统管理员 | admin | 123456 |
| 实验室管理员 | labadmin | 123456 |
| 教师 | teacher1 | 123456 |
| 学生 | student1 | 123456 |

---

## ⚡ 一键启动（Windows 用户）

双击运行项目根目录下的 `start.bat` 文件：

```bash
start.bat
```

该脚本会自动：
1. 检查环境（Java、Node.js、MySQL、Redis）
2. 启动后端服务
3. 启动前端服务
4. 显示访问地址

---

## 🔍 故障排查

### 问题 1：后端启动失败 - 端口被占用

**错误信息：**
```
Port 8080 was already in use
```

**解决方案：**
```bash
# Windows - 查找并结束占用端口的进程
netstat -ano | findstr :8080
taskkill /F /PID <进程 ID>

# Linux/Mac
lsof -i :8080
kill -9 <进程 ID>
```

或者修改端口：
```yaml
# application.yml
server:
  port: 8081  # 改为其他端口
```

### 问题 2：数据库连接失败

**错误信息：**
```
Could not open JDBC Connection for transaction
```

**解决方案：**
1. 确认 MySQL 服务已启动
2. 检查数据库连接配置
3. 确认数据库已创建：
```sql
SHOW DATABASES;
-- 应该能看到 lab_items_management
```

### 问题 3：Redis 连接失败

**错误信息：**
```
Cannot get Jedis connection
```

**解决方案：**
```bash
# 检查 Redis 是否运行
redis-cli ping
# 如果不通，启动 Redis
redis-server
```

### 问题 4：前端无法访问后端

**错误信息：**
```
Network Error / CORS policy
```

**解决方案：**
1. 确认后端服务已启动
2. 检查 Vite 代理配置（vite.config.ts）
3. 清除浏览器缓存

### 问题 5：npm install 失败

**错误信息：**
```
npm ERR! network timeout
```

**解决方案：**
```bash
# 切换淘宝镜像
npm config set registry https://registry.npmmirror.com

# 重新安装
rm -rf node_modules package-lock.json
npm install
```

---

## 📱 移动端访问

系统支持移动端访问，在同一局域网内：

1. 查看本机 IP 地址：
   ```bash
   # Windows
   ipconfig
   
   # Linux/Mac
   ifconfig
   ```

2. 在手机浏览器访问：
   ```
   http://<你的IP地址>:3000
   ```

---

## 🎯 下一步

启动成功后，您可以：

1. ✅ **登录系统** - 使用默认账号登录
2. ✅ **浏览界面** - 查看工作台、物品管理等页面
3. ✅ **测试功能** - 尝试添加物品、分类等操作
4. ✅ **查看 API** - 访问 Swagger UI 测试接口
5. ✅ **开始开发** - 根据需求扩展功能

---

## 📞 需要帮助？

如果遇到问题：

1. 查看控制台日志
2. 检查 [README.md](./README.md)
3. 查阅 [DEPLOY.md](./DEPLOY.md)
4. 提交 Issue

---

**祝您使用愉快！** 🎉
