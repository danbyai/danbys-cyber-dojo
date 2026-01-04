# 🛠️ Setup Guide – Danby's Cyber Dojo

This guide explains how to install and configure **Danby's Cyber Dojo** for Purple Team training.

**Phase 2.3** includes HTTP/HTTPS dual-protocol testing, TLS/SSL validation, and security header analysis.

---

## 📦 Requirements

### Supported Systems
- **Linux** (tested on Kali Purple, Ubuntu Server)
- Bash shell
- sudo access (for nmap scans)

### Required Packages
```bash
sudo apt update
sudo apt install -y \
  git \
  curl \
  openssl \
  nmap \
  nikto \
  netcat
```

**Package purposes:**
- `curl` - HTTP/HTTPS header analysis
- `openssl` - TLS/SSL certificate inspection
- `nmap` - Service detection, TLS cipher enumeration
- `nikto` - Web vulnerability scanning
- `netcat` - Banner grabbing

---

## 📥 Clone the Repository

```bash
git clone https://github.com/danbyai/danbys-cyber-dojo.git
cd danbys-cyber-dojo
```

---

## ⚙️ One-Step Setup (Recommended)

Run the interactive setup wizard:

```bash
chmod +x setup_dojo.sh
./setup_dojo.sh
```

**The wizard will ask:**
1. Target host IP (e.g., `10.0.10.20`)
2. Target username (e.g., `ubuntu`)
3. SSH port (default: `22`)
4. Local dojo home folder (default: `$HOME/cyber_dojo`)
5. SSH key path (default: `$HOME/.ssh/dojo_admin`)
6. HTTP port (default: `80`)
7. HTTPS port (default: `443`)

**Output:**
- `~/.dojo_config.sh` - Your personalized configuration
- Directory structure under `~/cyber_dojo/`

---

## 🔧 Manual Configuration (Advanced)

If you prefer manual setup:

```bash
# Copy template
cp dojo_config.sh ~/.dojo_config.sh

# Edit configuration
nano ~/.dojo_config.sh

# Update these values:
# export DOJO_TARGET_HOST="10.0.10.20"
# export DOJO_TARGET_USER="ubuntu"
# export DOJO_HTTP_PORT="80"
# export DOJO_HTTPS_PORT="443"

# Create directories
mkdir -p ~/cyber_dojo/{scripts,baselines,captures,logs,daily_diff,sessions}

# Load configuration
source ~/.dojo_config.sh
```

---

## 🧪 Test Your Configuration

### 1. Load Configuration
```bash
source ~/.dojo_config.sh
```

### 2. Test SSH Connection
```bash
ssh $DOJO_TARGET_USER@$DOJO_TARGET_HOST
```

If using SSH keys:
```bash
ssh -i $DOJO_KEY_ADMIN $DOJO_TARGET_USER@$DOJO_TARGET_HOST
```

### 3. Verify Environment Variables
```bash
echo "Target: $DOJO_TARGET_HOST"
echo "User: $DOJO_TARGET_USER"
echo "HTTP: $DOJO_HTTP_PORT"
echo "HTTPS: $DOJO_HTTPS_PORT"
echo "Dojo Home: $DOJO_HOME"
```

---

## 📸 Baseline Capture (Phase 2.3)

### Running Your First Scan

```bash
# Make script executable
chmod +x baseline_capture.sh

# Run baseline capture (before hardening)
./baseline_capture.sh baseline
```

**This executes 16 scans:**

**Part 1 - HTTP (Port 80):**
1. Banner grab (netcat)
2. HTTP headers (curl)
3. Full response with HTML
4. 404 error page test
5. HTTP methods (OPTIONS)

**Part 2 - HTTPS/TLS (Port 443):**
6. HTTPS headers
7. HTTPS HTML body (CSS detection)
8. HTTP → HTTPS redirect validation
9. HSTS header check
10. HTTP/2 protocol validation
11. SSL certificate details

**Part 3 - Vulnerability Scans:**
12. Nikto HTTP scan
13. Nikto HTTPS scan

**Part 4 - Privileged Scans (sudo required):**
14. Nmap HTTP service detection
15. Nmap HTTPS service detection
16. TLS cipher enumeration

### Evidence Storage

**Working Directory:**
- `baseline_*.txt` - Current scan results

**Archived Evidence:**
- `~/cyber_dojo/baselines/nginx/baseline_*_TIMESTAMP.txt`

**Categorized Captures:**
- `~/cyber_dojo/captures/curl/` - HTTP requests
- `~/cyber_dojo/captures/tls/` - HTTPS/SSL data
- `~/cyber_dojo/captures/nmap/` - Service scans

---

## 🔒 Phase 2.3 Workflow

### Complete Purple Team Cycle

**1. Capture BEFORE State:**
```bash
./baseline_capture.sh baseline
```

**2. Harden Target Server:**
```bash
# On target Ubuntu server:
sudo ./ubuntu_https_server_setup.sh
# (This script available in scripts/ directory)
```

**What hardening does:**
- Installs nginx with HTTPS
- Generates self-signed SSL certificate
- Configures HTTP → HTTPS redirect
- Adds security headers (HSTS, CSP, X-Frame-Options, etc)
- Separates inline CSS to external file
- Configures UFW firewall

**3. Capture AFTER State:**
```bash
./baseline_capture.sh hardened
```

**4. Compare Evidence:**
```bash
# Compare baseline vs hardened scans
diff baseline_nikto_https.txt hardened_nikto_https.txt
diff baseline_https_headers.txt hardened_https_headers.txt
```

---

## 📊 Reading Scan Results

### HTTP Headers (baseline_headers.txt)
```
HTTP/1.1 200 OK
Server: nginx/1.18.0
Content-Type: text/html
```
**Look for:** Server version, content type, missing security headers

### HTTPS Headers (baseline_https_headers.txt)
```
HTTP/2 200
strict-transport-security: max-age=31536000; includeSubDomains
x-frame-options: SAMEORIGIN
x-content-type-options: nosniff
```
**Look for:** HSTS, security headers, HTTP/2 support

### HSTS Header (baseline_hsts_header.txt)
```
strict-transport-security: max-age=31536000; includeSubDomains
```
**Absence = "HSTS not found"** - Server not enforcing HTTPS

### Nikto Results (baseline_nikto_https.txt)
```
+ Server: nginx/1.18.0 (Ubuntu)
+ The anti-clickjacking X-Frame-Options header is not present.
+ The X-Content-Type-Options header is not set.
```
**Compare BEFORE vs AFTER** to validate hardening improvements

---

## 🔐 Security Best Practices

### SSH Key Setup (Recommended)

```bash
# Generate admin key
ssh-keygen -t ed25519 -f ~/.ssh/dojo_admin -C "dojo-admin"

# Copy to target
ssh-copy-id -i ~/.ssh/dojo_admin.pub ubuntu@10.0.10.20

# Test connection
ssh -i ~/.ssh/dojo_admin ubuntu@10.0.10.20
```

### Firewall Configuration

**On target Ubuntu server:**
```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

---

## 🛡️ Privacy & Security

**This repository contains NO sensitive data:**
- ❌ No API keys or tokens
- ❌ No session logs or chat histories
- ❌ No network captures with real IPs
- ❌ No credentials or secrets
- ✅ All sensitive paths excluded via `.gitignore`

**Configuration file `~/.dojo_config.sh` is NEVER committed to Git.**

---

## ⚠️ Legal Disclaimer

**For authorized testing ONLY.**

- Only test systems you own or have explicit permission to test
- Never run scans against production systems without authorization
- Nikto and nmap can be intrusive - use responsibly
- Lab environment recommended (Kali + Ubuntu VM)

---

## 🆘 Troubleshooting

### "Configuration not found"
```bash
# Check if config exists
ls -la ~/.dojo_config.sh

# If missing, run setup again
./setup_dojo.sh
```

### "Permission denied" errors
```bash
# Make scripts executable
chmod +x setup_dojo.sh baseline_capture.sh

# Check SSH key permissions
chmod 600 ~/.ssh/dojo_admin
```

### "curl: command not found"
```bash
# Install missing tools
sudo apt install curl openssl nmap nikto netcat
```

### Nmap scans fail
```bash
# Nmap requires sudo
sudo nmap -sV -p 443 10.0.10.20

# Or run entire baseline with sudo context
sudo ./baseline_capture.sh baseline
```

### Self-signed certificate warnings
```bash
# Expected behavior for lab testing
# curl uses -k flag to accept self-signed certs
# This is defined in DOJO_CURL_OPTS
```

---

## 📁 Directory Structure

After setup completion:

```
~/cyber_dojo/
├── scripts/           # Automation scripts
├── baselines/         # Archived evidence (timestamped)
│   └── nginx/
├── captures/          # Categorized scan results
│   ├── curl/
│   ├── tls/
│   └── nmap/
├── logs/              # Runtime logs
├── daily_diff/        # Diff analysis reports
└── sessions/          # Session metadata
```

---

## 📚 Next Steps

1. **Run baseline capture** - Establish BEFORE state
2. **Harden target** - Implement HTTPS and security headers
3. **Run second capture** - Establish AFTER state
4. **Compare evidence** - Validate security improvements
5. **(Coming Soon)** Diff Report Professor - AI-powered analysis

---

## 🧠 Philosophy

> **Capture first.**  
> **Understand second.**  
> **Automate third.**  
> **Teach last.**

These scripts form the **foundation** for AI-powered Purple Team coaching agents.

---

## 🙋 Getting Help

**Found a bug?** Open an issue on GitHub  
**Have a question?** Check existing documentation  
**Want to contribute?** This is a personal training project, but feedback is welcome

---

**Train hard. Build skills. Stay curious.** 🥋🔥
