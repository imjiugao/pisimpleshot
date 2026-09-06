#!/usr/bin/env bash
# QuickShot 安装脚本：复制程序/图标/启动项，并立即启动托盘图标
set -e

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
ICON_SCAL="$HOME/.local/share/icons/hicolor/scalable/apps"
ICON_48="$HOME/.local/share/icons/hicolor/48x48/apps"
APP_DIR="$HOME/.local/share/applications"
AUTOSTART="$HOME/.config/autostart"

echo "==> 安装 QuickShot 快速截图"

# ---- 1. 依赖检查 ----
echo "==> 检查依赖"
NEED_APT=()
for dep in "python3:python3" "grim:grim" "slurp:slurp" "wl-copy:wl-clipboard"; do
    cmd="${dep%%:*}"; pkg="${dep##*:}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        NEED_APT+=("$pkg")
    fi
done
if ! python3 -c "import gi" >/dev/null 2>&1; then
    NEED_APT+=("python3-gi" "gir1.2-gtk-3.0")
fi

if [ ${#NEED_APT[@]} -gt 0 ]; then
    echo "    缺少依赖: ${NEED_APT[*]}"
    if command -v apt-get >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        echo "    尝试自动安装..."
        sudo apt-get install -y "${NEED_APT[@]}" || true
    else
        echo "    ⚠ 请手动安装: sudo apt-get install -y ${NEED_APT[*]}"
        echo "      （缺少 grim/slurp 时无法截图，缺少 python3-gi 时程序无法运行）"
    fi
else
    echo "    依赖齐全"
fi

# ---- 2. 复制文件 ----
echo "==> 复制程序与图标"
mkdir -p "$BIN" "$ICON_SCAL" "$ICON_48" "$APP_DIR" "$AUTOSTART"
install -m 755 "$SRC_DIR/src/quickshot" "$BIN/quickshot"
install -m 644 "$SRC_DIR/icons/quickshot.svg" "$ICON_SCAL/quickshot.svg"
install -m 644 "$SRC_DIR/icons/quickshot.png" "$ICON_48/quickshot.png"

# ---- 3. 生成桌面入口与自启动 ----
echo "==> 生成桌面入口与开机自启动"
for target in "$APP_DIR/quickshot.desktop" "$AUTOSTART/quickshot.desktop"; do
    cat > "$target" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=QuickShot 快速截图
GenericName=Screenshot Tool
Comment=在面板右上角托盘显示快速截图图标
Exec=$BIN/quickshot
TryExec=$BIN/quickshot
Terminal=false
Categories=Utility;
Icon=quickshot
X-GNOME-Autostart-enabled=true
EOF
done

# ---- 4. 重启托盘程序 ----
echo "==> 启动托盘图标"
pkill -f "/.local/bin/quickshot" 2>/dev/null && sleep 1 || true

# 若当前 shell 没有 Wayland 环境变量，尝试自动探测
if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
    for w in "$XDG_RUNTIME_DIR"/wayland-*; do
        [ -S "$w" ] && WAYLAND_DISPLAY="${w##*/}"
    done
fi

if [ -n "$WAYLAND_DISPLAY" ]; then
    (setsid nohup "$BIN/quickshot" >/dev/null 2>&1 &)
    sleep 2
    if pgrep -f "/.local/bin/quickshot" >/dev/null; then
        echo "✔ 安装完成，托盘图标已启动（右上角相机图标）"
    else
        echo "⚠ 程序已安装但启动失败，请重新登录桌面或手动运行: $BIN/quickshot"
        exit 1
    fi
else
    echo "✔ 安装完成。当前未检测到图形会话，下次登录桌面时自动启动。"
fi
