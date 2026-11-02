-- DeepSeek 平台海外邮箱登录启动器（Safari 路线）
-- 原理：把 platform.deepseek.com 指向 CloudFront 海外节点，专线按目的 IP 分流走海外出口，
--       边缘注入非 CN region → 显示邮箱 / Google 登录
-- 移除：sudo sed -i '' '/platform.deepseek.com/d' /etc/hosts

set targetURL to "https://platform.deepseek.com/sign_in"
set safariApp to "/Applications/Safari.app"

-- 动态获取 CloudFront 当前 IP（dig 走海外 DNS；专线外网络失败则用已知可用 IP 兜底）
set cfIP to do shell script "dig +short +time=3 +tries=2 platform.deepseek.com @1.1.1.1 | grep -E '^[0-9.]+$' | head -1"
if cfIP is "" then set cfIP to "3.173.21.63"

display dialog "将为 Safari 写入 /etc/hosts（需要管理员密码，全系统生效）：" & return & return & cfIP & " platform.deepseek.com" & return & return & "测试完可用 " & quoted form of "sudo sed -i '' '/platform.deepseek.com/d' /etc/hosts" & " 移除。" buttons {"取消", "写入并打开 Safari"} default button 2 cancel button 1

do shell script "grep -v 'platform.deepseek.com' /etc/hosts > /tmp/hosts.tmp 2>/dev/null; echo '" & cfIP & " platform.deepseek.com' >> /tmp/hosts.tmp; cat /tmp/hosts.tmp > /etc/hosts; rm /tmp/hosts.tmp; dscacheutil -flushcache; killall -HUP mDNSResponder 2>/dev/null; true" with administrator privileges

do shell script "open -a " & quoted form of safariApp & " " & quoted form of targetURL
