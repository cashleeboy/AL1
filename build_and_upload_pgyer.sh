#!/bin/bash

set -e
set -o pipefail

############################
# 自动识别项目
############################

# 找到第一个 xcodeproj（只列出目录本身，不列出其内容）
PROJECT_PATH=$(ls -d *.xcodeproj | head -n 1)

if [ -z "$PROJECT_PATH" ]; then
  echo "❌ No .xcodeproj found in current directory"
  exit 1
fi

# 去掉 .xcodeproj 后缀作为项目名
PROJECT_NAME=$(basename "$PROJECT_PATH" .xcodeproj)

echo "📦 Project: $PROJECT_NAME"
echo "📁 Project Path: $PROJECT_PATH"

############################
# 自动获取 Scheme（Shared）
############################

# 先获取原始 JSON 输出
XCODE_LIST_JSON=$(xcodebuild -list -json -project "$PROJECT_PATH" || echo "")

if [ -z "$XCODE_LIST_JSON" ]; then
  echo "❌ Failed to run xcodebuild -list. Check your Xcode select path."
  exit 1
fi

SCHEME_NAME=$(
  echo "$XCODE_LIST_JSON" \
  | python3 -c 'import json, sys; d = json.load(sys.stdin); s = d.get("project", {}).get("schemes", []); print(s[0] if s else "")'
)
echo "🧩 Scheme: $SCHEME_NAME"

############################
# 构建配置
############################

CONFIGURATION="Release"
BUILD_DIR="./build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/ipa"
EXPORT_OPTIONS_PLIST="./exportOptions.plist"

############################
# 蒲公英配置
############################

PGY_API_KEY="a53ab9b47c4622ae47bfdf8479c34ed1"
PGY_USER_KEY="fdfe96aadd0e98676dc28ff2ea74e2bf"

############################
# 1. 修改 Build 号 (核心新增)
############################
echo "🔢 Updating Build Number..."
# 使用时间戳确保唯一性
NEW_BUILD_NUMBER=$(date +"%Y%m%d%H%M")
# 更新项目中所有 Target 的 CFBundleVersion
xcrun agvtool new-version -all "$NEW_BUILD_NUMBER"
echo "✅ Build Number set to: $NEW_BUILD_NUMBER"

############################
# 清理旧文件
############################

echo "🧹 Clean build folder..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

############################
# Clean
############################

echo "🧹 Xcode clean..."
xcodebuild clean \
-project "$PROJECT_PATH" \
-scheme "$SCHEME_NAME" \
-configuration "$CONFIGURATION"

############################
# Archive
############################

echo "📦 Archiving..."
xcodebuild archive \
-project "$PROJECT_PATH" \
-scheme "$SCHEME_NAME" \
-configuration "$CONFIGURATION" \
-sdk iphoneos \
-destination "generic/platform=iOS" \
-archivePath "$ARCHIVE_PATH" \
-allowProvisioningUpdates \
-verbose

############################
# Export IPA
############################

echo "📤 Exporting IPA..."
xcodebuild -exportArchive \
-archivePath "$ARCHIVE_PATH" \
-exportPath "$EXPORT_PATH" \
-exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
-allowProvisioningUpdates \
-verbose

############################
# 找 IPA
############################

IPA_PATH=$(find "$EXPORT_PATH" -name "*.ipa" | head -n 1)

if [ ! -f "$IPA_PATH" ]; then
  echo "❌ IPA not found"
  exit 1
fi

echo "✅ IPA generated: $IPA_PATH"

############################
# 上传蒲公英
############################

echo "🚀 Uploading to Pgyer..."

# 上传并保存返回 JSON
RESPONSE=$(curl -s -F "file=@${IPA_PATH}" \
     -F "uKey=${PGY_USER_KEY}" \
     -F "_api_key=${PGY_API_KEY}" \
     https://www.pgyer.com/apiv2/app/upload)

# 输出完整返回，便于调试
echo "🎉 Upload finished!"
echo "🔹 Pgyer response: $RESPONSE"

# 解析短链接（buildShortcutUrl）
DOWNLOAD_URL=$(echo "$RESPONSE" | python3 -c 'import sys, json; print(json.load(sys.stdin)["data"]["buildShortcutUrl"])' 2>/dev/null)

if [ -n "$DOWNLOAD_URL" ]; then
  echo "🎉 Upload finished! Download URL: https://www.pgyer.com/$DOWNLOAD_URL"
else
  echo "⚠️ Upload may have failed or response format changed."
fi
