cmake_minimum_required(VERSION 3.20)
project(oceanraid_room_server VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(oceanraid_engine
    src/FishingEngine.cpp
    src/Room.cpp
)
target_include_directories(oceanraid_engine PUBLIC include)

add_executable(oceanraid_room_server src/main.cpp)
target_link_libraries(oceanraid_room_server PRIVATE oceanraid_engine)

enable_testing()
add_executable(oceanraid_engine_test tests/engine_test.cpp)
target_link_libraries(oceanraid_engine_test PRIVATE oceanraid_engine)
add_test(NAME oceanraid_engine_test COMMAND oceanraid_engine_test)
