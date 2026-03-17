# 实验室物品管理平台 - 完整测试指南

## 📋 测试前准备

### 1. 环境检查清单

#### 必需软件
- [ ] JDK 17+ 已安装
- [ ] Maven 3.8+ 已安装
- [ ] MySQL 8.0+ 已安装并运行
- [ ] Redis 已安装并运行（可选）
- [ ] Node.js 18+ 已安装

#### 验证命令
```bash
# 检查 Java
java -version

# 检查 Maven
mvn -version

# 检查 MySQL
mysql --version

# 检查 Redis
redis-cli ping

# 检查 Node.js
node --version
npm --version
```

---

## 🚀 第一步：数据库初始化测试

### 方法 1：使用命令行（推荐）

```bash
# 1. 登录 MySQL
mysql -u root -p

# 2. 删除旧数据库（如果有）
DROP DATABASE IF EXISTS lab_items_management;

# 3. 执行 SQL 文件
source c:/Users/north/Desktop/1/database_init.sql;

# 4. 验证数据库
USE lab_items_management;
SHOW TABLES;
```

**预期结果：** 应该看到 13 张表：
```
+--------------------------------+
| Tables_in_lab_items_management |
+--------------------------------+
| user                           |
| category                       |
| item                           |
| in_record                      |
| out_record                     |
| borrow_record                  |
| repair_record                  |
| alert_config                   |
| operation_log                  |
| inventory_check                |
| inventory_check_detail         |
| system_config                  |
| notification                   |
+--------------------------------+
```

### 方法 2：使用 Navicat/MySQL Workbench

1. 打开 Navicat 或 MySQL Workbench
2. 连接到 MySQL 数据库
3. 右键删除 `lab_items_management` 数据库（如果存在）
4. 右键 → 执行 SQL 文件
5. 选择 `database_init.sql`
6. 点击开始执行

### 验证数据

```sql
-- 查看用户数据
SELECT user_id, username, real_name, role FROM user;

-- 查看类别数据
SELECT category_id, category_name, level FROM category;

-- 查看系统配置
SELECT config_key, config_value FROM system_config;
```

---

## 🖥️ 第二步：后端启动测试

### 1. 配置检查

编辑 `lab-items-backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/lab_items_management?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password  # ⚠️ 修改为你的 MySQL 密码
  redis:
    host: localhost
    port: 6379
    # password: your_redis_password  # 如果 Redis 有密码
```

### 2. 启动后端

```bash
# 打开终端
cd c:\Users\north\Desktop\1\lab-items-backend

# 清理并编译
mvn clean install

# 启动服务
mvn spring-boot:run
```

### 3. 验证后端启动成功

**启动成功的标志：**
```
  ____            _              ___                   _ 
 | __ )  __ _ ___| |__   ___ _ _|_ _|_ __   __ _  ___| |
 |  _ \ / _` / __| '_ \ / _ \ '__|| || '_ \ / _` |/ _ \ |
 | |_) | (_| \__ \ | | |  __/ |   | || | | | (_| |  __/ |
 |____/ \__,_|___/_| |_|\___|_|  |___|_| |_|\__, |\___|_|
                                            |___/        
实验室物品管理平台启动成功！
API 文档：http://localhost:8080/api/swagger-ui.html
服务端口：8080
数据库：已连接
Redis：已连接
```

### 4. 测试后端 API

**测试 1：访问 Swagger UI**
- 打开浏览器：http://localhost:8080/api/swagger-ui.html
- 应该看到 API 文档界面

**测试 2：测试登录接口**

使用 curl 命令：
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"123456\"}"
```

或使用 Postman：
- URL: `POST http://localhost:8080/api/auth/login`
- Body (JSON):
```json
{
  "username": "admin",
  "password": "123456"
}
```

**预期响应：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "userId": 1,
      "username": "admin",
      "realName": "系统管理员",
      "role": "ADMIN"
    }
  }
}
```

**测试 3：测试物品列表接口**

```bash
curl -X GET "http://localhost:8080/api/items?pageNum=1&pageSize=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🌐 第三步：前端启动测试

### 1. 配置检查

编辑 `lab-items-frontend/vite.config.ts`，确保代理配置正确：

```typescript
export default defineConfig({
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  }
})
```

### 2. 安装依赖（首次运行）

```bash
cd c:\Users\north\Desktop\1\lab-items-frontend
npm install
```

### 3. 启动前端

```bash
# 开发模式
npm run dev
```

**启动成功的标志：**
```
  VITE v5.x.x  ready in xxx ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: use --host to expose
```

### 4. 验证前端

1. 打开浏览器访问：http://localhost:3000
2. 应该看到登录页面
3. 使用默认账号登录：
   - 用户名：`admin`
   - 密码：`123456`

---

## ✅ 第四步：功能测试

### 测试用例 1：用户登录

**步骤：**
1. 访问 http://localhost:3000
2. 输入用户名：`admin`
3. 输入密码：`123456`
4. 点击登录

**预期结果：**
- 登录成功
- 跳转到工作台页面
- 左侧菜单显示所有功能模块
- 顶部显示用户信息

### 测试用例 2：查看物品列表

**步骤：**
1. 点击左侧菜单 "物品管理" → "物品列表"
2. 查看物品列表

**预期结果：**
- 显示物品列表（初始为空）
- 分页组件正常显示
- 搜索框可用

### 测试用例 3：添加物品

**步骤：**
1. 点击 "添加物品" 按钮
2. 填写物品信息：
   - 物品名称：测试笔记本电脑
   - 类别：计算机设备
   - 规格型号：Dell XPS 15
   - 数量：10
   - 单位：台
   - 存放位置：实验楼 301
3. 点击保存

**预期结果：**
- 保存成功提示
- 物品列表中显示新物品
- 数据库中有记录

### 测试用例 4：物品分类

**步骤：**
1. 点击左侧菜单 "物品管理" → "分类管理"
2. 查看分类列表

**预期结果：**
- 显示 9 个预置分类
- 树形结构显示
- 可以展开/收起子分类

### 测试用例 5：数据统计

**步骤：**
1. 点击左侧菜单 "工作台"
2. 查看统计卡片

**预期结果：**
- 显示物品总数、借用次数等统计
- 图表正常显示（如果有数据）

---

## 🔍 第五步：API 接口测试

### 使用 Postman 测试

#### 1. 登录接口
- **URL**: `POST http://localhost:8080/api/auth/login`
- **Body**:
```json
{
  "username": "admin",
  "password": "123456"
}
```
- **预期**: 返回 token 和用户信息

#### 2. 获取当前用户信息
- **URL**: `GET http://localhost:8080/api/auth/info`
- **Header**: `Authorization: Bearer YOUR_TOKEN`
- **预期**: 返回当前登录用户信息

#### 3. 获取物品列表
- **URL**: `GET http://localhost:8080/api/items?pageNum=1&pageSize=10`
- **Header**: `Authorization: Bearer YOUR_TOKEN`
- **预期**: 返回物品列表（分页）

#### 4. 获取分类列表
- **URL**: `GET http://localhost:8080/api/categories/all`
- **预期**: 返回所有分类

#### 5. 创建物品
- **URL**: `POST http://localhost:8080/api/items`
- **Header**: 
  - `Authorization: Bearer YOUR_TOKEN`
  - `Content-Type: application/json`
- **Body**:
```json
{
  "itemName": "测试物品",
  "categoryId": 1,
  "specification": "规格型号",
  "brand": "品牌",
  "unit": "台",
  "price": 1000.00,
  "totalQuantity": 10,
  "availableQuantity": 10,
  "location": "实验楼 301",
  "labRoom": "301",
  "shelf": "A-01"
}
```
- **预期**: 创建成功

---

## 🐛 常见问题排查

### 问题 1：后端启动失败 - 数据库连接错误

**错误信息：**
```
Could not open JDBC Connection for transaction
```

**解决方案：**
1. 检查 MySQL 服务是否启动
2. 验证 `application.yml` 中的数据库配置
3. 测试数据库连接：
```bash
mysql -u root -p lab_items_management
```

### 问题 2：前端无法访问后端 - CORS 错误

**错误信息：**
```
Access to XMLHttpRequest has been blocked by CORS policy
```

**解决方案：**
1. 检查后端 `SecurityConfig.java` 中的 CORS 配置
2. 确保 Vite 代理配置正确
3. 清除浏览器缓存

### 问题 3：登录失败 - 401 Unauthorized

**可能原因：**
1. 用户名或密码错误
2. 用户被禁用
3. JWT 密钥配置错误

**解决方案：**
1. 检查数据库中用户是否存在
2. 验证用户状态（status=1）
3. 检查后端 JWT 配置

### 问题 4：端口被占用

**错误信息：**
```
Port 8080 was already in use
```

**解决方案：**
```bash
# Windows - 查找并结束进程
netstat -ano | findstr :8080
taskkill /F /PID <进程 ID>

# 或修改端口
# application.yml
server:
  port: 8081
```

### 问题 5：前端页面空白

**可能原因：**
1. 后端服务未启动
2. API 路径配置错误
3. 浏览器控制台有错误

**解决方案：**
1. 检查后端是否正常运行
2. 查看浏览器 Console 错误信息
3. 清除缓存重新加载

---

## 📊 测试报告模板

### 测试结果汇总

| 测试项 | 测试内容 | 结果 | 备注 |
|--------|---------|------|------|
| 数据库初始化 | 13 张表创建 | ✅/❌ | |
| 用户数据 | 4 个默认用户 | ✅/❌ | |
| 后端启动 | Spring Boot 启动 | ✅/❌ | |
| 前端启动 | Vite 启动 | ✅/❌ | |
| 用户登录 | admin 登录 | ✅/❌ | |
| 物品管理 | CRUD 操作 | ✅/❌ | |
| 分类管理 | 树形结构 | ✅/❌ | |
| API 测试 | Swagger UI | ✅/❌ | |

### 性能测试结果

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| 登录响应时间 | < 2 秒 | xx 秒 | ✅/❌ |
| 列表查询时间 | < 2 秒 | xx 秒 | ✅/❌ |
| 并发用户数 | 50 人 | xx 人 | ✅/❌ |

---

## 🎯 测试完成标准

- [x] 数据库初始化成功（13 张表 + 视图 + 存储过程）
- [x] 后端服务正常启动
- [x] 前端服务正常启动
- [x] 用户可以成功登录
- [x] 物品管理功能正常
- [x] 分类管理功能正常
- [x] API 接口测试通过
- [x] 无严重错误和异常

---

## 📝 测试记录

**测试日期：** 2024-xx-xx  
**测试人员：** xxx  
**测试环境：** 
- OS: Windows 11
- JDK: 17.0.9
- MySQL: 8.0.35
- Node.js: 18.19.0
- 浏览器：Chrome 120

**测试结果：**
- 通过：xx 项
- 失败：xx 项
- 阻塞：xx 项

**问题汇总：**
1. [问题描述]
2. [问题描述]

**建议：**
1. [改进建议]
2. [改进建议]

---

**测试完成！** 🎉
