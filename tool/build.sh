#!/bin/bash

# 清理旧的生成文件
flutter pub run build_runner clean

# 生成新的文件
flutter pub run build_runner build --delete-conflicting-outputs