# DeepSeek 海外邮箱登录启动器

GitHub Pages 静态站点：引导 macOS 用户通过 `applescript://` URL 直接在「脚本编辑器」中打开启动脚本（无需下载），将 `platform.deepseek.com` 指向 CloudFront 海外节点，从而在海外出口网络下显示**邮箱 / Google 登录**界面而非 +86 短信登录。

## 工作原理

1. `launcher.applescript` / `launcher.bat` 是脚本源：动态解析 CloudFront 当前 IP → 写入 hosts → 用系统默认浏览器打开登录页（保留用户已保存的登录态）。
2. `build.py` 把 AppleScript URL 编码为 `applescript://com.apple.scripteditor?action=new&script=...`，烘焙进 `site/index.html` 生成 `dist/index.html`，并把两个启动器文件拷入 `dist/` 供下载。
3. GitHub Actions（`.github/workflows/pages.yml`）在 push 到 `main` 时构建并部署到 GitHub Pages。

注意：`applescript://` 的 host **必须全小写** `com.apple.scripteditor`——Script Editor 对 host 做大小写敏感匹配，写成 Bundle ID 形式的 `com.apple.ScriptEditor2` 会打开空白文档。

## 本地开发

```sh
python3 build.py          # 生成 dist/index.html
python3 -m http.server -d dist 8000   # 本地预览 http://localhost:8000
```

## 首次部署设置

1. Push 本仓库到 GitHub 后，进入 **Settings → Pages → Source**，选择 **GitHub Actions**。
2. 触发一次 `Deploy to GitHub Pages` 工作流（push 到 main 或手动 Run workflow）。
3. 站点地址：`https://safumo.github.io/deepseek-email-login-launcher/`

## 使用条件

- **macOS**：Script Editor 为系统自带；任意浏览器可用——Safari 点按钮直启，其他浏览器下载 `launcher.applescript` 双击运行
- **Windows**：下载 `launcher.bat`，右键「以管理员身份运行」；脚本自动检测 Chrome / Edge / Firefox
- 网络能把到海外节点的流量送到**非中国大陆出口**（专线分流 / 海外代理 / 人在海外）
- 运行需管理员密码（修改 hosts 需要 root）

## 还原

macOS：

```sh
sudo sed -i '' '/platform.deepseek.com/d' /etc/hosts
```

Windows：用记事本（管理员）打开 `C:\Windows\System32\drivers\etc\hosts`，删除包含 `platform.deepseek.com` 的行。

## 局限性与风险

- CloudFront IP 可能更换，脚本每次运行会重新解析；已写入的旧 hosts 条目若失效会导致访问失败，需重新运行或移除。
- 写入 hosts 后**全系统**所有程序访问 platform.deepseek.com 都走海外出口，注意账号风控。
- 海外机房 IP（如 Zenlayer SG）偶尔被 AWS WAF 拦截，刷新重试即可。
