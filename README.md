# NSEC CTF Toolkit

A reproducible, Docker-based CTF environment with 60+ pre-installed tools across crypto, forensics, reverse engineering, binary exploitation, web pentesting, and steganography. One image, one command, zero competition-day setup.

**Used at:** TAMUctf 2026 · NorthSec 2026

---

## Why this exists

Spending the first hour of a CTF installing tools and chasing missing dependencies is a competitive disadvantage. This repo provides a single Dockerfile that produces an Ubuntu 22.04 image with every tool already installed, configured, and verified by a test script.

The toolkit evolved across multiple competitions: each event exposed a gap (a missing ECC library, a needed wordlist, a forensic tool), the gap got added to the Dockerfile, and the next event used the improved version.

---

## Quick start

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS) or Docker Engine (Linux)
- ~20 GB free disk space for the built image
- Git

### Build and run

```bash
git clone https://github.com/Arley100/nsec-ctf-toolkit.git
cd nsec-ctf-toolkit
docker compose build
docker compose run --rm ctf
```

First build takes 45–90 minutes (SageMath alone is ~30 min; SecLists clone is ~3 GB). Subsequent rebuilds use Docker's layer cache and finish in minutes.

### Verify the install

```bash
# Inside the container:
bash /ctf/scripts/test-tools.sh
```

You should see ~60 green checks across all categories.

### Get a tools cheat sheet

```bash
# Inside the container:
tools-help
```

---

## What's inside

### Web pentesting
ffuf · nuclei · subfinder · nikto · hydra · sqlmap · jwt_tool · mitmproxy · curl · git-dumper

### Crypto
RsaCtfTool · SageMath (ECC, DLP, lattices) · hashcat · john · fcrackzip · hashid · openssl · factordb-pycli · pycryptodome · gmpy2 · sympy · z3-solver

### Forensics — file/image
binwalk · foremost · exiftool · testdisk · steghide · stegseek · stegsolve · zsteg · pngcheck · zbarimg (QR/barcode) · imagemagick · strings · xxd

### Forensics — disk
sleuthkit · arj · ncompress · squashfs-tools

### Forensics — audio/video
sox · ffmpeg · multimon-ng · librosa · soundfile

### Memory forensics
Volatility 3 (`vol` / `vol3`)

### Reverse engineering
Ghidra · radare2 · GDB+pwndbg · ltrace · strace · upx · patchelf · yasm · unicorn (CPU emulator) · pefile · pyelftools · kaitaistruct

### Binary exploitation
pwntools · capstone · angr · ROPgadget · z3-solver

### Networking
nmap · netcat · tshark · tcpdump · mitmproxy

### Wordlists
rockyou.txt (`/opt/wordlists/rockyou.txt`) · SecLists (`/opt/SecLists/`)

### Workflow tools
`challenge-start` (or `cs`) — guided challenge setup template
`tools-help` — printable cheat sheet inside the container

---

## Project layout

```
nsec-ctf-toolkit/
├── Dockerfile              # The recipe — 24 layers, ~17 GB built image
├── docker-compose.yml      # Container runtime config
├── Makefile                # Shortcuts: make build / shell / test / rebuild
├── scripts/
│   ├── test-tools.sh       # Verification script — run after build
│   └── ctf-start.sh        # Per-challenge workspace initializer
├── challenges/             # Competition files go here (mounted into container)
└── wordlists/              # Optional extra wordlists
```

---

## How file sharing works

The `docker-compose.yml` mounts three host folders into the container so you can edit on the host (VS Code, etc.) and execute inside the container:

| Host folder      | Container path       |
|------------------|----------------------|
| `./challenges/`  | `/ctf/challenges/`   |
| `./scripts/`     | `/ctf/scripts/`      |
| `./wordlists/`   | `/ctf/wordlists/`    |

Drop a challenge file into `./challenges/` on the host — it appears instantly at `/ctf/challenges/` inside the container.

---

## Adding new tools

1. Open `Dockerfile` in your editor.
2. Append a new `RUN` block (or add to an existing one if the tool fits a category).
3. `docker compose build` — only the new and downstream layers rebuild.
4. Add a check for the tool to `scripts/test-tools.sh`.
5. Run `bash /ctf/scripts/test-tools.sh` to verify.
6. Commit and push.

The Dockerfile is the source of truth. Never `apt-get install` inside a running container without also patching the Dockerfile — that change won't survive a rebuild and won't be reproducible for teammates.

---

## Sharing with teammates

### Via Docker Hub (faster for them — no build needed)

```bash
docker tag nsec-ctf-toolkit arley0101/nsec-ctf-toolkit:latest
docker push arley0101/nsec-ctf-toolkit:latest

# Teammates:
docker pull arley0101/nsec-ctf-toolkit:latest
```

### Via GitHub (slower — they rebuild locally)

```bash
git clone https://github.com/Arley100/nsec-ctf-toolkit.git
cd nsec-ctf-toolkit
docker compose build
```

---

## Troubleshooting

**Build fails on a specific layer** — Paste the layer number and error. Most often a tool's release URL changed; the Dockerfile uses GitHub API queries for `latest` so most version drift is handled automatically.

**Ghidra/stegsolve won't open a GUI** — They need X11. Easiest fix on Windows: install Ghidra natively for the few times you need the GUI; use the container for everything else. On Linux, mount X11 with `-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix`.

**"No space left on device"** — The built image is ~17 GB. Free Docker space with `docker system prune -af`.

**A tool is missing** — Run `bash /ctf/scripts/test-tools.sh` to see which check failed. If a tool you need isn't covered, add it to the Dockerfile per "Adding new tools" above.

---

## License

Tools inside the image retain their original licenses. The Dockerfile and helper scripts in this repo are released under the MIT License.
