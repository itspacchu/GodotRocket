project(PIDLib CXX)

add_library(PIDLib SHARED
            library.cpp
            pid.hpp
            pid.cpp
            )

target_link_libraries(PIDLib PUBLIC godot-cpp)

target_include_directories(PIDLib
                           PUBLIC
                           $<INSTALL_INTERFACE:include>
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                           PRIVATE
                           ${CMAKE_CURRENT_SOURCE_DIR}
                           )