# ============================================================
# Makefile - shortcut commands for the CTF toolkit
# ============================================================
# A Makefile lets you define short commands that run longer ones.
# Instead of remembering "docker compose run --rm ctf", you
# just type "make shell".
#
# HOW TO USE ON WINDOWS:
# You need "make" installed. The easiest way:
#   winget install GnuWin32.Make
# Or use Git Bash which includes make.
# Alternatively, just copy-paste the commands after the tab below.
# ============================================================

# The name of your Docker image (matches what we tag it as)
IMAGE_NAME = nsec-ctf-toolkit
CONTAINER_NAME = nsec-toolkit

# ── build ────────────────────────────────────────────────────
# Reads the Dockerfile and creates the image.
# Run this ONCE before the competition, and again if you add tools.
# Takes ~10-20 minutes the first time (lots to download and install).
build:
	docker compose build

# ── shell ────────────────────────────────────────────────────
# Opens an interactive terminal inside the container.
# This is the command you'll use 90% of the time.
# Ctrl+D or type "exit" to leave the container.
shell:
	docker compose run --rm ctf

# ── up ───────────────────────────────────────────────────────
# Starts the container in the background (detached mode).
# Useful if you want to run multiple terminal windows into it.
up:
	docker compose up -d

# ── attach ───────────────────────────────────────────────────
# Connects to an already-running container started with "make up".
attach:
	docker exec -it $(CONTAINER_NAME) /bin/bash --login

# ── stop ─────────────────────────────────────────────────────
stop:
	docker compose down

# ── rebuild ──────────────────────────────────────────────────
# Full clean rebuild. Use this when you add new tools to the
# Dockerfile and want to rebuild from scratch.
rebuild:
	docker compose down
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	docker compose build --no-cache

# ── test ─────────────────────────────────────────────────────
# Runs the tool verification script to confirm everything works.
test:
	docker compose run --rm ctf /ctf/scripts/test-tools.sh

# ── share ────────────────────────────────────────────────────
# Pushes your built image to Docker Hub so teammates can pull it.
# Replace YOUR_DOCKERHUB_USERNAME with your actual username.
# Teammates then run: docker pull YOUR_DOCKERHUB_USERNAME/nsec-ctf-toolkit
share:
	@echo "Tagging and pushing image to Docker Hub..."
	@read -p "Enter your Docker Hub username: " username; \
	docker tag $(IMAGE_NAME) $$username/$(IMAGE_NAME):latest && \
	docker push $$username/$(IMAGE_NAME):latest && \
	echo "Done! Teammates can run: docker pull $$username/$(IMAGE_NAME)"

# ── clean ────────────────────────────────────────────────────
# Removes the image entirely. Re-run "make build" to start fresh.
clean:
	docker compose down
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	docker system prune -f

.PHONY: build shell up attach stop rebuild test share clean
