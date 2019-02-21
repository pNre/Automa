TARGET = iphone:clang::7.0

include theos/makefiles/common.mk

export ARCHS = armv7 arm64

# this is baaad
THEOS_INCLUDE_PATH = include -I .. -I ../include -I /opt/theos/include

BUNDLE_NAME = AutomaPrefs
AutomaPrefs_FILES = AutomaPrefs.m AutomaAlerts.m AutomaAlertsTableViewManager.xm
AutomaPrefs_INSTALL_PATH = /Library/PreferenceBundles
AutomaPrefs_FRAMEWORKS = UIKit CoreGraphics
AutomaPrefs_PRIVATE_FRAMEWORKS = Preferences
AutomaPrefs_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Automa$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Automa/Automa.plist$(ECHO_END)
	$(ECHO_NOTHING)cp -R ../Localizations/* $(THEOS_STAGING_DIR)/Library/PreferenceBundles/AutomaPrefs.bundle$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name '*.DS_Store' -type f -delete$(ECHO_END)
