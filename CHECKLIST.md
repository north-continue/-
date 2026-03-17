# 部署检查清单

## 📋 部署前检查

### 环境检查

- [ ] **JDK 17+** 已安装并配置环境变量
  ```bash
  java -version
  echo %JAVA_HOME%  # Windows
  echo $JAVA_HOME   # Linux/Mac
  ```

- [ ] **Maven 3.8+** 已安装
  ```bash
  mvn -version
  ```

- [ ] **MySQL 8.0+** 已安装并运行
  ```bash
  mysql --version
  netstat -an | findstr :3306
  ```

- [ ] **Redis 6.0+** 已安装并运行
  ```bash
  redis-cli ping
  # 应返回：PONG
  ```

- [ ] **Node.js 18+** 已安装
  ```bash
  node --version
  npm --version
  ```

### 数据库检查

- [ ] 执行 `database_init.sql` 脚本
- [ ] 验证数据库已创建
  ```sql
  SHOW DATABASES;
  USE lab_items_management;
  SHOW TABLES;
  ```
- [ ] 验证初始数据已插入
  ```sql
  SELECT * FROM user;
  SELECT * FROM category;
  ```
- [ ] 测试数据库连接
  ```bash
  mysql -u root -p lab_items_management
  ```

### 配置文件检查

#### 后端配置（application.yml）

- [ ] 数据库连接信息
  ```yaml
  spring:
    datasource:
      url: jdbc:mysql://localhost:3306/lab_items_management
      username: root
      password: your_password  # ⚠️ 修改为实际密码
  ```

- [ ] Redis 配置
  ```yaml
  spring:
    redis:
      host: localhost
      port: 6379
      password: ""  # 如果有密码，填写
  ```

- [ ] JWT 密钥（生产环境必须修改）
  ```yaml
  jwt:
    secret: your-production-secret-key-here  # ⚠️ 必须修改
  ```

#### 前端配置

- [ ] 开发环境（.env.development）
  ```
  VITE_BASE_API=/api
  VITE_BASE_API_TARGET=http://localhost:8080
  ```

- [ ] 生产环境（.env.production）
  ```
  VITE_BASE_API=/api
  ```

- [ ] Vite 代理配置（vite.config.ts）
  ```typescript
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
  ```

---

## 🚀 本地开发环境部署

### 步骤 1：启动 MySQL

```bash
# Windows
net start mysql

# Linux
sudo systemctl start mysql

# Mac
brew services start mysql
```

### 步骤 2：启动 Redis

```bash
# Windows
net start redis

# Linux/Mac
redis-server
```

### 步骤 3：初始化数据库

```bash
mysql -u root -p < database_init.sql
```

### 步骤 4：启动后端

```bash
cd lab-items-backend
mvn clean install
mvn spring-boot:run
```

**验证：**
- 访问 http://localhost:8080/api/swagger-ui.html
- 查看控制台无报错

### 步骤 5：启动前端

打开新终端：

```bash
cd lab-items-frontend
npm install
npm run dev
```

**验证：**
- 访问 http://localhost:3000
- 能看到登录页面

### 步骤 6：功能测试

- [ ] 使用 admin/123456 登录
- [ ] 查看工作台是否正常显示
- [ ] 进入物品管理页面
- [ ] 尝试添加一个物品
- [ ] 查看 API 文档是否能访问

---

## 🌐 生产环境部署

### 服务器准备

- [ ] 操作系统：Linux (Ubuntu/CentOS) 或 Windows Server
- [ ] CPU：≥ 2 核
- [ ] 内存：≥ 4GB
- [ ] 磁盘：≥ 20GB
- [ ] 网络：可访问互联网

### 软件安装

#### Ubuntu/CentOS

```bash
# 安装 JDK 17
sudo apt install openjdk-17-jdk  # Ubuntu
sudo yum install java-17-openjdk  # CentOS

# 安装 MySQL 8
sudo apt install mysql-server  # Ubuntu
sudo yum install mysql-server  # CentOS

# 安装 Redis
sudo apt install redis-server  # Ubuntu
sudo yum install redis         # CentOS

# 安装 Nginx
sudo apt install nginx  # Ubuntu
sudo yum install nginx  # CentOS

# 安装 Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install nodejs
```

### 数据库部署

```bash
# 1. 启动 MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# 2. 安全初始化
sudo mysql_secure_installation

# 3. 创建数据库和用户
mysql -u root -p
CREATE DATABASE lab_items_management CHARACTER SET utf8mb4;
CREATE USER 'lab_app'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON lab_items_management.* TO 'lab_app'@'localhost';
FLUSH PRIVILEGES;

# 4. 导入数据
mysql -u lab_app -p lab_items_management < database_init.sql
```

### 后端部署

```bash
# 1. 构建
cd lab-items-backend
mvn clean package -DskipTests

# 2. 创建启动脚本
cat > start-backend.sh << 'EOF'
#!/bin/bash
nohup java -jar target/lab-items-backend-1.0.0.jar \
  --spring.profiles.active=prod \
  > app.log 2>&1 &
echo "后端服务启动中..."
sleep 5
tail -f app.log
EOF

chmod +x start-backend.sh

# 3. 启动
./start-backend.sh

# 4. 验证
curl http://localhost:8080/api/auth/info
```

### 前端部署

```bash
# 1. 构建
cd lab-items-frontend
npm install
npm run build

# 2. 复制 dist 到 Nginx 目录
sudo cp -r dist/* /var/www/html/

# 3. 配置 Nginx
sudo vim /etc/nginx/sites-available/lab-items

server {
    listen 80;
    server_name your-domain.com;
    
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# 4. 启用配置
sudo ln -s /etc/nginx/sites-available/lab-items /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### HTTPS 配置（推荐）

```bash
# 使用 Let's Encrypt 免费证书
sudo apt install certbot python3-certbot-nginx

sudo certbot --nginx -d your-domain.com

# 自动续期
sudo crontab -e
# 添加：0 3 * * * certbot renew --quiet
```

---

## 🔒 安全检查清单

### 应用安全

- [ ] 修改默认密码（所有默认账号）
- [ ] 配置强密码策略
- [ ] 启用 HTTPS
- [ ] 配置 CORS 白名单
- [ ] 禁用 Swagger UI（生产环境）
- [ ] 配置防火墙规则

### 数据库安全

- [ ] 使用专用数据库用户（非 root）
- [ ] 限制数据库远程访问
- [ ] 定期备份数据
- [ ] 启用慢查询日志

### 服务器安全

- [ ] 更新系统补丁
- [ ] 配置 SSH 密钥登录
- [ ] 禁用 root 远程登录
- [ ] 配置 fail2ban 防暴力破解
- [ ] 定期备份系统

---

## 📊 性能优化检查

### 后端优化

- [ ] 配置数据库连接池
  ```yaml
  spring:
    datasource:
      hikari:
        maximum-pool-size: 20
        minimum-idle: 5
  ```

- [ ] 启用 Redis 缓存
- [ ] 配置 JVM 参数
  ```bash
  java -Xms512m -Xmx2g -jar app.jar
  ```

- [ ] 开启 Gzip 压缩
  ```yaml
  server:
    compression:
      enabled: true
  ```

### 前端优化

- [ ] 启用代码分割
- [ ] 启用 Tree Shaking
- [ ] 压缩静态资源
- [ ] 配置 CDN（可选）
- [ ] 启用浏览器缓存

### 数据库优化

- [ ] 添加必要索引
- [ ] 配置查询缓存
- [ ] 优化慢查询

---

## 📝 验收测试

### 功能测试

- [ ] 用户登录/登出
- [ ] 物品 CRUD 操作
- [ ] 分类管理
- [ ] 权限控制
- [ ] 数据导出

### 性能测试

- [ ] 响应时间 < 2 秒
- [ ] 支持 50 人并发
- [ ] 页面加载 < 3 秒

### 兼容性测试

- [ ] Chrome 浏览器
- [ ] Firefox 浏览器
- [ ] Edge 浏览器
- [ ] Safari 浏览器
- [ ] 移动端适配

---

## ✅ 最终确认

- [ ] 所有服务正常运行
- [ ] 所有功能测试通过
- [ ] 性能指标达标
- [ ] 安全配置完成
- [ ] 备份策略配置
- [ ] 监控告警配置
- [ ] 文档齐全
- [ ] 用户培训完成

---

**部署完成！系统可以上线使用！** 🎉
