#!/bin/bash
# ============================================================
# NSEC CTF Toolkit v3 — Tool Verification Script
# ============================================================
# Run inside the container:
#   bash /ctf/scripts/test-tools.sh
# ============================================================

PASS=0
FAIL=0

check() {
    local name="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  ✓ $name"
        PASS=$((PASS+1))
    else
        echo "  ✗ $name  [FAILED]"
        FAIL=$((FAIL+1))
    fi
}

echo ""
echo "══════════════════════════════════════════"
echo "   NSEC CTF Toolkit v3 — Tool Check"
echo "══════════════════════════════════════════"

echo ""
echo "── Crypto ────────────────────────────────"
check "john"          "command -v john"
check "hashcat"       "command -v hashcat"
check "openssl"       "command -v openssl"
check "RsaCtfTool"    "command -v RsaCtfTool"
check "sage"          "command -v sage"
check "factordb"      "command -v factordb || python3 -c 'import factordb'"
check "fcrackzip"     "command -v fcrackzip"
check "hashid (pip)"  "command -v hashid || python3 -c 'import hashid'"
check "rockyou.txt"   "test -f /opt/wordlists/rockyou.txt"

echo ""
echo "── Wordlists / Payloads ──────────────────"
check "SecLists dir"          "test -d /opt/SecLists"
check "SecLists Passwords"    "test -d /opt/SecLists/Passwords"
check "SecLists Discovery"    "test -d /opt/SecLists/Discovery"
check "SecLists Fuzzing"      "test -d /opt/SecLists/Fuzzing"

echo ""
echo "── Reverse Engineering ───────────────────"
check "gdb+pwndbg"    "gdb --batch -ex 'python import pwndbg' 2>/dev/null || test -d /opt/pwndbg"
check "radare2"       "command -v r2"
check "ghidra"        "command -v ghidra"
check "ropgadget"     "command -v ROPgadget"
check "ltrace"        "command -v ltrace"
check "strace"        "command -v strace"
check "upx"           "command -v upx"
check "patchelf"      "command -v patchelf"
check "yasm"          "command -v yasm"
check "unicorn"       "python3 -c 'import unicorn'"
check "pefile"        "python3 -c 'import pefile'"
check "pyelftools"    "python3 -c 'import elftools'"
check "kaitaistruct"  "python3 -c 'import kaitaistruct'"

echo ""
echo "── Binary Exploitation ───────────────────"
check "pwntools"      "python3 -c 'import pwn'"
check "capstone"      "python3 -c 'import capstone'"
check "z3-solver"     "python3 -c 'import z3'"
check "angr"          "python3 -c 'import angr'"

echo ""
echo "── Forensics — File / Image ──────────────"
check "binwalk"       "command -v binwalk"
check "foremost"      "command -v foremost"
check "exiftool"      "command -v exiftool"
check "testdisk"      "command -v testdisk"
check "steghide"      "command -v steghide"
check "stegseek"      "command -v stegseek"
check "stegsolve"     "command -v stegsolve"
check "zsteg"         "command -v zsteg"
check "pngcheck"      "command -v pngcheck"
check "zbarimg"       "command -v zbarimg"
check "imagemagick"   "command -v convert"

echo ""
echo "── Forensics — Disk ──────────────────────"
check "sleuthkit"     "command -v tsk_recover"
check "arj"           "command -v arj"
check "ncompress"     "command -v uncompress"

echo ""
echo "── Forensics — Audio / Video ─────────────"
check "sox"           "command -v sox"
check "ffmpeg"        "command -v ffmpeg"
check "multimon-ng"   "command -v multimon-ng"
check "librosa"       "python3 -c 'import librosa'"
check "soundfile"     "python3 -c 'import soundfile'"

echo ""
echo "── Memory Forensics ──────────────────────"
check "volatility3"   "command -v vol"

echo ""
echo "── Web / Network ─────────────────────────"
check "sqlmap"        "command -v sqlmap"
check "curl"          "command -v curl"
check "nmap"          "command -v nmap"
check "netcat"        "command -v nc"
check "tshark"        "command -v tshark"
check "tcpdump"       "command -v tcpdump"
check "nikto"         "command -v nikto"
check "hydra"         "command -v hydra"
check "ffuf"          "command -v ffuf"
check "nuclei"        "command -v nuclei"
check "subfinder"     "command -v subfinder"
check "mitmproxy"     "command -v mitmproxy"
check "jwt_tool"      "command -v jwt_tool"

echo ""
echo "── Git / Platform ────────────────────────"
check "git-dumper"    "command -v git-dumper"
check "dulwich"       "python3 -c 'import dulwich'"

echo ""
echo "── Workflow Tools ────────────────────────"
check "challenge-start" "command -v challenge-start"
check "tools-help"    "command -v tools-help"
check "python3"       "command -v python3"
check "git"           "command -v git"
check "tmux"          "command -v tmux"
check "java (Ghidra)" "command -v java"

echo ""
echo "══════════════════════════════════════════"
echo "  Results: $PASS passed  |  $FAIL failed"
echo "══════════════════════════════════════════"

if [ $FAIL -gt 0 ]; then
    echo "  ⚠  Some tools failed. Check the Dockerfile."
    echo "     Rebuild with: docker compose build --no-cache"
    exit 1
else
    echo "  ✓  All tools verified. Ready to ship."
fi
echo ""
