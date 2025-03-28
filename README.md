# LifeTV

一个基于 Flutter 开发的视频聚合应用，支持多种视频源和播放格式。

## 功能特点

- 支持多种视频源格式 (API、Spider、Web Page、Live)
- 自动解析视频源配置
- 支持 JAR 文件解析
- 支持分类浏览
- 响应式界面设计
- 跨平台支持 (Android、iOS、Web)

## 技术栈

- Flutter
- Riverpod (状态管理)
- Freezed (数据模型)
- Flutter Hooks
- HTTP (网络请求)

## 开始使用

1. 确保已安装 Flutter 开发环境
2. 克隆项目
```bash
git clone https://github.com/yourusername/lifetv.git
```
3. 安装依赖
```bash
flutter pub get
```
4. 运行项目
```bash
flutter run
```

## 配置说明

默认视频源: `http://pandown.pro/tvbox/tvbox.json`

支持的视频源类型:
- API 类型
- Spider 类型 (支持 JAR 文件)
- Web Page 类型
- Live 直播类型

## 贡献指南

欢迎提交 Pull Request 或提出 Issue。

## 许可证

MIT License
