# 🥋 Danby's Cyber Dojo

**Purple Team Training Framework with AI-Powered Security Coaching**

An interactive learning environment for offensive and defensive cybersecurity skills development, featuring specialized AI agents for nginx hardening validation, web security fundamentals, and CompTIA Security+ exam preparation.

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude](https://img.shields.io/badge/AI-Claude%20Haiku%204.5-purple.svg)](https://www.anthropic.com/)

---

## 🎯 Overview

**Danby's Cyber Dojo** is a professional security training environment built around AI-powered coaching agents. Each agent specializes in different aspects of cybersecurity, from offensive red team methodologies to defensive blue team incident response.

**Built in:** Brisbane, Australia 🇦🇺  
**Environment:** Kali Purple + Ubuntu Server (isolated lab)  
**Purpose:** Real-world security operations training + certification prep

---

## 🤖 The Agents

### 🎮 **Dojo Controller** (Master Command Center)
Central launcher with retro ASCII interface for all training agents.

**Features:**
- Unified agent launcher
- Session tracking and logging
- Professional CLI interface
- `/menu` and `/back` navigation

### 📊 **Diff Report Professor**
Analyzes nginx hardening reports and teaches security principles.

**What it teaches:**
- Security header implementation
- Vulnerability remediation
- Before/after change analysis
- Interactive Q&A on findings

### 🌐 **HTML Professor**
Web security fundamentals mentor for entry-level developers.

**What it teaches:**
- Secure HTML/CSS development
- XSS prevention basics
- Content-Security-Policy
- Accessibility = Security

### 🔴 **Red Team Agent**
Offensive security training (lab-only, ethical testing).

**What it teaches:**
- Attack methodologies
- Penetration testing procedures
- Purple team exercise planning
- Attacker mindset

### 🔵 **Blue Team Agent**
Defensive security and incident response mentor.

**What it teaches:**
- Detection methodologies
- Incident response planning
- Log analysis procedures
- System hardening

---

## 🚀 Quick Start

### Prerequisites

- Python 3.8 or higher
- Anthropic API key ([get one here](https://console.anthropic.com/))
- Linux environment (tested on Kali Purple, Ubuntu Server)

### Installation
```bash
# Clone repository
git clone https://github.com/danbyai/danbys-cyber-dojo.git
cd danbys-cyber-dojo

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set your API key
export ANTHROPIC_API_KEY='your-api-key-here'

# Launch the Dojo
cd agents
python3 dojo_controller.py
```

### First Launch
```
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║   ██████╗  █████╗ ███╗   ██╗██████╗ ██╗   ██╗███████╗                 ║
║   ██╔══██╗██╔══██╗████╗  ██║██╔══██╗╚██╗ ██╔╝██╔════╝                 ║
║   ██║  ██║███████║██╔██╗ ██║██████╔╝ ╚████╔╝ ███████╗                 ║
║   ██║  ██║██╔══██║██║╚██╗██║██╔══██╗  ╚██╔╝  ╚════██║                 ║
║   ██████╔╝██║  ██║██║ ╚████║██████╔╝   ██║   ███████║                 ║
║   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝    ╚═╝   ╚══════╝                 ║
║                                                                       ║
║                   🥋  C Y B E R   D O J O  🥋                         ║
╚═══════════════════════════════════════════════════════════════════════╝
```

---

## 📁 Project Structure
```
danbys-cyber-dojo/
├── agents/                  # AI coaching agents
│   ├── dojo_controller.py   # Master launcher
│   ├── diff_report_professor.py
│   ├── html_professor.py
│   ├── red_team_agent.py
│   └── blue_team_agent.py
├── scripts/                 # Bash automation scripts
│   └── daily_diff.sh       # nginx hardening validator
├── examples/                # Sample outputs and demos
├── docs/                    # Documentation
├── .gitignore              # Security: NO secrets pushed
├── requirements.txt        # Python dependencies
├── LICENSE                 # MIT License
└── README.md              # This file
```

---

## 🛡️ Security & Privacy

**This repository contains NO sensitive data:**

- ❌ No API keys or authentication tokens
- ❌ No session logs (chat histories)
- ❌ No network captures (IP addresses)
- ❌ No credentials or secrets
- ✅ All sensitive data excluded via `.gitignore`

**All agents log locally to `~/test_labs/logs/` (never committed).**

---

## 📊 Features

### Unified Logging
Every agent logs complete session transcripts to dedicated directories:
```
~/test_labs/logs/
├── dojo_controller/
├── professor/
├── html_professor/
├── red_team/
└── blue_team/
```

### Cost Optimization
- **Model:** Claude Haiku 4.5
- **Cost:** ~$0.0003 per interaction
- **Context:** 8-message history (trimmed automatically)
- **Tokens:** 1500 max per response

### Modular Design
Easy to extend with new agents following the established pattern.

---

## 🎓 Use Cases

1. **CompTIA Security+ Preparation**  
   Interactive learning with AI-powered coaches

2. **nginx Hardening Validation**  
   Before/after diff analysis with expert explanations

3. **Purple Team Training**  
   Combined offensive and defensive methodologies

4. **Web Security Fundamentals**  
   HTML/CSS security best practices

5. **Incident Response Planning**  
   Defense strategies and detection procedures

---

## 🔧 Requirements

**Python packages:**
```
anthropic>=0.18.0
```

See `requirements.txt` for complete dependencies.

---

## 📖 Documentation

- [Setup Guide](docs/setup.md) *(coming soon)*
- [Usage Examples](docs/usage.md) *(coming soon)*
- [Architecture Overview](docs/architecture.md) *(coming soon)*

---

## 🤝 Contributing

This is a personal training environment and portfolio project. Not currently accepting contributions, but feel free to fork and adapt for your own learning!

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

**For authorized testing only.** All red team methodologies and offensive security content are designed exclusively for use in isolated lab environments on systems you own or have explicit permission to test.

Never use these techniques on systems without proper authorization.

---

## 🙏 Acknowledgments

- **Claude by Anthropic** - AI coaching foundation
- **Kali Linux / Offensive Security** - Training platform
- **CompTIA** - Security+ certification framework

---

## 📫 Contact

**Built by Danby**  
Security+ Candidate | Purple Team Practitioner  
Brisbane, Australia 🇦🇺

---

**Train hard. Build skills. Stay curious.** 🥋🔥
