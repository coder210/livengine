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

file(GLOB PROJECT_FILES "liv-main.c")

add_executable(${LIVNET_PROJECT_NAME} ${PROJECT_FILES})

# 首先，需要查找正确的SDL3库目标
if(EMSCRIPTEN)
    message(STATUS "Building for Emscripten with SDL3")
    # Emscripten需要特殊的链接选项
    target_link_options(${LIVNET_PROJECT_NAME} PRIVATE
        -sUSE_SDL=2
        -sALLOW_MEMORY_GROWTH=1
        -sMAX_WEBGL_VERSION=2
        -sMIN_WEBGL_VERSION=2
        -sASYNCIFY
    )
endif()

# 统一的SDL库链接 - 根据你的SDL3配置选择正确的目标
# 注意：SDL3构建生成的目标名通常是 SDL3::SDL3, SDL3-static, 或 SDL3-shared
# 你需要根据SDL3的CMake配置确定正确的目标名

if(CMAKE_SYSTEM_NAME MATCHES "Linux")
    if(EMSCRIPTEN)
        # 对于Emscripten，SDL3通常构建为静态库
        # 首先尝试查找SDL3的CMake目标
        if(TARGET SDL3::SDL3)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3::SDL3 -lm)
        elseif(TARGET SDL3-static)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3-static -lm)
        elseif(TARGET SDL3)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3 -lm)
        else()
            # 如果找不到目标，尝试链接库文件
            find_library(SDL3_LIB NAMES libSDL3.a SDL3 PATHS ${CMAKE_BINARY_DIR}/bin)
            if(SDL3_LIB)
                target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE ${SDL3_LIB} -lm)
            else()
                message(FATAL_ERROR "Cannot find SDL3 library for Emscripten")
            endif()
        endif()
    else()
        # 对于常规Linux，链接共享库
        if(TARGET SDL3::SDL3)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3::SDL3 -lm)
        elseif(TARGET SDL3-shared)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3-shared -lm)
        else()
            find_library(SDL3_LIB NAMES libSDL3.so SDL3 PATHS ${CMAKE_BINARY_DIR}/bin)
            if(SDL3_LIB)
                target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE ${SDL3_LIB} -lm)
            else()
                message(FATAL_ERROR "Cannot find SDL3 library for Linux")
            endif()
        endif()
    endif()
    
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-D_WINSOCK_DEPRECATED_NO_WARNINGS)

    if(ENABLE_LIVNET_CLASSIC_MONO)
        message("enable classic mono")
        add_definitions(-DLIVNET_CLASSIC_MONO)
        target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE 
            SDL3-shared 
            libmono-static-sgen 
            ws2_32 Bcrypt Winmm setupapi Imm32 Version)
    else()
        if(TARGET SDL3::SDL3)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3::SDL3 ws2_32 Bcrypt Winmm setupapi Imm32 Version)
        elseif(TARGET SDL3-shared)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE SDL3-shared ws2_32 Bcrypt Winmm setupapi Imm32 Version)
        else()
            find_library(SDL3_LIB NAMES SDL3.lib SDL3 PATHS ${CMAKE_BINARY_DIR}/bin)
            if(SDL3_LIB)
                target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE ${SDL3_LIB} ws2_32 Bcrypt Winmm setupapi Imm32 Version)
            else()
                message(FATAL_ERROR "Cannot find SDL3 library for Windows")
            endif()
        endif()
    endif()
    
elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")  # macOS
    message("current Platform: macOS")
    
    # macOS 特定库
    find_library(COCOA_LIBRARY Cocoa)
    find_library(METAL_LIBRARY Metal)
    find_library(QUARTZCORE_LIBRARY QuartzCore)
    find_library(COREAUDIO_LIBRARY CoreAudio)
    find_library(AUDIOTOOLBOX_LIBRARY AudioToolbox)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    find_library(FORCEFEEDBACK_LIBRARY ForceFeedback)
    find_library(IOKIT_LIBRARY IOKit)
    find_library(CARBON_LIBRARY Carbon)
    
    # 链接 macOS 库
    if(TARGET SDL3::SDL3)
        target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE
            SDL3::SDL3
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
    elseif(TARGET SDL3-shared)
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
    else()
        find_library(SDL3_LIB NAMES libSDL3.dylib SDL3 PATHS ${CMAKE_BINARY_DIR}/bin)
        if(SDL3_LIB)
            target_link_libraries(${LIVNET_PROJECT_NAME} PRIVATE
                ${SDL3_LIB}
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
        else()
            message(FATAL_ERROR "Cannot find SDL3 library for macOS")
        endif()
    endif()
    
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
    message("current Platform: unknown")
endif()

# 添加显式的依赖关系，确保SDL3在livnet之前构建
if(TARGET SDL3-static)
    add_dependencies(${LIVNET_PROJECT_NAME} SDL3-static)
elseif(TARGET SDL3-shared)
    add_dependencies(${LIVNET_PROJECT_NAME} SDL3-shared)
elseif(TARGET SDL3)
    add_dependencies(${LIVNET_PROJECT_NAME} SDL3)
endif()

source_group(TREE "${CMAKE_SOURCE_DIR}" FILES ${PROJECT_FILES})