# 项目结构说明

## 📁 完整目录结构

```
lab-items-management/
│
├── 📄 README.md                          # 项目说明文档
├── 📄 DEPLOY.md                          # 部署文档
├── 📄 PROJECT_STRUCTURE.md               # 项目结构说明
├── 📄 database_init.sql                  # 数据库初始化脚本
├── 📄 .gitignore                         # Git 忽略配置
├── 📄 start.bat                          # Windows 启动脚本
│
├── 📂 lab-items-backend/                 # 后端项目
│   ├── 📄 pom.xml                        # Maven 配置文件
│   └── 📂 src/main/
│       ├── 📂 java/com/lab/items/
│       │   ├── 📄 LabItemsApplication.java           # 主启动类
│       │   │
│       │   ├── 📂 config/                            # 配置类
│       │   │   ├── SecurityConfig.java              # Spring Security 配置
│       │   │   ├── MybatisPlusConfig.java           # MyBatis Plus 配置
│       │   │   └── ...
│       │   │
│       │   ├── 📂 controller/                        # REST API 控制器
│       │   │   ├── AuthController.java              # 认证控制器
│       │   │   ├── ItemController.java              # 物品控制器
│       │   │   └── ...
│       │   │
│       │   ├── 📂 service/                           # 业务逻辑层
│       │   │   ├── AuthService.java                 # 认证服务
│       │   │   ├── ItemService.java                 # 物品服务
│       │   │   └── ...
│       │   │
│       │   ├── 📂 repository/                        # 数据访问层
│       │   │   ├── UserRepository.java              # 用户 Mapper
│       │   │   ├── ItemRepository.java              # 物品 Mapper
│       │   │   └── ...
│       │   │
│       │   ├── 📂 entity/                            # 实体类
│       │   │   ├── User.java                        # 用户实体
│       │   │   ├── Item.java                        # 物品实体
│       │   │   ├── Category.java                    # 类别实体
│       │   │   ├── BorrowRecord.java                # 借用记录实体
│       │   │   └── ...
│       │   │
│       │   ├── 📂 dto/                               # 数据传输对象
│       │   │   ├── R.java                           # 统一响应结果
│       │   │   ├── AuthRequest.java                 # 登录请求
│       │   │   ├── AuthResponse.java                # 登录响应
│       │   │   └── ...
│       │   │
│       │   ├── 📂 security/                          # 安全相关
│       │   │   └── JwtAuthenticationFilter.java     # JWT 认证过滤器
│       │   │
│       │   ├── 📂 util/                              # 工具类
│       │   │   └── JwtUtil.java                     # JWT 工具
│       │   │
│       │   └── 📂 exception/                         # 异常处理
│       │       └── ...
│       │
│       └── 📂 resources/
│           ├── 📄 application.yml                    # 应用配置文件
│           ├── 📂 mapper/                            # MyBatis XML
│           │   ├── UserRepository.xml
│           │   ├── ItemRepository.xml
│           │   └── ...
│           └── 📂 static/                            # 静态资源
│               └── ...
│
└── 📂 lab-items-frontend/                # 前端项目
    ├── 📄 package.json                     # Node.js 依赖配置
    ├── 📄 vite.config.ts                   # Vite 构建配置
    ├── 📄 tsconfig.json                    # TypeScript 配置
    ├── 📄 tsconfig.node.json               # TypeScript Node 配置
    │
    └── 📂 src/
        ├── 📄 main.ts                      # 应用入口文件
        ├── 📄 App.vue                      # 根组件
        ├── 📄 vite-env.d.ts                # TypeScript 类型声明
        │
        ├── 📂 api/                         # API 接口封装
        │   └── 📄 index.ts                 # API 接口定义
        │
        ├── 📂 router/                      # 路由配置
        │   └── 📄 index.ts                 # 路由定义
        │
        ├── 📂 store/                       # Pinia 状态管理
        │   ├── 📄 index.ts                 # Store 配置
        │   └── 📂 modules/                 # 模块
        │       ├── user.ts                # 用户模块
        │       └── ...
        │
        ├── 📂 utils/                       # 工具函数
        │   └── 📄 request.ts              # Axios 请求封装
        │
        ├── 📂 views/                       # 页面组件
        │   ├── 📄 Login.vue               # 登录页
        │   ├── 📄 Layout.vue              # 布局页
        │   ├── 📄 Dashboard.vue           # 工作台
        │   │
        │   ├── 📂 items/                  # 物品管理
        │   │   ├── ItemList.vue          # 物品列表
        │   │   └── ItemDetail.vue        # 物品详情
        │   │
        │   ├── 📂 inventory/              # 库存管理
        │   │   ├── InStock.vue           # 入库管理
        │   │   ├── OutStock.vue          # 出库管理
        │   │   └── InventoryCheck.vue    # 盘点管理
        │   │
        │   ├── 📂 borrow/                 # 借用管理
        │   │   └── BorrowList.vue        # 借用列表
        │   │
        │   ├── 📂 repair/                 # 报废报修
        │   │   └── RepairList.vue        # 报修列表
        │   │
        │   ├── 📂 system/                 # 系统管理
        │   │   └── UserManage.vue        # 用户管理
        │   │
        │   └── 📄 Statistics.vue          # 数据统计
        │
        ├── 📂 components/                  # 通用组件
        │   ├── 📂 common/                 # 通用组件
        │   └── 📂 charts/                 # 图表组件
        │
        └── 📂 styles/                      # 样式文件
            ├── 📄 index.scss              # 全局样式
            └── 📄 variables.scss          # 样式变量
```

## 🔑 核心文件说明

### 后端核心文件

| 文件 | 说明 | 作用 |
|------|------|------|
| `LabItemsApplication.java` | 主启动类 | Spring Boot 应用入口 |
| `SecurityConfig.java` | 安全配置 | 配置 Spring Security 和 JWT |
| `MybatisPlusConfig.java` | ORM 配置 | 配置 MyBatis Plus 分页和自动填充 |
| `JwtUtil.java` | JWT 工具 | Token 生成和解析 |
| `AuthController.java` | 认证接口 | 登录、登出、获取用户信息 |
| `ItemController.java` | 物品接口 | 物品 CRUD 操作 |
| `application.yml` | 配置文件 | 数据库、Redis、JWT 等配置 |

### 前端核心文件

| 文件 | 说明 | 作用 |
|------|------|------|
| `main.ts` | 入口文件 | 初始化 Vue 应用、注册插件 |
| `App.vue` | 根组件 | 应用根组件 |
| `router/index.ts` | 路由配置 | 定义所有路由和导航守卫 |
| `api/index.ts` | API 接口 | 封装所有后端 API 调用 |
| `utils/request.ts` | 请求封装 | Axios 拦截器、错误处理 |
| `views/Login.vue` | 登录页 | 用户登录界面 |
| `views/Layout.vue` | 布局页 | 主框架（侧边栏 + 顶栏） |
| `views/Dashboard.vue` | 工作台 | 数据统计和概览 |
| `views/items/ItemList.vue` | 物品列表 | 物品管理和查询 |

## 🗂️ 数据库表结构

### 核心表

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `user` | 用户表 | username, password, role, department |
| `category` | 物品类别 | category_name, parent_id, level |
| `item` | 物品表 | item_code, qr_code, item_name, quantity, status |
| `in_record` | 入库记录 | in_no, item_id, quantity, in_type |
| `out_record` | 出库记录 | out_no, item_id, quantity, out_type |
| `borrow_record` | 借用记录 | borrow_no, item_id, borrower, status |
| `repair_record` | 报废报修 | repair_no, item_id, fault_description |
| `alert_config` | 库存预警 | item_id, min_stock, max_stock |
| `operation_log` | 操作日志 | module, operation_type, operator |
| `inventory_check` | 盘点记录 | check_no, check_type, status |
| `system_config` | 系统配置 | config_key, config_value |
| `notification` | 消息通知 | title, content, receiver, is_read |

## 🔌 API 接口分类

### 认证相关
- `POST /auth/login` - 用户登录
- `GET /auth/info` - 获取当前用户
- `POST /auth/logout` - 用户登出

### 物品管理
- `GET /items` - 分页查询物品
- `GET /items/{id}` - 获取物品详情
- `POST /items` - 创建物品
- `PUT /items` - 更新物品
- `DELETE /items/{id}` - 删除物品
- `GET /items/qr/{qrCode}` - 扫码获取物品
- `POST /items/batch` - 批量导入

### 其他功能（待实现）
- 入库管理
- 出库管理
- 借用管理
- 报废报修
- 盘点管理
- 系统管理

## 🎨 技术架构

### 分层架构

```
┌─────────────────────────────────────┐
│         前端展示层 (Vue3)            │
│  ┌─────────────────────────────┐    │
│  │   Views (页面组件)           │    │
│  │   Components (通用组件)      │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│         API 网关层 (Axios)           │
│  ┌─────────────────────────────┐    │
│  │   Request Interceptors      │    │
│  │   Response Interceptors     │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      后端控制层 (Spring MVC)         │
│  ┌─────────────────────────────┐    │
│  │   Controllers (REST API)    │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│       业务逻辑层 (Service)           │
│  ┌─────────────────────────────┐    │
│  │   Services (业务逻辑)        │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      数据访问层 (MyBatis Plus)       │
│  ┌─────────────────────────────┐    │
│  │   Repositories (Mapper)     │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│         数据存储层                   │
│  ┌──────────┐    ┌──────────────┐  │
│  │  MySQL   │    │    Redis     │  │
│  │ (主数据)  │    │  (缓存/会话)  │  │
│  └──────────┘    └──────────────┘  │
└─────────────────────────────────────┘
```

## 🚀 开发流程

### 新增功能模块

1. **数据库设计**
   - 创建/修改表结构
   - 更新 `database_init.sql`

2. **后端开发**
   - 创建 Entity 实体类
   - 创建 Repository 数据访问接口
   - 创建 Service 业务逻辑类
   - 创建 Controller REST 控制器
   - 编写单元测试

3. **前端开发**
   - 在 `api/index.ts` 添加 API 接口
   - 创建 View 页面组件
   - 创建 Router 路由配置
   - 调试和测试

4. **联调测试**
   - 前后端联调
   - 功能测试
   - 性能优化

5. **部署上线**
   - 代码审查
   - 打包构建
   - 部署到服务器

## 📊 权限设计

### 角色权限矩阵

| 功能模块 | ADMIN | LAB_ADMIN | TEACHER | STUDENT |
|---------|-------|-----------|---------|---------|
| 系统管理 | ✅ | ❌ | ❌ | ❌ |
| 用户管理 | ✅ | ❌ | ❌ | ❌ |
| 物品建档 | ✅ | ✅ | ❌ | ❌ |
| 物品编辑 | ✅ | ✅ | ❌ | ❌ |
| 物品删除 | ✅ | ✅ | ❌ | ❌ |
| 入库管理 | ✅ | ✅ | ❌ | ❌ |
| 出库管理 | ✅ | ✅ | ❌ | ❌ |
| 借用申请 | ✅ | ✅ | ✅ | ✅ |
| 借用审批 | ✅ | ✅ | ❌ | ❌ |
| 报废申请 | ✅ | ✅ | ✅ | ✅ |
| 报废审核 | ✅ | ✅ | ❌ | ❌ |
| 盘点管理 | ✅ | ✅ | ❌ | ❌ |
| 数据统计 | ✅ | ✅ | ✅ | ✅ |

---

**完整的实验室物品管理平台项目结构！** 🎓
