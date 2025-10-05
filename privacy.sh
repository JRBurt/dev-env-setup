#!/bin/bash

###################################################################################################
#                                    PRIVACY & PERFORMANCE                                        #
###################################################################################################

echo "Configuring macOS privacy and performance settings..."

# ----- PRIVACY ---------------------------------------------------------------- #

# Disable Siri
defaults write com.apple.assistant.support "Assistant Enabled" -bool false
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.Siri UserHasDeclinedEnable -bool true

# Disable Siri voice feedback
defaults write com.apple.assistant.backedup "Use device speaker for TTS" -bool false

# Disable personalized advertisements
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

# Disable crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Disable diagnostic data sharing
defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false
defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist ThirdPartyDataSubmit -bool false

# Disable analytics & improvements data
defaults write com.apple.appleseed.FeedbackAssistant Autogather -bool false

# Disable location services (system-wide - requires sudo)
# sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.locationd.plist 2>/dev/null

# Disable Handoff
defaults write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool false
defaults write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool false

# Disable Spotlight indexing for development directories
# Add your project folders here
sudo defaults write /.Spotlight-V100/VolumeConfiguration.plist Exclusions -array-add ~/projects
sudo defaults write /.Spotlight-V100/VolumeConfiguration.plist Exclusions -array-add ~/Library/Caches
sudo defaults write /.Spotlight-V100/VolumeConfiguration.plist Exclusions -array-add ~/.Trash

# Reload Spotlight
sudo killall mds 2>/dev/null
sudo mdutil -i on / 2>/dev/null
sudo mdutil -E / 2>/dev/null


# ----- PERFORMANCE ------------------------------------------------------------ #

# Reduce transparency (improve performance)
defaults write com.apple.universalaccess reduceTransparency -bool true

# Reduce motion (disable animations)
defaults write com.apple.universalaccess reduceMotion -bool true

# Disable window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable animations when opening and closing windows
defaults write NSGlobalDomain NSWindowAnimationsEnabled -bool false

# Disable animations when opening a Quick Look window
defaults write -g QLPanelAnimationDuration -float 0

# Accelerate Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Speed up wake from sleep (reduce hibernation mode)
# Mode 0: Disable hibernation (fastest wake, uses more battery)
# Mode 3: Default (copy RAM to disk, slower wake, saves battery)
sudo pmset -a hibernatemode 0

# Remove the sleep image file to save disk space (optional)
# sudo rm -f /var/vm/sleepimage

# Disable sudden motion sensor (only for SSDs, saves CPU cycles)
sudo pmset -a sms 0


# ----- VISUAL EFFECTS --------------------------------------------------------- #

# Disable smooth scrolling
defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false

# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Disable Dock magnification
defaults write com.apple.dock magnification -bool false

# Speed up Dock auto-hide/show
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5


# ----- SECURITY & PRIVACY ----------------------------------------------------- #

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Disable guest account login
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

# Enable firewall (if not already enabled)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null

# Enable firewall stealth mode
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2>/dev/null

# Disable remote apple events
sudo systemsetup -setremoteappleevents off 2>/dev/null

# Disable remote login (SSH) - comment out if you need SSH
# sudo systemsetup -setremotelogin off 2>/dev/null


# ----- RESTART AFFECTED APPLICATIONS ------------------------------------------ #

applications_to_kill=(
  "Activity Monitor"
  "Dock"
  "Finder"
  "SystemUIServer"
  "cfprefsd"
)

for app in "${applications_to_kill[@]}"; do
  killall "$app" &>/dev/null
done

echo "Privacy and performance settings applied!"
echo "Note: Some changes may require a restart to take full effect."
