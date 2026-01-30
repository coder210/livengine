LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := main

# Add your application source files here...
LOCAL_SRC_FILES := \
    $(wildcard $(LOCAL_PATH)/*.c) \
    $(wildcard $(LOCAL_PATH)/external/*.c) \
    $(wildcard $(LOCAL_PATH)/external/lua/*.c) \
    $(wildcard $(LOCAL_PATH)/external/mujs/*.c) \
    $(wildcard $(LOCAL_PATH)/external/klib/*.c) \

SDL_PATH := ../SDL  # SDL
MONO_PATH := ../include #MONO

LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(SDL_PATH)/include  # SDL
LOCAL_C_INCLUDES += $(LOCAL_PATH)/${MONO_PATH}

LOCAL_SHARED_LIBRARIES := SDL3

LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -lOpenSLES -llog -landroid  # SDL

include $(BUILD_SHARED_LIBRARY)
