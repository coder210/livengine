cmake_minimum_required(VERSION 3.16)

set(PROJECT_NAME livnet)

project(${PROJECT_NAME} LANGUAGES C VERSION "3.2.6")

#本工程支持的C版本
set(ENABLE_LIVNET_CLASSIC_MONO OFF)

# 可选：设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

link_directories(${CMAKE_BINARY_DIR}/bin)

if (${CMAKE_BUILD_TYPE} MATCHES "Release")
	set(BUILD_TYPE_STR "Release")
else()
	set(BUILD_TYPE_STR "Debug")
endif()

if (MSVC)
    set(CompilerFlags
        CMAKE_CXX_FLAGS
        CMAKE_CXX_FLAGS_DEBUG
        CMAKE_CXX_FLAGS_RELEASE
        CMAKE_C_FLAGS
        CMAKE_C_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE
        )
    foreach(CompilerFlag ${CompilerFlags})
        string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
    endforeach()
endif(MSVC)


add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/3rd/SDL)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/livnet)


file(GLOB LIBS "./assets/lib")
file(GLOB LUALIB "./assets/lualib")
file(GLOB RESOURCES "./assets/resources")
file(GLOB SCRIPTS "./assets/scripts")


# 仅在VS环境下添加C#项目
if(CMAKE_GENERATOR MATCHES "Visual Studio")

    	enable_language(CSharp)
	
	file(GLOB LIVLIB_FILES "cslib/Livlib/*.cs" "cslib/Livlib/Native/*.cs" "cslib/Livlib/FixMath/*.cs"  "cslib/Livlib/Collision/*.cs")
	add_library(Livlib SHARED ${LIVLIB_FILES})
	
	file(GLOB TEST1_FILES "cslib/Test1/*.cs")
    	add_library(Test1 SHARED ${TEST1_FILES})
	file(GLOB TEST2_FILES "cslib/Test2/*.cs")
    	add_library(Test2 SHARED ${TEST2_FILES})

	file(GLOB ASPOSEXLSTEST_FILES "cslib/AsposeXlsTest/*.cs")
    	add_executable(AsposeXlsTest ${ASPOSEXLSTEST_FILES})

	file(GLOB SPIREXLSTEST_FILES "cslib/SpireXlsTest/*.cs")
    	add_library(SpireXlsTest SHARED ${SPIREXLSTEST_FILES})


	set_property(TARGET Livlib PROPERTY DOTNET_TARGET_FRAMEWORK_VERSION)
	set_property(TARGET Test1 PROPERTY DOTNET_TARGET_FRAMEWORK_VERSION)
	set_property(TARGET Test2 PROPERTY DOTNET_TARGET_FRAMEWORK_VERSION)
	set_property(TARGET AsposeXlsTest PROPERTY DOTNET_TARGET_FRAMEWORK_VERSION)
	set_property(TARGET SpireXlsTest PROPERTY DOTNET_TARGET_FRAMEWORK_VERSION)

	#Aspose.Cells.dll
	set_property(TARGET Livlib PROPERTY VS_DOTNET_REFERENCE_NewtonsoftJson "lib/mono/4.5/Newtonsoft.Json.dll")
	set_property(TARGET AsposeXlsTest PROPERTY  VS_DOTNET_REFERENCE_AsposeCells "lib/mono/4.5/Aspose.Cells.dll")
	set_property(TARGET SpireXlsTest PROPERTY  VS_DOTNET_REFERENCE_AsposeCells "lib/mono/4.5/Aspose.Cells.dll")
	set_property(TARGET Test1 PROPERTY  VS_DOTNET_REFERENCE_AsposeCells "lib/mono/4.5/Aspose.Cells.dll")

	# 如果需要可以添加项目间依赖
	add_dependencies(Test1 Livlib)
	add_dependencies(Test2 Livlib)
	# NuGet包

	file(COPY ${LIBS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME})
	file(COPY ${LUALIB} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME})
	file(COPY ${RESOURCES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME})
	file(COPY ${SCRIPTS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME})
endif()


if(CMAKE_SYSTEM_NAME MATCHES "Linux")
	file(COPY ${LIBS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin)
	file(COPY ${LUALIB} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin)
	file(COPY ${RESOURCES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin)
	file(COPY ${SCRIPTS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin)
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
	file(COPY ${LIBS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin/${BUILD_TYPE_STR})
	file(COPY ${LUALIB} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin/${BUILD_TYPE_STR})
	file(COPY ${RESOURCES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin/${BUILD_TYPE_STR})
	file(COPY ${SCRIPTS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin/${BUILD_TYPE_STR})
else() 
	message("current Platform: unkonw")
endif()

message(${BUILD_TYPE_STR})
message(${CMAKE_CURRENT_SOURCE_DIR})
message(${CMAKE_CURRENT_BINARY_DIR})
message(${CMAKE_BINARY_DIR})
