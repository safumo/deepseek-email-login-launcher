# DeepSeek Email Login Launcher

A GitHub Pages static site that guides macOS and Windows users to point `platform.deepseek.com` at a CloudFront overseas edge IP, so the sign-in page shows the **email / Google login** form instead of the +86 SMS form when the network has a non-mainland-China exit.

## How it works

1. `launcher.applescript` / `launcher.bat` are the launcher sources: they resolve the current CloudFront IP, write it to the hosts file, and open the sign-in page in the system default browser (keeping the user's saved sessions and passwords).
2. `build.py` URL-encodes the AppleScript into an `applescript://com.apple.scripteditor?action=new&script=...` URL, bakes it into `site/index.html` to produce `dist/index.html`, and copies both launcher files into `dist/` for download.
3. GitHub Actions (`.github/workflows/pages.yml`) builds and deploys to GitHub Pages on every push to `main`.

Note: the `applescript://` host **must be all lowercase** `com.apple.scripteditor` — Script Editor matches the host case-sensitively, and the Bundle ID form `com.apple.ScriptEditor2` opens a blank document.

## Local development

```sh
python3 build.py                        # generate dist/index.html
python3 -m http.server -d dist 8000     # preview at http://localhost:8000
```

## First-time deployment

1. After pushing this repo to GitHub, go to **Settings → Pages → Source** and choose **GitHub Actions**.
2. Trigger a `Deploy to GitHub Pages` run (push to main, or run the workflow manually).
3. Site URL: `https://safumo.github.io/deepseek-email-login-launcher/`

## Requirements

- **macOS**: Script Editor is built in; any browser works — Safari gets the one-click `applescript://` button, other browsers download `launcher.applescript` and double-click it
- **Windows**: download `launcher.bat`, right-click → **Run as administrator**; the script detects Chrome / Edge / Firefox
- Your network must route traffic to the overseas edge through a **non-mainland-China exit** (dedicated line split tunneling, an overseas proxy, or simply being abroad)
- Running the launcher requires an administrator password (root is needed to modify hosts)

## Revert

macOS:

```sh
sudo sed -i '' '/platform.deepseek.com/d' /etc/hosts
```

Windows: open `C:\Windows\System32\drivers\etc\hosts` in Notepad (as administrator) and delete the line containing `platform.deepseek.com`.

## Limitations and risks

- The CloudFront IP can change; the launcher re-resolves it on every run. A stale hosts entry will break access — re-run the launcher or revert.
- Once written, the hosts entry applies **system-wide**: every program reaching platform.deepseek.com goes through the overseas exit. Mind account risk controls.
- Overseas datacenter IPs (e.g. Zenlayer SG) are occasionally blocked by AWS WAF — just refresh and retry.
