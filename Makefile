# TARGET_CC = xcrun --sdk iphoneos clang
# TARGET_CXX = xcrun --sdk iphoneos clang++
ARCHS = armv7
TARGET = iphone:latest:5.1
include theos/makefiles/common.mk

TWEAK_NAME = CleanActivity
CleanActivity_FILES = Tweak.xm
CleanActivity_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
