# LifeTV 视频源解析流程图

## 解析逻辑流程图

```mermaid
flowchart TD
    Start([开始]) --> Input[输入视频源URL]
    Input --> FetchConfig[获取视频源配置]
    
    %% 配置获取和解析流程
    FetchConfig --> TryRequest{尝试请求}
    TryRequest -->|AllOrigins代理| Proxy1[使用AllOrigins代理]
    TryRequest -->|CORS代理| Proxy2[使用CORS代理]
    TryRequest -->|直接请求| Direct[直接请求URL]
    
    Proxy1 --> ValidateResp{验证响应}
    Proxy2 --> ValidateResp
    Direct --> ValidateResp
    
    ValidateResp -->|失败| RetryOther[尝试其他方式]
    RetryOther --> TryRequest
    
    ValidateResp -->|成功| ParseConfig[解析配置JSON]
    
    %% 配置解析分支
    ParseConfig --> CheckSpider{包含Spider?}
    CheckSpider -->|是| HandleSpider[处理Spider配置]
    HandleSpider --> ParseJar[解析JAR信息]
    ParseJar --> ExtractMD5[提取MD5]
    
    CheckSpider -->|否| CheckSites{检查站点列表}
    HandleSpider --> CheckSites
    
    CheckSites -->|无站点| Error1[抛出错误]
    CheckSites -->|有站点| ProcessSites[处理站点列表]
    
    %% 站点处理流程
    ProcessSites --> ForEachSite[遍历每个站点]
    ForEachSite --> HandleType[处理类型]
    HandleType --> HandleApi[处理API]
    HandleApi --> HandleExt[处理扩展字段]
    
    HandleExt --> IsBase64{是Base64?}
    IsBase64 -->|是| DecodeBase64[Base64解码]
    IsBase64 -->|否| CheckUrl{是URL?}
    DecodeBase64 --> CheckUrl
    
    CheckUrl -->|是| ValidateUrl[验证URL]
    CheckUrl -->|否| NextSite[处理下一个站点]
    ValidateUrl --> NextSite
    
    NextSite --> ForEachSite
    
    %% 视频获取流程
    ProcessSites --> FetchVideos[获取视频列表]
    FetchVideos --> CheckType{检查类型}
    
    CheckType -->|API| ApiVideos[API类型处理]
    CheckType -->|Spider| SpiderVideos[Spider类型处理]
    CheckType -->|WebPage| WebVideos[网页类型处理]
    CheckType -->|Live| LiveVideos[直播类型处理]
    
    %% Spider视频处理
    SpiderVideos --> DownloadJar[下载JAR文件]
    DownloadJar --> CheckCache{检查缓存}
    CheckCache -->|存在| LoadCache[加载缓存]
    CheckCache -->|不存在| SaveNew[保存新文件]
    
    LoadCache --> ParseRules[解析规则]
    SaveNew --> ParseRules
    
    ParseRules --> BuildRequest[构建请求]
    BuildRequest --> SendRequest[发送请求]
    SendRequest --> ParseResponse[解析响应]
    
    %% 数据标准化
    ApiVideos --> StandardizeData[数据标准化]
    ParseResponse --> StandardizeData
    WebVideos --> StandardizeData
    LiveVideos --> StandardizeData
    
    StandardizeData --> End([结束])
    
    %% 错误处理
    Error1 --> ErrorHandler[错误处理]
    ErrorHandler --> End
    
    style Start fill:#f9f,stroke:#333,stroke-width:2px
    style End fill:#f9f,stroke:#333,stroke-width:2px
    style ErrorHandler fill:#f66,stroke:#333,stroke-width:2px
```

## 流程说明

### 1. 初始化阶段
- 接收视频源 URL
- 开始获取配置过程

### 2. 配置获取流程
- 多级请求尝试（AllOrigins代理 -> CORS代理 -> 直接请求）
- 响应验证
- 配置解析

### 3. Spider配置处理
- 检查是否包含 Spider 配置
- 解析 JAR 文件信息
- 提取 MD5 校验值

### 4. 站点列表处理
- 验证站点列表存在
- 遍历处理每个站点
- 类型转换和标准化
- 处理 API 和扩展字段

### 5. 视频获取流程
- 根据类型分发到不同处理器
- API 类型直接请求
- Spider 类型需要额外处理
- WebPage 类型网页解析
- Live 类型直播源处理

### 6. Spider视频处理
- JAR 文件下载和缓存管理
- 规则解析
- 请求构建和发送
- 响应解析

### 7. 数据标准化
- 统一数据格式
- 字段映射和转换
- 返回标准化结果

### 8. 错误处理
- 各阶段错误捕获
- 错误信息标准化
- 错误恢复机制 

## TVBox配置解析流程

```mermaid
flowchart TD
    A[开始] --> B[获取TVBox配置URL]
    B --> C[调用TvboxService.fetchConfig]
    C --> D{HTTP请求是否成功?}
    D -->|是| E[解析JSON响应]
    D -->|否| F[抛出获取配置失败异常]
    E --> G[创建TvboxConfig对象]
    G --> H[解析站点列表sites]
    G --> I[解析解析器列表parses]
    H --> J[保存到数据库]
    I --> J
    J --> K[更新Provider状态]
    K --> L[结束]
    F --> L
```

## 数据源添加流程

```mermaid
flowchart TD
    A[开始] --> B{选择添加方式}
    B -->|默认配置| C[使用默认URL]
    B -->|自定义URL| D[输入新URL]
    C --> E[调用refreshSites]
    D --> F[调用updateFromUrl]
    E --> G[获取配置]
    F --> G
    G --> H{配置是否有效?}
    H -->|是| I[转换为数据库实体]
    H -->|否| J[显示错误信息]
    I --> K[保存到Isar数据库]
    K --> L[更新UI显示]
    J --> M[结束]
    L --> M
```

## 数据源列表管理流程

```mermaid
flowchart TD
    A[开始] --> B[加载数据源列表]
    B --> C{是否有数据源?}
    C -->|否| D[加载默认数据源]
    C -->|是| E[显示数据源列表]
    
    %% 数据源操作
    E --> F{用户操作}
    F -->|添加| G[添加新数据源]
    F -->|切换| H[切换数据源]
    F -->|删除| I[删除数据源]
    F -->|编辑| J[编辑数据源]
    
    %% 添加数据源流程
    G --> K{选择类型}
    K -->|默认| L[使用默认URL]
    K -->|自定义| M[输入URL]
    L --> N[验证并解析]
    M --> N
    N -->|成功| O[保存到数据库]
    N -->|失败| P[显示错误]
    
    %% 切换数据源流程
    H --> Q[更新当前数据源标记]
    Q --> R[重新加载视频源]
    
    %% 删除数据源流程
    I --> S{是否为当前源?}
    S -->|是| T[切换到默认源]
    S -->|否| U[直接删除]
    
    %% 编辑数据源流程
    J --> V[更新数据源信息]
    V --> W[刷新数据源列表]
    
    %% 结果处理
    O --> W
    T --> W
    U --> W
    R --> W
    P --> W
    W --> X[结束]
```

### 数据源管理数据结构

```mermaid
classDiagram
    class VideoSourceList {
        +List<VideoSource> sources
        +VideoSource? currentSource
        +DateTime lastUpdated
        +addSource(VideoSource)
        +removeSource(String)
        +switchSource(String)
        +updateSource(VideoSource)
    }
    
    class VideoSource {
        +String id
        +String name
        +String url
        +bool isDefault
        +bool isActive
        +DateTime createdAt
        +DateTime updatedAt
        +SourceType type
    }
    
    class VideoSourceEntity {
        +Id id
        +String name
        +String url
        +bool isDefault
        +bool isActive
        +DateTime createdAt
        +DateTime updatedAt
        +int type
    }
    
    VideoSourceList --> VideoSource : contains
    VideoSource --> VideoSourceEntity : maps to
```

### 数据源状态管理流程

```mermaid
flowchart TD
    A[VideoSourceListNotifier] --> B[build初始化]
    B --> C[加载所有数据源]
    C --> D{有活跃数据源?}
    D -->|否| E[设置默认源为活跃]
    D -->|是| F[加载活跃源配置]
    
    A --> G[addSource添加源]
    G --> H[保存到数据库]
    H --> I[更新状态]
    
    A --> J[removeSource删除源]
    J --> K{是活跃源?}
    K -->|是| L[切换到默认源]
    K -->|否| M[从数据库删除]
    L --> I
    M --> I
    
    A --> N[switchSource切换源]
    N --> O[更新活跃状态]
    O --> P[加载新源配置]
    P --> I
    
    I --> Q[通知UI更新]
```

## 数据源切换时序图

```mermaid
sequenceDiagram
    participant U as User
    participant VM as VideoSourceListNotifier
    participant DB as Database
    participant S as VideoSourceService
    
    U->>VM: 选择新数据源
    VM->>DB: 更新当前源状态
    VM->>S: 加载新源配置
    S->>DB: 保存新配置
    S-->>VM: 返回结果
    VM-->>U: 更新UI显示
```

## 数据结构

### TvboxConfig
```mermaid
classDiagram
    class TvboxConfig {
        +String spider
        +String wallpaper
        +List<TvboxSite> sites
        +List<TvboxParse> parses
    }
    class TvboxSite {
        +String key
        +String name
        +int type
        +String api
        +bool searchable
        +bool quickSearch
        +bool filterable
        +String? ext
        +int playerType
    }
    class TvboxParse {
        +String name
        +int type
        +String url
        +Map<String,dynamic>? ext
    }
    TvboxConfig --> TvboxSite : contains
    TvboxConfig --> TvboxParse : contains
```

### 数据库实体
```mermaid
classDiagram
    class TvboxSiteEntity {
        +Id id
        +String key
        +String name
        +int type
        +String api
        +bool searchable
        +bool quickSearch
        +bool filterable
        +String? ext
        +int playerType
        +DateTime updatedAt
    }
```

## 状态管理流程

```mermaid
flowchart TD
    A[TvboxSitesNotifier] --> B[build初始化]
    B --> C[加载数据库中的站点]
    A --> D[refreshSites刷新]
    D --> E[更新状态为loading]
    E --> F[获取新配置]
    F --> G[保存到数据库]
    G --> H[重新加载站点]
    H --> I[更新状态为data/error]
    A --> J[updateFromUrl更新]
    J --> K[更新状态为loading]
    K --> L[从URL获取配置]
    L --> M[保存到数据库]
    M --> N[重新加载站点]
    N --> O[更新状态为data/error]
``` 