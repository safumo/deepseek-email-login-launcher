-- DeepSeek overseas email-login launcher (macOS).
-- Principle: point platform.deepseek.com at a CloudFront edge IP; with traffic
-- routed through a non-CN exit, the edge serves the email / Google sign-in
-- form instead of the +86 SMS one.
-- Revert: sudo sed -i '' '/platform.deepseek.com/d' /etc/hosts

set targetURL to "https://platform.deepseek.com/sign_in"

-- Resolve the current CloudFront IP via overseas DNS; fall back to a known IP
set cfIP to do shell script "dig +short +time=3 +tries=2 platform.deepseek.com @1.1.1.1 | grep -E '^[0-9.]+$' | head -1"
if cfIP is "" then set cfIP to "3.173.21.63"

display dialog "This will write to /etc/hosts for your default browser (requires your administrator password, applies system-wide):" & return & return & cfIP & " platform.deepseek.com" & return & return & "To remove it afterwards, run: " & quoted form of "sudo sed -i '' '/platform.deepseek.com/d' /etc/hosts" buttons {"Cancel", "Write & Open Browser"} default button 2 cancel button 1

-- Rewrite hosts without stale entries, then flush the DNS cache
do shell script "grep -v 'platform.deepseek.com' /etc/hosts > /tmp/hosts.tmp 2>/dev/null; echo '" & cfIP & " platform.deepseek.com' >> /tmp/hosts.tmp; cat /tmp/hosts.tmp > /etc/hosts; rm /tmp/hosts.tmp; dscacheutil -flushcache; killall -HUP mDNSResponder 2>/dev/null; true" with administrator privileges

-- Open in the default browser to keep the user's saved sessions/passwords
do shell script "open " & quoted form of targetURL
