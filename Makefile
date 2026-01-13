# Development Environment Setup - Makefile
# Modular installation and configuration for macOS

.PHONY: help install all homebrew brew-packages dotfiles dotfiles-bash dotfiles-git dotfiles-psql \
	macos-defaults macos-privacy backup check git-config postgres-setup

# Colors
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
BOLD := \033[1m
RESET := \033[0m

# Directories
CONFIG_DIR := config
SCRIPTS_DIR := scripts
BACKUP_DIR := $(HOME)/.dotfiles-backup

##@ General

help: ## Show this help message
	@echo "$(BOLD)$(CYAN)Development Environment Setup$(RESET)"
	@echo ""
	@echo "$(BOLD)Usage:$(RESET) make $(CYAN)[target]$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf ""} \
		/^[a-zA-Z_-]+:.*?##/ { printf "  $(CYAN)%-20s$(RESET) %s\n", $$1, $$2 } \
		/^##@/ { printf "\n$(BOLD)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Full Installation

install: ## Interactive full installation (runs install.sh)
	@echo "$(BOLD)$(CYAN)==> Running full interactive installation...$(RESET)"
	@./install.sh

all: install ## Alias for 'install'

quick: homebrew brew-packages dotfiles macos-defaults ## Quick non-interactive setup with defaults
	@echo "$(BOLD)$(GREEN)==> Quick setup complete!$(RESET)"
	@echo "$(YELLOW)Note: Git and PostgreSQL not configured. Run 'make git-config' and 'make postgres-setup' if needed.$(RESET)"

##@ Package Management

homebrew: ## Install or update Homebrew
	@if command -v brew >/dev/null 2>&1; then \
		echo "$(BOLD)$(GREEN)==> Homebrew already installed$(RESET)"; \
		echo "$(BOLD)$(CYAN)==> Updating Homebrew...$(RESET)"; \
		brew update; \
		brew upgrade; \
	else \
		echo "$(BOLD)$(CYAN)==> Installing Homebrew...$(RESET)"; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi

brew-packages: ## Install packages from Brewfile
	@if [ -f "$(CONFIG_DIR)/Brewfile" ]; then \
		echo "$(BOLD)$(CYAN)==> Installing packages from Brewfile...$(RESET)"; \
		brew bundle --file=$(CONFIG_DIR)/Brewfile; \
	else \
		echo "$(RED)Error: Brewfile not found at $(CONFIG_DIR)/Brewfile$(RESET)"; \
		exit 1; \
	fi

##@ Configuration Files

dotfiles: dotfiles-bash dotfiles-psql ## Install all dotfiles
	@echo "$(BOLD)$(GREEN)==> All dotfiles installed$(RESET)"

dotfiles-bash: backup-bash ## Install .bash_profile
	@echo "$(BOLD)$(CYAN)==> Installing .bash_profile...$(RESET)"
	@cp $(CONFIG_DIR)/.bash_profile $(HOME)/.bash_profile
	@echo "$(GREEN)==> .bash_profile installed. Run 'source ~/.bash_profile' to apply.$(RESET)"

dotfiles-psql: backup-psql ## Install .psqlrc
	@echo "$(BOLD)$(CYAN)==> Installing .psqlrc...$(RESET)"
	@cp $(CONFIG_DIR)/.psqlrc $(HOME)/.psqlrc
	@echo "$(GREEN)==> .psqlrc installed$(RESET)"

##@ Tool Configuration

git-config: backup-gitconfig ## Configure git (interactive)
	@echo "$(BOLD)$(CYAN)==> Configuring Git...$(RESET)"
	@chmod +x $(SCRIPTS_DIR)/git.sh
	@$(SCRIPTS_DIR)/git.sh

postgres-setup: ## Install and configure PostgreSQL
	@echo "$(BOLD)$(CYAN)==> Setting up PostgreSQL...$(RESET)"
	@chmod +x $(SCRIPTS_DIR)/postgres.sh
	@$(SCRIPTS_DIR)/postgres.sh

##@ macOS Settings

macos-defaults: ## Apply macOS default settings
	@echo "$(BOLD)$(CYAN)==> Applying macOS defaults...$(RESET)"
	@chmod +x $(SCRIPTS_DIR)/defaults.sh
	@. $(SCRIPTS_DIR)/defaults.sh
	@echo "$(GREEN)==> macOS defaults applied$(RESET)"

macos-privacy: ## Apply privacy and performance settings
	@echo "$(BOLD)$(CYAN)==> Applying privacy and performance settings...$(RESET)"
	@chmod +x $(SCRIPTS_DIR)/privacy.sh
	@$(SCRIPTS_DIR)/privacy.sh

macos-all: macos-defaults macos-privacy ## Apply all macOS settings
	@echo "$(BOLD)$(GREEN)==> All macOS settings applied$(RESET)"
	@echo "$(YELLOW)Note: Some changes may require a restart$(RESET)"

##@ Backup & Recovery

backup: ## Backup all existing dotfiles
	@echo "$(BOLD)$(CYAN)==> Backing up existing dotfiles to $(BACKUP_DIR)...$(RESET)"
	@mkdir -p $(BACKUP_DIR)
	@if [ -f $(HOME)/.bash_profile ]; then \
		cp $(HOME)/.bash_profile $(BACKUP_DIR)/.bash_profile.backup.$$(date +%Y%m%d_%H%M%S); \
		echo "$(GREEN)==> Backed up .bash_profile$(RESET)"; \
	fi
	@if [ -f $(HOME)/.psqlrc ]; then \
		cp $(HOME)/.psqlrc $(BACKUP_DIR)/.psqlrc.backup.$$(date +%Y%m%d_%H%M%S); \
		echo "$(GREEN)==> Backed up .psqlrc$(RESET)"; \
	fi
	@if [ -f $(HOME)/.gitconfig ]; then \
		cp $(HOME)/.gitconfig $(BACKUP_DIR)/.gitconfig.backup.$$(date +%Y%m%d_%H%M%S); \
		echo "$(GREEN)==> Backed up .gitconfig$(RESET)"; \
	fi
	@echo "$(GREEN)==> Backup complete!$(RESET)"

backup-bash:
	@if [ -f $(HOME)/.bash_profile ]; then \
		mkdir -p $(BACKUP_DIR); \
		cp $(HOME)/.bash_profile $(BACKUP_DIR)/.bash_profile.backup.$$(date +%Y%m%d_%H%M%S); \
	fi

backup-psql:
	@if [ -f $(HOME)/.psqlrc ]; then \
		mkdir -p $(BACKUP_DIR); \
		cp $(HOME)/.psqlrc $(BACKUP_DIR)/.psqlrc.backup.$$(date +%Y%m%d_%H%M%S); \
	fi

backup-gitconfig:
	@if [ -f $(HOME)/.gitconfig ]; then \
		mkdir -p $(BACKUP_DIR); \
		cp $(HOME)/.gitconfig $(BACKUP_DIR)/.gitconfig.backup.$$(date +%Y%m%d_%H%M%S); \
	fi

##@ Utilities

check: ## Check what's already installed
	@echo "$(BOLD)$(CYAN)==> Checking installation status...$(RESET)"
	@echo ""
	@echo "$(BOLD)Package Managers:$(RESET)"
	@if command -v brew >/dev/null 2>&1; then \
		echo "  $(GREEN)✓$(RESET) Homebrew - $$(brew --version | head -n1)"; \
	else \
		echo "  $(RED)✗$(RESET) Homebrew"; \
	fi
	@echo ""
	@echo "$(BOLD)Development Tools:$(RESET)"
	@if command -v git >/dev/null 2>&1; then \
		echo "  $(GREEN)✓$(RESET) Git - $$(git --version)"; \
	else \
		echo "  $(RED)✗$(RESET) Git"; \
	fi
	@if command -v ruby >/dev/null 2>&1; then \
		echo "  $(GREEN)✓$(RESET) Ruby - $$(ruby --version | cut -d' ' -f2)"; \
	else \
		echo "  $(RED)✗$(RESET) Ruby"; \
	fi
	@if command -v psql >/dev/null 2>&1; then \
		echo "  $(GREEN)✓$(RESET) PostgreSQL - $$(psql --version)"; \
	else \
		echo "  $(RED)✗$(RESET) PostgreSQL"; \
	fi
	@echo ""
	@echo "$(BOLD)Configuration Files:$(RESET)"
	@if [ -f $(HOME)/.bash_profile ]; then \
		echo "  $(GREEN)✓$(RESET) .bash_profile"; \
	else \
		echo "  $(RED)✗$(RESET) .bash_profile"; \
	fi
	@if [ -f $(HOME)/.gitconfig ]; then \
		echo "  $(GREEN)✓$(RESET) .gitconfig"; \
	else \
		echo "  $(RED)✗$(RESET) .gitconfig"; \
	fi
	@if [ -f $(HOME)/.psqlrc ]; then \
		echo "  $(GREEN)✓$(RESET) .psqlrc"; \
	else \
		echo "  $(RED)✗$(RESET) .psqlrc"; \
	fi
	@echo ""

clean: ## Remove backup files
	@echo "$(BOLD)$(YELLOW)==> Removing backup files...$(RESET)"
	@if [ -d "$(BACKUP_DIR)" ]; then \
		rm -rf $(BACKUP_DIR); \
		echo "$(GREEN)==> Backup directory removed$(RESET)"; \
	else \
		echo "$(YELLOW)==> No backup directory found$(RESET)"; \
	fi
