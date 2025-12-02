# .cursorrules (项目规则与规范)

你是一位资深的 Flutter 工程师和 Android 系统专家。你正在开发 "MediaStream Pro"，这是一款专为 Android TV 盒子和手机设备优化的高性能视频解析与播放应用。

## 1. 项目背景与愿景
- **目标**: 构建一个去中心化的媒体播放工具。用户输入 URL，应用将其解析为可播放的媒体流。
- **目标平台**: Android TV (重点适配方向键/遥控器交互) & Android 手机 (触屏交互)。
- **核心特征**: 极致性能、整洁架构 (Clean Architecture)、可扩展的多源解析能力。

## 2. 技术栈约束 (Tech Stack)
- **框架**: Flutter (Dart 3.x, 必须开启 Null Safety)。
- **状态管理**: **Riverpod** (v2.x, 推荐使用代码生成 `@riverpod` 方式)。
- **路由管理**: **GoRouter** (声明式路由)。
- **网络请求**: **Dio** (Http 客户端)。
- **本地数据库**: **Isar** (NoSQL, 高性能，适合存储大量历史记录)。
- **视频播放器**: **media_kit** (首选，性能更好) 或 `video_player` (备选)。
- **UI 设计系统**: Material 3。

## 3. 架构规范 (严格遵守)
我们要遵循 **Clean Architecture (整洁架构)**，并采用特定的 4 层结构。

### A. 依赖原则 (The Dependency Rule)
- **Domain 层 (业务层)**：**严禁**依赖任何其他层（不能依赖 Flutter UI、Data 实现或 Dio/Isar 等外部库）。它是纯 Dart 代码。
- **Data 层 (数据层)**：依赖 Domain 层。
- **Presentation 层 (表现层)**：依赖 Domain 层。
- **Source 层 (源解析层)**：依赖 Domain/Data 的定义，但逻辑上必须与核心业务隔离。

### B. 各层职责
1.  **`presentation/` (UI 层)**:
    - 包含 Widgets, Screens, 和 Riverpod Notifiers。
    - **规则**: UI 层**严禁**包含任何业务逻辑。UI 只能调用 UseCases 或监听 Providers。
    - **规则**: 组件必须支持 TV 端的焦点遍历 (Focus Traversal)。
2.  **`domain/` (核心层)**:
    - 包含 Entities (实体), UseCases (用例), Repository Interfaces (仓库接口)。
    - **规则**: 实体必须是纯 Dart 对象 (不要写 `fromJson`, 这是 DTO 的事)。
3.  **`data/` (实现层)**:
    - 包含 Repository Implementations (接口实现), Data Sources (数据源), DTOs。
    - **规则**: 必须在此层将 DTOs 转换为 Domain 实体。
4.  **`source/` (解析层 - 关键扩展)**:
    - 专门用于存放特定网站的解析逻辑。
    - **规则**: 所有解析逻辑必须实现 `BaseParser` 接口。
    - **规则**: **严禁**在通用的 Repository 中硬编码解析逻辑 (如针对某网站的 regex/爬虫代码)。

## 4. 目录结构映射
请严格遵循此结构，不要随意在根目录创建文件夹。

```text
lib/
├── core/                   # 核心通用工具 (Utils, Constants, Failures, UseCase Interface)
├── data/                   # 数据层 (外部实现)
│   ├── datasources/        # 具体数据源 (internal_db_source.dart, http_client.dart)
│   ├── repositories/       # 实现 Domain 层的 Repository 接口
│   └── dtos/               # 数据传输对象 (JSON/DB 模型, 包含 fromJson/toJson)
├── domain/                 # 业务层 (纯 Dart)
│   ├── entities/           # 核心业务对象 (MediaBookmark, MediaLink)
│   ├── media_source/       # 统一的源数据模型 (标准化的数据格式)
│   ├── repositories/       # 抽象接口 (Abstract Interfaces)
│   └── usecases/           # 单一职责的业务逻辑单元
├── source/                 # 源解析适配层 (保证可扩展性)
│   ├── parsers/            # 具体的解析器实现 (例如: DirectLinkParser, YouTubeParser)
│   ├── source_models/      # 来自网站的原始数据结构
│   └── mappers/            # 原始数据 -> Domain 实体的映射器
└── presentation/           # UI 视图层
    ├── home_browse/        # 首页相关的页面 & Providers
    ├── player/             # 播放器相关的页面 & Controllers
    ├── bookmarks_history/  # 历史记录/收藏夹页面
    ├── settings/           # 设置页面
    └── ui_shared/          # 主题, 颜色, 通用可复用组件
```

## 5. 编码规范
通用规范
1. 类名/类型使用 PascalCase (大驼峰)。
2. 变量/函数使用 camelCase (小驼峰)。
3. 文件名使用 snake_case (蛇形命名)。
4. 在可能的情况下，Widgets 构造函数必须使用 const。
5. 默认使用 final 定义变量。
6. 状态管理 (Riverpod)
    - 优先使用 ConsumerWidget 或 ConsumerStatefulWidget。
    - 在 build 方法中使用 ref.watch 监听状态。
    - 在回调方法 (如 onPressed) 中使用 ref.read 读取状态。
    - 逻辑应封装在 Notifier 或 AsyncNotifier 中，而非 Widget 内部。

7. 异步编程
    - 使用 async/await，避免使用 .then()。
    - 在 Data Source 层必须使用 try-catch 捕获异常，并返回 Either<Failure, Type> 或抛出自定义异常供 Repository 捕获。

9. 扩展性规范 (针对解析器)
    - 当需要添加新的视频源支持时，必须在 lib/source/parsers/ 下创建一个新文件。
    - 不要修改现有的解析器来添加新网站的逻辑。
    - 在 Repository 中使用 策略模式 (Strategy Pattern) 根据 URL 动态选择正确的 Parser。

## 6. 开发任务清单 (第一期 MVP)
- 环境搭建: 初始化 GoRouter 路由表和 App 主题。
- Domain 定义: 定义 MediaBookmark 实体和 UrlRepository 接口。
- Source 实现: 创建 BaseParser 抽象类。实现 DirectLinkParser (基础直链解析)。
- Data 实现: 实现 SourceRepositoryImpl，负责调度 Parser。
- UI 开发: 创建 HomePage，包含 URL 输入框。
- 播放器集成: 集成基础的 video_player 或 media_kit。

## 7. 负面清单 (绝对禁止的行为)
- 禁止: 使用 GetX。
- 禁止: 在 Widget (UI) 中直接发起 HTTP 请求 (Dio)。
- 禁止: 混用 Presentation 模型和 Data DTOs。必须进行转换映射。
- 禁止: 硬编码字符串。请使用常量文件或本地化方案。

## UI设计风格
未来主义 UI 设计，适用于流媒体应用程序，Android TV 界面，深色主题，高对比度，特点是包含一个巨大的电影风格英雄横幅（hero banner），横幅中有人物为宇航员和深空星云。界面使用霓虹蓝和青色作为强调色，排版简洁清晰，内容卡片网格水平滚动，要求高度细节化，8K 分辨率，概念艺术风格。