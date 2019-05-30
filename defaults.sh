# Nice to Adds
# Keyboard Shortcuts:
#   F6 selects Chrome/Mozilla Search bar

# ----- FINDER --------------------------------------------------------- #

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Set 'home directory' as default, new window directory
defaults write com.apple.finder NewWindowTarget -string "PfHm"



# ----- DOCK ----------------------------------------------------------- #

# Set Dock size
defaults write com.apple.dock tilesize -int 35

# Auto-hide Dock
defaults write com.apple.dock autohide -int 1

# Disable animations
defaults write com.apple.dock launchanim -int 0

# Disable minimizing windows into their application’s icon
defaults write com.apple.dock minimize-to-application -int 0

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -int 1



# ----- KEYBOARD ------------------------------------------------------- #

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false



# ----- OTHER ---------------------------------------------------------- #

# Disable transparency
defaults read com.apple.universalaccess reduceTransparency -bool true

# Enable Dark Mode
defaults write NSGlobalDomain AppleInterfaceStyle Dark

# Reset icons order in Dashboard
defaults write com.apple.dock ResetLaunchPad -bool true

# Show battery percentage in Menu Bar
defaults write com.apple.menuextra.battery ShowPercent YES

# Ask to kepp change when closing documents
defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -int 1

# Set date format in menubar
defaults write "com.apple.menuextra.clock" DateFormat -string "EEE d.MM  HH:mm"

applications_to_kill=(
  "Activity Monitor"
  "Dock"
  "Finder"
)

killall "${applications_to_kill[@]}"
