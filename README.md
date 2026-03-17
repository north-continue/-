# 实验室物品管理平台

基于 Web 的实验室物品全生命周期管理系统，支持二维码管理、出入库管理、借用归还、报废报修等功能。

## 📋 项目特性

- ✅ **物品全生命周期管理**：从建档、入库、出库到报废的全流程管理
- ✅ **二维码管理**：支持二维码批量生成、打印、扫描识别
- ✅ **多角色权限控制**：系统管理员、实验室管理员、教师、学生四种角色
- ✅ **库存预警**：自动监控库存状态，低库存时提醒
- ✅ **数据可视化**：ECharts 图表展示库存状态、借用频率等统计信息
- ✅ **前后端分离架构**：Vue3 + Spring Boot，易于扩展和维护

## 🛠️ 技术栈

### 后端
- **框架**: Spring Boot 3.2.0
- **安全**: Spring Security + JWT
- **ORM**: MyBatis Plus
- **数据库**: MySQL 8.0
- **缓存**: Redis
- **API 文档**: Springdoc OpenAPI 3

### 前端
- **框架**: Vue 3.4 + TypeScript
- **UI 组件**: Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router 4
- **HTTP 客户端**: Axios
- **图表**: ECharts 5
- **构建工具**: Vite 5

## 📦 快速开始

### 环境要求
- Node.js >= 18
- JDK >= 17
- MySQL >= 8.0
- Redis >= 6.0

### 1. 数据库初始化

```bash
# 登录 MySQL
mysql -u root -p

# 执行初始化脚本
source database_init.sql
```

### 2. 启动后端服务

```bash
cd lab-items-backend

# 修改配置文件 src/main/resources/application.yml
# 配置数据库连接和 Redis 连接

# Maven 构建并启动
mvn clean install
mvn spring-boot:run

# 或者直接运行 jar
java -jar target/lab-items-backend-1.0.0.jar
```

后端服务将在 http://localhost:8080/api 启动

API 文档地址：http://localhost:8080/api/swagger-ui.html

### 3. 启动前端服务

```bash
cd lab-items-frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build
```

前端服务将在 http://localhost:3000 启动

## 👤 默认账号

| 用户名 | 密码 | 角色 | 说明 |
|--------|------|------|------|
| admin | 123456 | ADMIN | 系统管理员 |
| labadmin | 123456 | LAB_ADMIN | 实验室管理员 |
| teacher1 | 123456 | TEACHER | 教师 |
| student1 | 123456 | STUDENT | 学生 |

## 📁 项目结构

```
lab-items-management/
├── database_init.sql          # 数据库初始化脚本
├── lab-items-backend/         # 后端项目
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/lab/items/
│       │   ├── LabItemsApplication.java    # 主启动类
│       │   ├── config/                     # 配置类
│       │   ├── controller/                 # 控制器层
│       │   ├── service/                    # 服务层
│       │   ├── repository/                 # 数据访问层
│       │   ├── entity/                     # 实体类
│       │   ├── dto/                        # 数据传输对象
│       │   ├── security/                   # 安全相关
│       │   └── util/                       # 工具类
│       └── resources/
│           ├── application.yml             # 配置文件
│           └── mapper/                     # MyBatis XML
└── lab-items-frontend/        # 前端项目
    ├── package.json
    ├── vite.config.ts
    └── src/
        ├── main.ts                       # 入口文件
        ├── App.vue                       # 根组件
        ├── api/                          # API 接口
        ├── router/                       # 路由配置
        ├── store/                        # 状态管理
        ├── utils/                        # 工具函数
        ├── views/                        # 页面组件
        └── styles/                       # 样式文件
```

## 🔧 配置说明

### 后端配置 (application.yml)

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/lab_items_management
    username: root
    password: your_password
  
  redis:
    host: localhost
    port: 6379

jwt:
  secret: your-secret-key
  expiration: 86400000
```

### 前端代理配置 (vite.config.ts)

```typescript
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```

## 📊 主要功能模块

### 1. 物品管理
- 物品建档（名称、类别、规格、位置、图片等）
- 二维码生成与管理
- 物品信息查询、编辑、删除
- 批量导入导出

### 2. 入库管理
- 扫码入库
- 入库记录查询
- 采购入库、归还入库、调拨入库

### 3. 出库管理
- 扫码出库
- 出库记录查询
- 借用出库、领用出库

### 4. 借用管理
- 借用申请
- 借用审批
- 归还操作
- 逾期提醒

### 5. 报废报修
- 报废申请
- 报修申请
- 审核处理
- 维修记录

### 6. 盘点管理
- 定期盘点
- 临时盘点
- 盘点报告
- 差异分析

### 7. 数据统计
- 库存状态统计
- 借用频率分析
- 分类统计
- 趋势分析

### 8. 系统管理
- 用户管理
- 角色权限管理
- 操作日志审计
- 系统配置

## 🔐 安全性

- JWT Token 认证
- RBAC 角色权限控制
- 密码 BCrypt 加密
- CORS 跨域配置
- SQL 注入防护（MyBatis Plus）
- XSS 攻击防护

## 📝 开发规范

### 代码风格
- 后端：遵循阿里巴巴 Java 开发手册
- 前端：遵循 Vue3 + TypeScript 最佳实践

### Git 提交规范
```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 重构代码
test: 测试相关
chore: 构建/工具链相关
```

## 🚀 部署

### Docker 部署（待实现）

```bash
# 构建镜像
docker build -t lab-items-backend .

# 运行容器
docker run -d -p 8080:8080 lab-items-backend
```

### Jenkins CI/CD（待实现）

配置 Jenkins Pipeline 实现自动化构建和部署。

## 📄 常见问题

### 1. 前端启动失败
```bash
# 清除缓存重新安装
rm -rf node_modules package-lock.json
npm install
```

### 2. 后端数据库连接失败
- 检查 MySQL 是否启动
- 检查数据库连接配置
- 检查数据库是否已创建

### 3. Redis 连接失败
- 检查 Redis 是否启动
- 检查 Redis 密码配置

## 📞 技术支持

如有问题，请提交 Issue 或联系开发团队。

## 📜 许可证

MIT License

---

**毕业设计项目** | 2024
