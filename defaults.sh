
# ----- FINDER --------------------------------------------------------- #
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder NewWindowTarget -string "PfHm"



# ----- DOCK ----------------------------------------------------------- #
defaults write com.apple.dock tilesize -int 35
defaults write com.apple.dock autohide -int 1
defaults write com.apple.dock launchanim -int 0
defaults write com.apple.dock minimize-to-application -int 0
defaults write com.apple.dock show-process-indicators -int 1



# ----- KEYBOARD ------------------------------------------------------- #
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false



# ----- OTHER ---------------------------------------------------------- #
defaults read com.apple.universalaccess reduceTransparency -bool true
defaults write NSGlobalDomain AppleInterfaceStyle Dark
defaults write com.apple.dock ResetLaunchPad -bool true
defaults write com.apple.menuextra.battery ShowPercent YES
defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -int 1
defaults write "com.apple.menuextra.clock" DateFormat -string "EEE d.MM  HH:mm"

applications_to_kill=(
  "Activity Monitor"
  "Dock"
  "Finder"
)

killall "${applications_to_kill[@]}"
