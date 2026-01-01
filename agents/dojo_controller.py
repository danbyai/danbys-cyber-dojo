#!/usr/bin/env python3
"""
🥋 DANBY'S CYBER DOJO - Master Controller
Central command center for all Purple Team training agents

Usage:
    python3 dojo_controller.py

Features:
- Retro ASCII art interface
- Unified agent launcher
- Session logging to ~/test_labs/logs/dojo_controller/
- /menu or /back navigation
- Professional Purple Team workflow
"""

import os
import sys
import subprocess
from pathlib import Path
from datetime import datetime


class DojoController:
    """Master controller for Danby's Cyber Dojo"""

    LOGS_DIR = Path.home() / "test_labs" / "logs" / "dojo_controller"
    AGENTS_DIR = Path.home() / "test_labs" / "agents"

    def __init__(self):
        self._ensure_directories()
        
        # Session logging
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.session_log_path = self.LOGS_DIR / f"dojo_session_{ts}.log"
        self._log(f"[START] Dojo Controller session started @ {datetime.now().isoformat()}")
        self._log(f"[LOGFILE] {self.session_log_path}")

    def _ensure_directories(self):
        """Create log directory"""
        self.LOGS_DIR.mkdir(parents=True, exist_ok=True)

    def _log(self, msg: str):
        """Append to session log (best effort, never crash)"""
        try:
            with open(self.session_log_path, "a", encoding="utf-8") as f:
                f.write(msg.rstrip() + "\n")
        except Exception:
            pass

    def display_banner(self):
        """Show the epic Danby's Cyber Dojo banner"""
        banner = """
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║     ██████╗  █████╗ ███╗   ██╗██████╗ ██╗   ██╗███████╗               ║
║     ██╔══██╗██╔══██╗████╗  ██║██╔══██╗╚██╗ ██╔╝██╔════╝               ║
║     ██║  ██║███████║██╔██╗ ██║██████╔╝ ╚████╔╝ ███████╗               ║
║     ██║  ██║██╔══██║██║╚██╗██║██╔══██╗  ╚██╔╝  ╚════██║               ║
║     ██████╔╝██║  ██║██║ ╚████║██████╔╝   ██║   ███████║               ║
║     ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝    ╚═╝   ╚══════╝               ║
║                                                                       ║
║                   🥋  C Y B E R   D O J O  🥋                         ║
║              Purple Team Training & Security Lab                      ║
║                    Brisbane, Australia 🇦🇺                             ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
"""
        print(banner)
        self._log(banner)

    def display_menu(self):
        """Show agent selection menu"""
        menu = """
┌───────────────────────────────────────────────────────────────────────┐
│                         AGENT SELECTION                               │
└───────────────────────────────────────────────────────────────────────┘

  [1] 📊 Diff Report Professor  - Learn from nginx hardening reports
  [2] 🌐 HTML Professor          - Web security fundamentals
  [3] 🔴 Red Team Agent          - Attack methodology (lab only)
  [4] 🔵 Blue Team Agent         - Defense & incident response
  [5] 🚪 Exit Dojo

┌───────────────────────────────────────────────────────────────────────┐
│ All sessions logged to: ~/test_labs/logs/                            │
│ Type /menu or /back in any agent to return here                      │
└───────────────────────────────────────────────────────────────────────┘
"""
        print(menu)
        self._log(menu)

    def launch_agent(self, agent_name, script_name):
        """Launch an agent and wait for it to complete"""
        self._log(f"[LAUNCH] Starting {agent_name}")
        
        print(f"\n🚀 Launching {agent_name}...")
        print(f"   (Type /menu or /back to return to Dojo menu)\n")
        print("=" * 75 + "\n")
        
        try:
            # Try to find the script in common locations
            possible_paths = [
                Path.cwd() / script_name,  # Current directory
                self.AGENTS_DIR / script_name,  # Agents directory
                Path.home() / "test_labs" / script_name,  # test_labs root
            ]
            
            script_path = None
            for path in possible_paths:
                if path.exists():
                    script_path = path
                    break
            
            if not script_path:
                print(f"❌ Cannot find {script_name}")
                print(f"   Searched locations:")
                for path in possible_paths:
                    print(f"   - {path}")
                print(f"\n   Please ensure {script_name} is in one of these locations.")
                self._log(f"[ERROR] {script_name} not found")
                return
            
            # Launch the agent
            result = subprocess.run(
                [sys.executable, str(script_path)],
                check=False
            )
            
            self._log(f"[END] {agent_name} exited with code {result.returncode}")
            
        except KeyboardInterrupt:
            self._log(f"[INTERRUPT] {agent_name} interrupted by user")
            print(f"\n\n🔙 Returning to Dojo menu...")
        except Exception as e:
            error_msg = f"❌ Error launching {agent_name}: {e}"
            print(error_msg)
            self._log(f"[ERROR] {error_msg}")

    def run(self):
        """Main controller loop"""
        if not os.getenv("ANTHROPIC_API_KEY"):
            print("❌ ANTHROPIC_API_KEY not set")
            print("   Export it: export ANTHROPIC_API_KEY='your-key-here'")
            sys.exit(1)

        self.display_banner()

        while True:
            self.display_menu()

            try:
                choice = input("Select your training [1-5]: ").strip()
                self._log(f"[SELECT] User chose: {choice}")

                if choice == "1":
                    self.launch_agent("Diff Report Professor", "diff_report_professor.py")
                
                elif choice == "2":
                    self.launch_agent("HTML Professor", "html_professor.py")
                
                elif choice == "3":
                    self.launch_agent("Red Team Agent", "red_team_agent.py")
                
                elif choice == "4":
                    self.launch_agent("Blue Team Agent", "blue_team_agent.py")
                
                elif choice == "5":
                    print("\n" + "=" * 75)
                    print("🥋 Exiting Danby's Cyber Dojo")
                    print("=" * 75)
                    print("\n✅ Keep training hard, brother! 💪")
                    print("   All session logs saved to: ~/test_labs/logs/\n")
                    self._log("[EXIT] User exited Dojo")
                    self._log(f"[END] Session ended @ {datetime.now().isoformat()}")
                    self._log("=" * 80 + "\n")
                    break
                
                else:
                    print("\n❌ Invalid choice. Please select 1-5.\n")
                    self._log(f"[ERROR] Invalid choice: {choice}")

            except KeyboardInterrupt:
                print("\n\n🔙 Returning to menu...\n")
                continue
            except EOFError:
                print("\n\n✅ Exiting Dojo. Train hard! 🥋\n")
                self._log("[EXIT] EOF detected, exiting")
                break


def main():
    """Entry point"""
    controller = DojoController()
    controller.run()


if __name__ == "__main__":
    main()
