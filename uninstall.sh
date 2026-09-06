#!/usr/bin/env bash
# QuickShot 卸载脚本：停止程序并删除所有安装的文件
# 注意：截图文件保存在 ~/Pictures/Screenshots，卸载不会删除它们
set -e

echo "==> 卸载 QuickShot 快速截图"

echo "==> 停止正在运行的托盘程序"
pkill -f "/.local/bin/quickshot" 2>/dev/null && echo "    已停止" || echo "    未在运行"

echo "==> 删除程序与图标"
rm -fv "$HOME/.local/bin/quickshot"
rm -fv "$HOME/.local/share/icons/hicolor/scalable/apps/quickshot.svg"
rm -fv "$HOME/.local/share/icons/hicolor/48x48/apps/quickshot.png"
rm -fv "$HOME/.local/share/icons/hicolor/scalable/apps/quickshot-success.svg"
rm -fv "$HOME/.local/share/icons/hicolor/48x48/apps/quickshot-success.png"

echo "==> 删除桌面入口与自启动项"
rm -fv "$HOME/.local/share/applications/quickshot.desktop"
rm -fv "$HOME/.config/autostart/quickshot.desktop"

echo "✔ 卸载完成"
echo "  （历史截图仍保留在 ~/Pictures/Screenshots/，如不需要请手动删除）"
