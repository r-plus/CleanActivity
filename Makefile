ARCHS = armv7
TARGET = iphone:clang::6.0
include theos/makefiles/common.mk

TWEAK_NAME = CleanActivity
CleanActivity_FILES = Tweak.xm
CleanActivity_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
