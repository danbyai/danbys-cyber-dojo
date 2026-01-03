# 🛠️ Setup Guide — Danby’s Cyber Dojo

This guide explains how to install and run the **public Cyber Dojo scripts**.

These scripts form the **foundation** of future AI agents by capturing, logging, and diffing security state in a clean, reproducible way.

No hardcoded IPs.
No personal paths.
No secrets committed.

---

## 📦 Requirements

### Supported Systems

* Linux (tested on **Kali Linux** and **Ubuntu Server**)
* Bash shell
* sudo access (for scans)

### Required Packages

```bash
sudo apt update
sudo apt install -y \
  git \
  curl \
  openssl \
  nmap \
  nikto
```

> `nmap` and `nikto` are only required for baseline capture and diffing.

---

## 📥 Clone the Repository

```bash
git clone https://github.com/danbyai/danbys-cyber-dojo.git
cd danbys-cyber-dojo
```

---

## ⚙️ One-Step Setup (Recommended)

Run the setup script from the repo root:

```bash
bash setup_dojo.sh
```

This script will:

* Generate a local configuration file
* Ask for your target host and SSH user
* Create required directories
* Prepare the environment for captures

Nothing is committed to Git.

---

## 🧩 Configuration (Auto-Generated)

The setup script creates:

```
.dojo_config.sh
```

This file controls:

* Target host / IP
* SSH user
* Log directories
* Capture output paths

Example contents:

```bash
TARGET_HOST="10.0.0.10"
SSH_USER="danby"
LOG_ROOT="$HOME/cyber_dojo/logs"
CAPTURE_ROOT="$HOME/cyber_dojo/captures"
```

⚠️ **Never commit this file**
It is already protected by `.gitignore`.

To load it manually later:

```bash
source .dojo_config.sh
```

---

## 📁 Runtime Directories (Auto-Created)

You do **not** need to create these yourself.

```
~/cyber_dojo/
├── logs/
│   ├── baseline/
│   └── diff/
└── captures/
```

All paths are controlled by `.dojo_config.sh`.

---

## 🧪 Baseline Capture

Run the baseline capture script:

```bash
bash scripts/baseline_capture_public.sh
```

This will:

* Validate config
* Check connectivity
* Capture headers and services
* Store results in `captures/`

This data becomes the **ground truth** for future comparisons and agents.

---

## 📊 Diffing (When Available)

Diff scripts will compare:

* Before vs after hardening
* Header changes
* Service exposure changes

These are currently being finalized and released incrementally.

---

## 🔐 Security Notes

* ❌ Never commit `.dojo_config.sh`
* ❌ Never commit logs or captures
* ✅ `.gitignore` blocks sensitive output
* ✅ Only test systems you own or are authorized to test

---

## ⚠️ Legal Disclaimer

This framework is for **authorized testing only**.

Do not run scans or attacks against systems you do not own or have permission to test.

---

## 🧠 Philosophy

> Capture first.
> Understand second.
> Automate third.
> Teach last.

These scripts are the **heart** of the Cyber Dojo agents to come.

---

## 🆘 Troubleshooting

**Permission denied?**

```bash
chmod +x setup_dojo.sh scripts/*.sh
```

**Config not loading?**

```bash
source .dojo_config.sh
```

**Missing tools?**

```bash
which nmap nikto curl openssl
```

---

