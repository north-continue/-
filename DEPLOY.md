# 部署文档

## 环境准备

### 1. 安装 JDK 17+

```bash
# Windows 用户
# 下载并安装：https://adoptium.net/temurin/releases/?version=17

# 验证安装
java -version
```

### 2. 安装 MySQL 8.0

```bash
# Windows 用户
# 下载安装包：https://dev.mysql.com/downloads/mysql/

# 安装后初始化
mysqld --initialize-insecure --console

# 启动服务
net start mysql

# 修改 root 密码
mysqladmin -u root password "your_password"
```

### 3. 安装 Redis

```bash
# Windows 用户
# 从 GitHub 下载：https://github.com/microsoftarchive/redis/releases

# 或使用 Chocolatey 安装
choco install redis-64

# 启动 Redis
redis-server
```

### 4. 安装 Node.js 18+

```bash
# Windows 用户
# 下载安装包：https://nodejs.org/

# 验证安装
node --version
npm --version
```

## 数据库初始化

```bash
# 登录 MySQL
mysql -u root -p

# 执行初始化脚本
source database_init.sql

# 验证
use lab_items_management;
show tables;
```

## 后端部署

### 开发环境

```bash
cd lab-items-backend

# 修改配置文件
# src/main/resources/application.yml
# 配置数据库连接和 Redis 连接

# Maven 构建
mvn clean install

# 启动服务
mvn spring-boot:run

# 或直接运行 jar
java -jar target/lab-items-backend-1.0.0.jar
```

### 生产环境

```bash
# 修改生产环境配置
# application-prod.yml

# 打包
mvn clean package -P prod

# 后台运行
nohup java -jar target/lab-items-backend-1.0.0.jar > app.log 2>&1 &

# 或使用 systemd (Linux)
sudo systemctl start lab-items-backend
```

### Docker 部署

```dockerfile
# Dockerfile
FROM openjdk:17-slim

WORKDIR /app

COPY target/lab-items-backend-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

```bash
# 构建镜像
docker build -t lab-items-backend .

# 运行容器
docker run -d \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/lab_items_management \
  -e SPRING_REDIS_HOST=host.docker.internal \
  --name lab-backend \
  lab-items-backend
```

## 前端部署

### 开发环境

```bash
cd lab-items-frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:3000
```

### 生产环境

```bash
# 安装依赖
npm install

# 构建
npm run build

# 预览
npm run preview
```

构建产物在 `dist/` 目录，可部署到 Nginx 或其他 Web 服务器。

### Nginx 配置

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/lab-items-frontend/dist;
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
```

## Jenkins CI/CD 配置

### Jenkins Pipeline 示例

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven 3.8'
        jdk 'JDK 17'
        nodejs 'Node 18'
    }
    
    environment {
        DOCKER_IMAGE = 'lab-items-backend'
        DOCKER_REGISTRY = 'your-registry.com'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/lab-items.git'
            }
        }
        
        stage('Backend Build') {
            steps {
                dir('lab-items-backend') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        
        stage('Frontend Build') {
            steps {
                dir('lab-items-frontend') {
                    sh 'npm install'
                    sh 'npm run build'
                }
            }
        }
        
        stage('Docker Build & Push') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${BUILD_ID}")
                    docker.image("${DOCKER_IMAGE}:${BUILD_ID}").push()
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                docker stop lab-backend || true
                docker rm lab-backend || true
                docker run -d \\
                  -p 8080:8080 \\
                  --name lab-backend \\
                  ${DOCKER_IMAGE}:${BUILD_ID}
                '''
            }
        }
    }
    
    post {
        always {
            junit '**/target/surefire-reports/*.xml'
        }
        success {
            echo '部署成功！'
        }
        failure {
            echo '部署失败！'
        }
    }
}
```

## 性能优化建议

### 1. 数据库优化

```sql
-- 添加索引
CREATE INDEX idx_item_status ON item(status);
CREATE INDEX idx_borrow_user ON borrow_record(borrower_user_id);

-- 定期分析表
ANALYZE TABLE item;
ANALYZE TABLE borrow_record;
```

### 2. Redis 缓存策略

```yaml
# application.yml
spring:
  cache:
    type: redis
  redis:
    lettuce:
      pool:
        max-active: 50
        max-idle: 20
        min-idle: 10
```

### 3. Nginx 优化

```nginx
# 开启 gzip 压缩
gzip on;
gzip_types text/plain text/css application/json application/javascript;

# 静态资源缓存
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

## 监控与日志

### 1. Spring Boot Actuator

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
```

### 2. 日志配置

```yaml
# application.yml
logging:
  level:
    com.lab.items: INFO
  file:
    name: logs/app.log
  logback:
    rollingpolicy:
      max-file-size: 10MB
      max-history: 30
```

### 3. Prometheus + Grafana 监控

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'lab-items'
    metrics_path: '/api/actuator/prometheus'
    static_configs:
      - targets: ['localhost:8080']
```

## 故障排查

### 常见问题

1. **后端启动失败**
   ```bash
   # 检查端口占用
   netstat -ano | findstr :8080
   
   # 查看日志
   tail -f logs/app.log
   ```

2. **前端无法连接后端**
   ```bash
   # 检查代理配置
   # vite.config.ts 中的 proxy 配置
   
   # 检查 CORS 配置
   # SecurityConfig.java 中的跨域设置
   ```

3. **数据库连接失败**
   ```bash
   # 检查 MySQL 服务状态
   service mysql status
   
   # 测试连接
   mysql -u root -p -h localhost
   ```

## 备份策略

### 数据库备份

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u root -p lab_items_management > ${BACKUP_DIR}/lab_${DATE}.sql

# 保留最近 30 天的备份
find ${BACKUP_DIR} -name "*.sql" -mtime +30 -delete
```

### 定时任务

```bash
# crontab -e
# 每天凌晨 2 点备份
0 2 * * * /path/to/backup.sh
```

---

**部署完成！** 🎉
