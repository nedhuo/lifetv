import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'LifeTV';
  static const String appVersion = '1.0.0';
  
  // API 配置
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  
  // 缓存配置
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration maxCacheAge = Duration(days: 7);
  
  // UI 配置
  static const double defaultPadding = 16.0;
  static const double gridSpacing = 10.0;
  static const int gridCrossAxisCount = 4;
  
  // 播放器配置
  static const Duration seekDuration = Duration(seconds: 10);
  static const Duration autoHideControlsDelay = Duration(seconds: 3);
  
  // 主题配置
  static const MaterialColor primarySwatch = Colors.blue;
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF03A9F4);
  static const Color backgroundColor = Color(0xFF121212);
  
  // 动画配置
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // 错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String serverErrorMessage = '服务器错误，请稍后重试';
  static const String unknownErrorMessage = '发生未知错误，请重试';
  
  // 本地存储键
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String sourceKey = 'video_sources';
  static const String historyKey = 'watch_history';
  static const String favoritesKey = 'favorites';
}