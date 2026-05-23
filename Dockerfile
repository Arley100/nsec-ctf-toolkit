# ============================================================
# NSEC CTF Toolkit - Dockerfile v3 (post-NorthSec 2026)
# ============================================================
# Author: Arley (GitHub: Arley100, Docker Hub: arley0101)
# Repo:   github.com/Arley100/nsec-ctf-toolkit
#
# A reproducible, all-in-one CTF environment used at:
#   - TAMUctf 2026
#   - @Hack 2026 (Beginner Track, 14th place)
#   - NorthSec 2026
#
# Build:  docker compose build
# Enter:  docker compose run --rm ctf
# Verify: bash /ctf/scripts/test-tools.sh
# ============================================================

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Montreal

# ── LAYER 1: Core system packages ─────────────────────────────────────
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev python3-venv \
    git curl wget vim nano tmux tree unzip zip p7zip-full \
    build-essential gcc g++ make cmake \
    nmap netcat-openbsd tshark tcpdump dnsutils iputils-ping net-tools \
    binwalk foremost exiftool testdisk \
    steghide \
    hashcat john \
    openssl libssl-dev libffi-dev \
    gdb ltrace strace file xxd \
    sqlmap \
    openjdk-21-jdk \
    ruby ruby-dev \
    less man-db \
    && rm -rf /var/lib/apt/lists/*

# ── LAYER 2: radare2 (CLI disassembler) ───────────────────────────────
RUN wget -q --tries=3 --timeout=60 --waitretry=10 \
    https://github.com/radareorg/radare2/releases/download/5.9.4/radare2_5.9.4_amd64.deb \
    -O /tmp/radare2.deb \
    && apt-get install -y /tmp/radare2.deb \
    && rm /tmp/radare2.deb

# ── LAYER 3: Python security libraries (core) ─────────────────────────
RUN pip3 install --no-cache-dir \
    pwntools \
    pycryptodome \
    requests \
    mitmproxy \
    z3-solver \
    capstone \
    angr \
    gmpy2 \
    flask \
    Pillow \
    ropgadget \
    tqdm

# ── LAYER 4: Ghidra (NSA decompiler) ──────────────────────────────────
RUN GHIDRA_URL=$(curl -s --retry 3 --retry-delay 10 --max-time 60 https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest \
    | grep "browser_download_url" \
    | grep "\.zip" \
    | cut -d '"' -f 4) \
    && wget -q --tries=3 --timeout=60 --waitretry=10 "$GHIDRA_URL" -O /opt/ghidra.zip \
    && unzip /opt/ghidra.zip -d /opt/ \
    && rm /opt/ghidra.zip \
    && GHIDRA_DIR=$(find /opt -maxdepth 1 -type d -name "ghidra_*" | head -1) \
    && ln -s "$GHIDRA_DIR/ghidraRun" /usr/local/bin/ghidra

# ── LAYER 5: Volatility 3 (memory forensics) ──────────────────────────
RUN pip3 install --no-cache-dir volatility3

# ── LAYER 6: pwndbg (GDB extension for exploit dev) ───────────────────
RUN git clone --depth=1 \
    https://github.com/pwndbg/pwndbg /opt/pwndbg \
    && cd /opt/pwndbg && ./setup.sh

# ── LAYER 7: RsaCtfTool (automated RSA attacks) ───────────────────────
RUN git clone --depth=1 \
    https://github.com/RsaCtfTool/RsaCtfTool.git /opt/RsaCtfTool \
    && pip3 install --no-cache-dir --no-deps /opt/RsaCtfTool \
    && pip3 install --no-cache-dir factordb-pycli \
    && printf '#!/bin/bash\ncd /opt/RsaCtfTool && PYTHONPATH=/opt/RsaCtfTool/src python3 -m RsaCtfTool.main "$@"\n' \
        > /usr/local/bin/RsaCtfTool \
    && chmod +x /usr/local/bin/RsaCtfTool

# ── LAYER 8: zsteg (PNG/BMP steganography) ────────────────────────────
RUN gem install zsteg

# ── LAYER 9: stegseek (fast steghide cracker) ─────────────────────────
RUN wget -q --tries=3 --timeout=60 --waitretry=10 \
    https://github.com/RickdeJager/stegseek/releases/download/v0.6/stegseek_0.6-1.deb \
    -O /tmp/stegseek.deb \
    && apt-get install -y /tmp/stegseek.deb \
    && rm /tmp/stegseek.deb

# ── LAYER 10: rockyou.txt wordlist ────────────────────────────────────
RUN mkdir -p /opt/wordlists \
    && wget -q --tries=3 --timeout=60 --waitretry=10 \
    https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt \
    -O /opt/wordlists/rockyou.txt

# ── LAYER 11: Quick-access aliases ────────────────────────────────────
RUN echo 'alias ll="ls -la --color=auto"' >> /root/.bashrc \
    && echo 'alias vol3="vol"' >> /root/.bashrc \
    && echo 'alias rsa="RsaCtfTool"' >> /root/.bashrc \
    && echo 'echo "NSEC CTF Toolkit ready. Type: tools-help"' >> /root/.bashrc

# ── LAYER 12: Audio/Video forensics ───────────────────────────────────
RUN apt-get update && apt-get install -y \
    sox ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir \
    librosa \
    scipy \
    soundfile \
    numpy

# ── LAYER 13: SageMath (ECC, DLP, lattice attacks) ────────────────────
RUN apt-get update && apt-get install -y sagemath \
    && rm -rf /var/lib/apt/lists/*

# ── LAYER 14: stegsolve (visual bit-plane analysis, needs X11) ────────
# Two install paths: upstream ctf-tools installer (drops jar in /usr/bin),
# or fallback direct download to /opt/stegsolve. Either way, we then
# create a unified /usr/local/bin/stegsolve wrapper so the command works
# the same regardless of which install path succeeded.
RUN (wget -q --tries=3 --timeout=60 --waitretry=10 \
    https://github.com/zardus/ctf-tools/raw/master/stegsolve/install \
    -O /tmp/stegsolve-install \
    && bash /tmp/stegsolve-install \
    && rm /tmp/stegsolve-install) \
    || (mkdir -p /opt/stegsolve \
    && wget -q --tries=3 --timeout=60 --waitretry=10 "https://github.com/eugenekolo/sec-tools/raw/master/stego/stegsolve/stegsolve/stegsolve.jar" \
        -O /opt/stegsolve/stegsolve.jar) \
    ; STEGSOLVE_JAR=$(find /usr/bin /opt -name "stegsolve.jar" -type f 2>/dev/null | head -1) \
    && printf '#!/bin/bash\njava -jar %s "$@"\n' "$STEGSOLVE_JAR" \
        > /usr/local/bin/stegsolve \
    && chmod +x /usr/local/bin/stegsolve

# ── LAYER 15: git-dumper (enumerate unreferenced Git objects) ─────────
RUN pip3 install --no-cache-dir git-dumper

# ── LAYER 16: Extra crypto/web Python libs ────────────────────────────
RUN pip3 install --no-cache-dir \
    sympy \
    pyOpenSSL \
    pyjwt \
    pycurl

# ── LAYER 17: challenge-start workflow script ─────────────────────────
RUN printf '#!/bin/bash\necho ""\necho "═══════════════════════════════════════════"\necho "   CHALLENGE FINISH TEMPLATE"\necho "═══════════════════════════════════════════"\necho ""\nread -p "1. What is the input artifact? (file/URL/string/binary): " ART\nread -p "2. What transformation is likely intended?: " TRANS\nread -p "3. What evidence supports that?: " EVID\nread -p "4. What exact tool or command tests this?: " TOOL\nread -p "5. What intermediate output should appear if correct?: " OUT\nread -p "6. What is your 30-min pivot if nothing works?: " PIVOT\necho ""\necho "───────────────────────────────────────────"\necho "  Artifact : $ART"\necho "  Transform: $TRANS"\necho "  Evidence : $EVID"\necho "  Tool     : $TOOL"\necho "  Expected : $OUT"\necho "  Pivot    : $PIVOT"\necho "───────────────────────────────────────────"\nCHAL_DIR="/ctf/challenges/$(date +%%Y%%m%%d_%%H%%M%%S)_challenge"\nmkdir -p "$CHAL_DIR"\necho "Artifact: $ART" > "$CHAL_DIR/notes.txt"\necho "Transform: $TRANS" >> "$CHAL_DIR/notes.txt"\necho "Evidence: $EVID" >> "$CHAL_DIR/notes.txt"\necho "Tool: $TOOL" >> "$CHAL_DIR/notes.txt"\necho "Expected output: $OUT" >> "$CHAL_DIR/notes.txt"\necho "Pivot plan: $PIVOT" >> "$CHAL_DIR/notes.txt"\necho ""\necho "  Workspace created: $CHAL_DIR"\necho "  Notes saved to   : $CHAL_DIR/notes.txt"\necho "  cd into it and start working."\necho ""\n' > /usr/local/bin/challenge-start \
    && chmod +x /usr/local/bin/challenge-start

# ============================================================
#   POST-NORTHSEC ADDITIONS (Layers 18–24)
#   Added May 2026 based on TAMUctf, MidnightSun, THCON writeups
#   and tools that proved necessary during competitions.
# ============================================================

# ── LAYER 18: Web pentest apt suite + archive/binary tooling ──────────
RUN apt-get update && apt-get install -y \
    nikto hydra fcrackzip \
    sleuthkit multimon-ng pngcheck zbar-tools imagemagick \
    arj ncompress squashfs-tools cramfsswap mtd-utils \
    upx-ucl patchelf yasm \
    && rm -rf /var/lib/apt/lists/*

# ── LAYER 19: Go-based web pentest tools (ProjectDiscovery + ffuf) ────
# Pre-built binaries from GitHub releases. No Go runtime needed.
RUN FFUF_URL=$(curl -s --retry 3 --retry-delay 10 --max-time 60 https://api.github.com/repos/ffuf/ffuf/releases/latest \
    | grep "browser_download_url" | grep "linux_amd64.tar.gz" \
    | cut -d '"' -f 4) \
    && wget -q --tries=3 --timeout=60 --waitretry=10 "$FFUF_URL" -O /tmp/ffuf.tar.gz \
    && tar -xzf /tmp/ffuf.tar.gz -C /usr/local/bin ffuf \
    && rm /tmp/ffuf.tar.gz \
    && NUCLEI_URL=$(curl -s --retry 3 --retry-delay 10 --max-time 60 https://api.github.com/repos/projectdiscovery/nuclei/releases/latest \
    | grep "browser_download_url" | grep "linux_amd64.zip" \
    | cut -d '"' -f 4) \
    && wget -q --tries=3 --timeout=60 --waitretry=10 "$NUCLEI_URL" -O /tmp/nuclei.zip \
    && unzip -o /tmp/nuclei.zip -d /usr/local/bin nuclei \
    && rm /tmp/nuclei.zip \
    && SUBFINDER_URL=$(curl -s --retry 3 --retry-delay 10 --max-time 60 https://api.github.com/repos/projectdiscovery/subfinder/releases/latest \
    | grep "browser_download_url" | grep "linux_amd64.zip" \
    | cut -d '"' -f 4) \
    && wget -q --tries=3 --timeout=60 --waitretry=10 "$SUBFINDER_URL" -O /tmp/subfinder.zip \
    && unzip -o /tmp/subfinder.zip -d /usr/local/bin subfinder \
    && rm /tmp/subfinder.zip \
    && chmod +x /usr/local/bin/ffuf /usr/local/bin/nuclei /usr/local/bin/subfinder

# ── LAYER 20: jwt_tool (JWT attack toolkit) ───────────────────────────
RUN git clone --depth=1 \
    https://github.com/ticarpi/jwt_tool /opt/jwt_tool \
    && pip3 install --no-cache-dir -r /opt/jwt_tool/requirements.txt \
    && printf '#!/bin/bash\npython3 /opt/jwt_tool/jwt_tool.py "$@"\n' \
        > /usr/local/bin/jwt_tool \
    && chmod +x /usr/local/bin/jwt_tool

# ── LAYER 21: SecLists (the largest layer, ~3 GB) ─────────────────────
# Depth-1 clone keeps download under control. Contains wordlists,
# payloads, fuzzing patterns, default credentials, etc.
RUN git clone --depth=1 \
    https://github.com/danielmiessler/SecLists /opt/SecLists

# ── LAYER 22: Extra Python libraries (RE, crypto, web, parsing) ───────
RUN pip3 install --no-cache-dir \
    unicorn \
    pefile \
    pyelftools \
    kaitaistruct \
    bcrypt \
    bitarray \
    bitstring \
    cart \
    cryptography \
    dulwich \
    ldap3 \
    paramiko \
    pyxbe \
    rich \
    rpyc \
    scikit-learn \
    service-identity \
    uefi-firmware \
    pyperclip \
    pyserial \
    zstandard \
    beautifulsoup4 \
    hashID

# ── LAYER 23: Extra Ruby gems for image/stego analysis ────────────────
RUN gem install iostruct rainbow zpng

# ── LAYER 24: Refreshed quick-reference and aliases (v3) ──────────────
RUN echo 'alias sage="sage"' >> /root/.bashrc \
    && echo 'alias cs="challenge-start"' >> /root/.bashrc \
    && echo 'alias steg="stegsolve"' >> /root/.bashrc \
    && echo 'alias seclists="ls /opt/SecLists"' >> /root/.bashrc \
    && printf '#!/bin/bash\necho ""\necho "══════════════════════════════════════════════════════"\necho "   NSEC CTF TOOLKIT v3 — Quick Reference"\necho "══════════════════════════════════════════════════════"\necho ""\necho "  WORKFLOW"\necho "  cs / challenge-start   Run Finish Template before any tool"\necho ""\necho "  WEB PENTEST"\necho "  ffuf                   Fast web fuzzer"\necho "  nuclei                 Templated vulnerability scanner"\necho "  subfinder              Subdomain enumeration"\necho "  nikto                  Web server scanner"\necho "  hydra                  Network login brute force"\necho "  sqlmap                 SQL injection"\necho "  jwt_tool               JWT attacks (signature, kid, etc.)"\necho "  git-dumper             Enumerate unreferenced Git objects"\necho "  curl / mitmproxy       HTTP tooling"\necho ""\necho "  CRYPTO"\necho "  RsaCtfTool / rsa       Automated RSA attacks"\necho "  sage                   SageMath — ECC, DLP, lattices"\necho "  hashcat / john         Hash cracking"\necho "  fcrackzip              Zip password cracking"\necho "  hashid                 Identify hash types"\necho "  openssl                Cert and cipher inspection"\necho "  factordb               Query online factoring database"\necho ""\necho "  FORENSICS — IMAGE / FILE"\necho "  binwalk -e <file>      Extract embedded files"\necho "  foremost               File carving"\necho "  exiftool <file>        Metadata extraction"\necho "  zsteg <file>           PNG/BMP LSB steganography"\necho "  steghide / stegseek    JPEG steganography"\necho "  stegsolve              Visual bit-plane analysis (needs GUI)"\necho "  pngcheck               PNG structure analysis"\necho "  zbarimg                QR/barcode reading"\necho "  convert (imagemagick)  Image manipulation"\necho "  strings / xxd          Raw binary inspection"\necho ""\necho "  FORENSICS — DISK"\necho "  tsk_recover (sleuthkit) Disk image carving"\necho ""\necho "  FORENSICS — AUDIO / VIDEO"\necho "  sox <in> <out> reverse Reverse audio"\necho "  sox <in> -n spectrogram Generate spectrogram"\necho "  multimon-ng            Decode radio/DTMF/POCSAG"\necho "  ffmpeg -i <vid> frames/ Extract video frames"\necho ""\necho "  MEMORY FORENSICS"\necho "  vol / vol3             Volatility 3"\necho ""\necho "  REVERSE ENGINEERING"\necho "  ghidra                 Decompiler (needs GUI)"\necho "  r2 / radare2           CLI disassembly"\necho "  gdb                    Debugger with pwndbg"\necho "  ltrace / strace        Library and syscall tracing"\necho "  upx                    Unpacker"\necho "  patchelf               ELF metadata patcher"\necho "  python3 -c unicorn     CPU emulator (Python binding)"\necho "  python3 -c pefile      Windows PE parser"\necho "  python3 -c pyelftools  ELF parser"\necho ""\necho "  BINARY EXPLOITATION"\necho "  python3 -c pwntools    Exploit scripting"\necho "  ROPgadget              ROP chain gadget finder"\necho ""\necho "  NETWORK"\necho "  nmap / nc              Scanning and raw TCP"\necho "  tshark / tcpdump       PCAP analysis"\necho ""\necho "  WORDLISTS"\necho "  /opt/wordlists/rockyou.txt"\necho "  /opt/SecLists/         (full SecLists tree)"\necho "══════════════════════════════════════════════════════"\necho ""\n' > /usr/local/bin/tools-help \
    && chmod +x /usr/local/bin/tools-help

WORKDIR /ctf

CMD ["/bin/bash", "--login"]
