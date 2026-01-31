cmake_minimum_required(VERSION 3.16)

set(LIVNET_PROJECT_NAME livnet)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_C_STANDARD_REQUIRED ON)

if(ANDROID)
    # Android环境
    message(STATUS "Building for Android")
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../SDL/include)
else()
    # 非Android环境
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../3rd/SDL/include)
endif()

#set(LUA_FILES "external/lua/*.h" "external/lua/*.c") 
#set(MUJS_FILES "external/mujs/*.h" "external/mujs/*.c") 
#set(KLIB_FILES "external/klib/*.h" "external/klib/*.c") 
#file(GLOB PROJECT_FILES "external/*.h" "external/*.c" ${LUA_FILES} ${MUJS_FILES} ${KLIB_FILES} "*.h" "*.c")
file(GLOB PROJECT_FILES "liv-main.c")

add_executable(${LIVNET_PROJECT_NAME} ${PROJECT_FILES})


if(CMAKE_SYSTEM_NAME MATCHES "Linux")
	if(EMSCRIPTEN)
		target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE ./bin/SDL3-static -lm)	
    else()
		target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3-shared -lm)	
	endif()
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
 	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
 	add_definitions(-D_WINSOCK_DEPRECATED_NO_WARNINGS)

	if(ENABLE_LIVNET_CLASSIC_MONO)
		message("enable classic mono")
		add_definitions(-DLIVNET_CLASSIC_MONO)
		# libmono-static-sgen.lib winmm.lib ws2_32.lib Version.lib Bcrypt.lib
		target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3-shared libmono-static-sgen ws2_32 Bcrypt Winmm setupapi Imm32 Version)
	else()
		target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3-shared ws2_32 Bcrypt Winmm setupapi Imm32 Version)
	endif()
	elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")  # macOS ��֧
    message("current Platform: macOS")
    
    # macOS �ض�����
    find_library(COCOA_LIBRARY Cocoa)
    find_library(METAL_LIBRARY Metal)
    find_library(QUARTZCORE_LIBRARY QuartzCore)
    find_library(COREAUDIO_LIBRARY CoreAudio)
    find_library(AUDIOTOOLBOX_LIBRARY AudioToolbox)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    find_library(FORCEFEEDBACK_LIBRARY ForceFeedback)
    find_library(IOKIT_LIBRARY IOKit)
    find_library(CARBON_LIBRARY Carbon)
    
    # ���� macOS ���
    target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE
        SDL3-shared
        ${COCOA_LIBRARY}
        ${METAL_LIBRARY}
        ${QUARTZCORE_LIBRARY}
        ${COREAUDIO_LIBRARY}
        ${AUDIOTOOLBOX_LIBRARY}
        ${COREFOUNDATION_LIBRARY}
        ${FORCEFEEDBACK_LIBRARY}
        ${IOKIT_LIBRARY}
        ${CARBON_LIBRARY}
    )
    
    if(ENABLE_LIVNET_CLASSIC_MONO)
        message("enable classic mono for macOS")
        add_definitions(-DLIVNET_CLASSIC_MONO)
        find_library(MONO_LIBRARY mono-2.0)
        if(MONO_LIBRARY)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE ${MONO_LIBRARY})
        else()
            message(WARNING "Mono library not found on macOS")
        endif()
    endif()
    
    set_target_properties(${LIVNET_PROJECT_NAME} PROPERTIES
        MACOSX_RPATH ON
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "@executable_path"
    )
else() 
	message("current Platform: unkonw")
endif()

source_group(TREE "${CMAKE_SOURCE_DIR}" FILES ${PROJECT_FILES})
