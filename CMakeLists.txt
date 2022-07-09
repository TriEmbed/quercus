cmake_minimum_required(VERSION 3.5)

# This example uses an extra component for common functions such as Wi-Fi and Ethernet connection.
set(common_components/protocol)


set(EXTRA_COMPONENT_DIRS $ENV{IDF_PATH}/examples/common_components)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(ant)
