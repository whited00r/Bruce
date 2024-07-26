THEOS_DEVICE_IP = 192.168.1.18
GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

TWEAK_NAME = Bruce
Bruce_FILES = Tweak.xm WD7API.m UIImage+StackBlur.m
Bruce_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk