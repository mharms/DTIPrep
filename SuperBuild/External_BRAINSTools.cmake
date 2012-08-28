
# Make sure this file is included only once
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Sanity checks
if(DEFINED BRAINSTools_SOURCE_DIR AND NOT EXISTS ${BRAINSTools_SOURCE_DIR})
  message(FATAL_ERROR "BRAINSTools_SOURCE_DIR variable is defined but corresponds to non-existing directory")
endif()

# Set dependency list
set(BRAINSTools_DEPENDENCIES ${ITK_EXTERNAL_NAME} SlicerExecutionModel VTK )

# Include dependent projects if any
SlicerMacroCheckExternalProjectDependency(BRAINSTools)
set(proj BRAINSTools)

# Set CMake OSX variable to pass down the external project
set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
if(APPLE)
  list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
    -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
    -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
endif()

if(NOT DEFINED BRAINSTools_SOURCE_DIR)
  #message(STATUS "${__indent}Adding project ${proj}")
if(${ITK_VERSION_MAJOR} STREQUAL "3")
  set(GIT_TAG "03ce71cca9bbfb1f0da0040b139011211694b1c6")
else()
  set(GIT_TAG "c1f2cd71c33c62d8931029f18aab01960a0b9dbc")
endif()

  if(NOT DEFINED git_protocol)
    set(git_protocol "git")
  endif()

  #message("VTK_DIR: ${VTK_DIR}")
  #message("ITK_DIR: ${ITK_DIR}")
  #message("SlicerExecutionModel_DIR: ${SlicerExecutionModel_DIR}")
  ExternalProject_Add(${proj}
    GIT_REPOSITORY "${git_protocol}://github.com/BRAINSia/BRAINSStandAlone.git"
    GIT_TAG "${GIT_TAG}"
    SOURCE_DIR ${proj}
    BINARY_DIR ${proj}-build
    CMAKE_GENERATOR ${gen}
    "${cmakeversion_external_update}"
    CMAKE_ARGS
      ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
      ${COMMON_EXTERNAL_PROJECT_ARGS}
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DUSE_SYSTEM_ITK:BOOL=ON
      -DUSE_SYSTEM_VTK:BOOL=ON
      -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
      -DITK_DIR:PATH=${ITK_DIR}
      -DVTK_DIR:PATH=${VTK_DIR}
      -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
      ${${proj}_CMAKE_OPTIONS}
    INSTALL_COMMAND ""
    DEPENDS
      ${BRAINSTools_DEPENDENCIES}
    )
  set(BRAINSTools_SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj})
  set(BRAINSCommonLib_DIR    ${CMAKE_BINARY_DIR}/${proj}-build/BRAINSTools-build/BRAINSCommonLib)
else()
  # The project is provided using BRAINSTools_DIR, nevertheless since other project may depend on BRAINSTools,
  # let's add an 'empty' one
  SlicerMacroEmptyExternalProject(${proj} "${BRAINSTools_DEPENDENCIES}")
endif()
