ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

ifneq ($(PREBUILT_DYLIB),)
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	mkdir -p "$(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries"
	cp "$(PREBUILT_DYLIB)" "$(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/WCRound.dylib"
	cp WCRound.plist "$(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/WCRound.plist"
else
TWEAK_NAME = WCRound
WCRound_FILES = Tweak.x $(shell find Sources -type f -name '*.m' -o -type f -name '*.x')
WCRound_LOGOS_DEFAULT_GENERATOR = internal
WCRound_OBJCFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR) -fvisibility=hidden
WCRound_FRAMEWORKS = UIKit Foundation QuartzCore UniformTypeIdentifiers

include $(THEOS_MAKE_PATH)/tweak.mk
endif
