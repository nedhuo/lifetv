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