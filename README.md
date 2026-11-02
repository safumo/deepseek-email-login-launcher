# DeepSeek 海外邮箱登录启动器

GitHub Pages 静态站点：引导 macOS 用户通过 `applescript://` URL 直接在「脚本编辑器」中打开启动脚本（无需下载），将 `platform.deepseek.com` 指向 CloudFront 海外节点，从而在海外出口网络下显示**邮箱 / Google 登录**界面而非 +86 短信登录。

## 工作原理

1. `launcher.applescript` 是本仓库唯一的脚本源：动态解析 CloudFront 当前 IP → 写入 `/etc/hosts` → 打开 Safari 登录页。
2. `build.py` 把脚本 URL 编码为 `applescript://com.apple.ScriptEditor2?action=new&script=...`，烘焙进 `site/index.html` 生成 `dist/index.html`。
3. GitHub Actions（`.github/workflows/pages.yml`）在 push 到 `main` 时构建并部署到 GitHub Pages。

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

- macOS（Script Editor 为系统自带）
- 网络能把到海外节点的流量送到**非中国大陆出口**（专线分流 / 海外代理 / 人在海外）
- 运行脚本需输入管理员密码（修改 `/etc/hosts` 需要 root）

## 还原

```sh
sudo sed -i '' '/platform.deepseek.com/d' /etc/hosts
```

## 局限性与风险

- CloudFront IP 可能更换，脚本每次运行会重新解析；已写入的旧 hosts 条目若失效会导致访问失败，需重新运行或移除。
- 写入 hosts 后**全系统**所有程序访问 platform.deepseek.com 都走海外出口，注意账号风控。
- 海外机房 IP（如 Zenlayer SG）偶尔被 AWS WAF 拦截，刷新重试即可。
