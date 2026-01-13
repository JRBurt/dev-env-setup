#!/bin/bash

###################################################################################################
#                                    PRIVACY & PERFORMANCE                                        #
###################################################################################################

echo "Configuring macOS privacy and performance settings..."

# ----- PRIVACY ---------------------------------------------------------------- #
defaults write com.apple.assistant.support "Assistant Enabled" -bool false
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.Siri UserHasDeclinedEnable -bool true
defaults write com.apple.assistant.backedup "Use device speaker for TTS" -bool false
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.CrashReporter DialogType -string "none"
defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false
defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist ThirdPartyDataSubmit -bool false
defaults write com.apple.appleseed.FeedbackAssistant Autogather -bool false
# sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.locationd.plist 2>/dev/null
defaults write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool false
defaults write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool false
sudo defaults write /.Spotlight-V100/VolumeConfiguration.plist Exclusions -array-add ~/projects
sudo defaults write /.Spotlight-V100/VolumeConfiguration.plist Exclusions -array-add ~/Library/Caches
sudo defaults write /.Spotlight-V100/VolumeConfiguration.plist Exclusions -array-add ~/.Trash
sudo killall mds 2>/dev/null
sudo mdutil -i on / 2>/dev/null
sudo mdutil -E / 2>/dev/null


# ----- PERFORMANCE ------------------------------------------------------------ #
defaults write com.apple.universalaccess reduceTransparency -bool true
defaults write com.apple.universalaccess reduceMotion -bool true
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowAnimationsEnabled -bool false
defaults write -g QLPanelAnimationDuration -float 0
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dashboard mcx-disabled -bool true
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.LaunchServices LSQuarantine -bool false
sudo pmset -a hibernatemode 0 # 0 fast re-wake, 3 slow re-wake
# sudo rm -f /var/vm/sleepimage
sudo pmset -a sms 0


# ----- VISUAL EFFECTS --------------------------------------------------------- #
defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5


# ----- SECURITY & PRIVACY ----------------------------------------------------- #
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2>/dev/null
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
