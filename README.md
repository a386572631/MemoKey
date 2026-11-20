# MemoKey

用鼠标操作时，在屏幕中央弹出该操作对应的键盘快捷键，帮你通过反复暴露记住快捷键。

## 行为

- 点击菜单栏菜单项、右键上下文菜单项：反查该菜单项绑定的快捷键并显示，例如点击「编辑 > 复制」显示 `⌘ + C`。
- 没有快捷键等价物的动作（点击 Dock 图标、双击文件、普通按钮）：**不显示任何内容**。
- 正常使用键盘：**不显示任何内容**。
- 悬浮窗无焦点、鼠标穿透、覆盖全屏应用，在当前鼠标所在屏幕居中显示，约 0.6 秒内放大淡出。

## 系统要求

macOS 14 及以上，需授予两项权限：

| 权限 | 用途 |
|------|------|
| 输入监控（Input Monitoring） | 捕获全局鼠标点击事件 |
| 辅助功能（Accessibility） | 读取被点击菜单项绑定的快捷键 |

授权路径：**系统设置 > 隐私与安全性 > 输入监控 / 辅助功能**，勾选 MemoKey。

首次启动会弹出引导弹窗；菜单栏图标菜单中也会实时显示两项权限状态，点击可跳转对应设置页。授权后选择「重新启动监听」；若仍无效，请退出并重新打开应用。

## 使用

菜单栏键盘图标菜单包含：

- 输入监控 / 辅助功能状态（点击跳转系统设置）
- 重新启动监听
- 预览提示样式（显示一个示例 `⌘ + C`）
- 退出 MemoKey

## 构建

```bash
xcodebuild -project MemoKey.xcodeproj -scheme MemoKey -configuration Debug \
  -derivedDataPath build/DerivedData build
open build/DerivedData/Build/Products/Debug/MemoKey.app
```

产物路径：

```
build/DerivedData/Build/Products/Debug/MemoKey.app
```

## 已知限制

- 登录/锁屏界面无法监听。
- 第三方 App 的自绘菜单、非标准控件读不到菜单项快捷键时，该次点击静默忽略。
- 权限与代码签名绑定。Debug 构建每次重签名后，可能需要在系统设置中重新授权。
- 事件监听为 `listenOnly`，不拦截、不修改任何用户输入。
