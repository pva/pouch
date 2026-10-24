# Resolve required CPU dependencies before upstream's FetchContent wrappers.
# In particular Boost::mp11 must exist before the unconditional Populate call.
# Missing system packages must fail instead of triggering source downloads.
find_package(absl CONFIG REQUIRED)
find_package(Boost 1.82 CONFIG REQUIRED)
if(NOT TARGET Boost::mp11)
    add_library(Boost::mp11 ALIAS Boost::headers)
endif()
find_package(cpuinfo CONFIG REQUIRED)
find_package(date 3 CONFIG REQUIRED)
find_package(Eigen3 3.4 CONFIG REQUIRED)
find_package(flatbuffers 23.5.9 CONFIG REQUIRED)
if(NOT TARGET flatbuffers::flatbuffers)
    add_library(flatbuffers::flatbuffers ALIAS flatbuffers::flatbuffers_shared)
endif()
find_package(Microsoft.GSL 4.2.1 CONFIG REQUIRED)
find_package(nlohmann_json 3.11.3 CONFIG REQUIRED)
find_package(Protobuf CONFIG REQUIRED)
find_package(re2 CONFIG REQUIRED)
find_package(ONNX 1.23.1 CONFIG REQUIRED)
find_path(safeint_SOURCE_DIR NAMES SafeInt.hpp REQUIRED)

# Abseil's config accepts only its exact LTS version. The minimum version is
# enforced by Portage; let FetchContent reuse the installed LTS too.
include(FetchContent)
FetchContent_Declare(abseil_cpp FIND_PACKAGE_ARGS CONFIG REQUIRED NAMES absl)
