#THEOS_DEVICE_IP = 192.168.1.247
#GO_EASY_ON_ME = 1
export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222

TARGET := iphone:clang::7.0
ARCHS := armv7 arm64

ADDITIONAL_CFLAGS += -fvisibility=hidden

TWEAK_NAME = Automa
Automa_FILES = Tweak.x UIKit.x Automa.x NAAlert.m SpringBoard.xm
Automa_FRAMEWORKS = CoreFoundation UIKit CoreGraphics QuartzCore
#Automa_PRIVATE_FRAMEWORKS = BulletinBoard
Automa_LIBRARIES = MobileGestalt

include theos/makefiles/common.mk

# this is baaad
THEOS_INCLUDE_PATH = include -I . -I /opt/theos/include

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

after-clean::
	rm -f *.deb

SUBPROJECTS += AutomaPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
