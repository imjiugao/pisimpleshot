# PisimpleShot — 树莓派托盘快速截图

在树莓派 OS（labwc / wf-panel-pi 桌面）屏幕右上角的面板托盘中常驻一个相机图标，
一键快速截图。

## 功能

| 操作 | 效果 |
|---|---|
| **左键单击**托盘图标 | 立即全屏截图：保存到 `~/Pictures/Screenshots/` 并自动复制到剪贴板 |
| **右键单击**托盘图标 | 菜单：全屏截图 / 区域截图…（拖框选取，Esc 取消）/ 3 秒后全屏截图 / 打开截图文件夹 / 退出 |
| **中键单击**托盘图标 | 快捷触发“区域截图” |

每次截图成功后给出不打扰操作的提示：**托盘图标短暂变成绿勾样式（3 秒），
鼠标悬停图标可查看保存路径**——不弹窗、不抢焦点、不出现在任务栏。

## 配置文件

配置文件位于 `~/.config/PisimpleShot/config.ini`，首次运行时自动生成：

```ini
[PisimpleShot]
# 截图成功后的提示方式：
#   icon   = 托盘图标短暂变绿勾并更新悬停提示（默认，不打扰操作）
#   window = 弹出提示窗口（会抢焦点，4 秒后自动消失）
#   none   = 不提示
# 修改保存后立即生效，无需重启程序
feedback = icon
```

| 配置项 | 可选值 | 说明 |
|---|---|---|
| `feedback` | `icon`（默认） | 截图成功后托盘图标变绿勾 3 秒，悬停显示保存路径 |
| | `window` | 旧式弹窗提示（会抢焦点） |
| | `none` | 不提示 |

- 修改保存后**立即生效**，无需重启程序
- 截图失败的报错弹窗不受此设置影响，始终显示
- 旧配置项 `show_popup`（true/false）仍被兼容：`false` 等效于 `none`

## 安装

```bash
cd PisimpleShot
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

- 主菜单 → 附件 → **PisimpleShot 快速截图**
- 或终端执行：`~/.local/bin/PisimpleShot &`

程序有单实例保护：重复启动不会出现两个图标。

## 文件清单

```
PisimpleShot/
├── install.sh              # 安装脚本
├── uninstall.sh            # 卸载脚本
├── src/PisimpleShot           # 主程序（Python 3 + PyGObject，单文件）
└── icons/
    ├── PisimpleShot.svg       # 托盘/应用图标（矢量）
    ├── PisimpleShot.png       # 48px 位图（托盘像素图标源）
    ├── PisimpleShot-success.svg  # 截图成功提示图标（绿勾，矢量）
    └── PisimpleShot-success.png  # 成功提示图标 48px 位图
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
