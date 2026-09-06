# QuickShot — 树莓派托盘快速截图

在树莓派 OS（labwc / wf-panel-pi 桌面）屏幕右上角的面板托盘中常驻一个相机图标，
一键快速截图。

## 功能

| 操作 | 效果 |
|---|---|
| **左键单击**托盘图标 | 立即全屏截图：保存到 `~/Pictures/Screenshots/` 并自动复制到剪贴板 |
| **右键单击**托盘图标 | 菜单：全屏截图 / 区域截图…（拖框选取，Esc 取消）/ 3 秒后全屏截图 / 打开截图文件夹 / 退出 |
| **中键单击**托盘图标 | 快捷触发“区域截图” |

每次截图后会弹出一个提示小窗（显示保存路径，4 秒自动消失）。

## 安装

```bash
cd quickshot
./install.sh
```

脚本会：检查并提示缺失的依赖 → 复制程序与图标到 `~/.local` →
生成应用菜单入口和开机自启动项 → 立即启动托盘图标。

安装后**每次开机自动启动**，无需手动操作。

## 卸载

```bash
./uninstall.sh
```

删除程序、图标、菜单入口和自启动项。历史截图（`~/Pictures/Screenshots/`）保留不删。

## 手动启动 / 退出后再次启动

- 主菜单 → 附件 → **QuickShot 快速截图**
- 或终端执行：`~/.local/bin/quickshot &`

程序有单实例保护：重复启动不会出现两个图标。

## 文件清单

```
quickshot/
├── install.sh              # 安装脚本
├── uninstall.sh            # 卸载脚本
├── src/quickshot           # 主程序（Python 3 + PyGObject，单文件）
└── icons/
    ├── quickshot.svg       # 托盘/应用图标（矢量）
    └── quickshot.png       # 48px 位图（托盘像素图标源）
```

## 依赖

树莓派 OS 桌面版默认已全部自带：

| 依赖 | 用途 | 缺失时 |
|---|---|---|
| `python3-gi` / GTK3 | 程序本体 | 无法运行（必需） |
| `grim` | Wayland 截图 | 无法截图（必需） |
| `slurp` | 区域选择 | 区域截图不可用 |
| `wl-clipboard` | 自动复制到剪贴板 | 仅失去复制功能 |
| `pcmanfm` | “打开截图文件夹” | 仅失去该菜单项 |

## 实现说明

树莓派 OS Bookworm+ 的面板（wf-panel-pi）通过 org.kde.StatusNotifierItem
协议显示托盘图标。本程序用 PyGObject/Gio 直接导出该接口：

- 图标以原始像素（IconPixmap）方式提供，避免面板主题缓存导致图标不显示；
- 右键菜单通过 com.canonical.dbusmenu 提供，布局节点采用 `(ia{sv}av)`
  格式（children 为变体数组），方法应答均封装为元组——这两点是与
  libdbusmenu 客户端互通的关键；
- 退出/卸载后重启面板或重新登录即可彻底清除痕迹。
