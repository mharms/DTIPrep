#add_subdirectory(src)
#add_subdirectory(gui)

include_directories(${CMAKE_BINARY_DIR}/src)
link_directories(${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

set( DTIPrep_SRCS
  main.cxx
  GMainWindow.cxx
  Dicom2NrrdPanel.cxx
  IntensityMotionCheckPanel.cxx
  ImageView2DPanelWithControls.cxx
  IntensityMotionCheck.cxx
  IntraGradientRigidRegistration.cxx
  InterGradientRigidRegistration.cxx
  RigidRegistration.cxx
  ThreadIntensityMotionCheck.cxx
  ThreadEddyMotionCorrect.cxx
  ThreadDicomToNrrd.cxx
  ThreadDicomSeriesRead.cxx
  FurtherQCThread.cxx
  XmlStreamReader.cxx
  XmlStreamWriter.cxx
  Protocol.cxx
  QCResult.cxx
  UtilBaselineOptimizedAverage.h
  itkDWIBaselineAverager.h
  itkDWIBaselineAverager.hxx
# Utah
  itkDWIHeadMotionEddyCurrentCorrection.cxx
  itkGradientSteepestDescentBaseOptimizer.cxx
  itkGradientSteepestDescentOptimizer.cxx
# Iowa
  itkVectorImageRegisterAffineFilter.h
# MIT
 itkMultiImageRegistrationFilter.cxx
 GradientDescentLineSearchOptimizer.cxx
 DominantDirectional/DominantDirectional_Detector.cxx
 DominantDirectional/Counter.cxx
 DominantDirectional/Point.cxx
 DominantDirectional/Sphere.cxx
 DominantDirectional/SphereIkosahedron.cxx
 DominantDirectional/Triangle.cxx
 DominantDirectional/Vector.cxx
 DominantDirectional/Geometry_Common.cxx
 #
 UtilRegister.cxx
)

file(READ DTIPrep.xml var)

string(REGEX MATCH "<version>.*</version>" ext "${var}")
string(REPLACE "<version>" "" version_number ${ext} )
string(REPLACE "</version>" "" version_number ${version_number})

ADD_DEFINITIONS(-DDTIPREP_VERSION="${version_number}")

generateclp(DTIPrep_SRCS_CLP DTIPrep.xml )
set( DTIPrep_SRCS ${DTIPrep_SRCS} ${DTIPrep_SRCS_CLP} )

set( DTIPrep_MOC_HDRS
  GMainWindow.h
  Dicom2NrrdPanel.h
  IntensityMotionCheckPanel.h
  ImageView2DPanelWithControls.h
  ThreadIntensityMotionCheck.h
  ThreadEddyMotionCorrect.h
  ThreadDicomToNrrd.h
  ThreadDicomSeriesRead.h
  FurtherQCThread.h
  #Combo_Box.h
)

set( DTIPrep_HDRS
  DominantDirectional/DominantDirectional_Detector.h
  DominantDirectional/Counter.h
  DominantDirectional/SphereIkosahedron.h
  DominantDirectional/Point.h
  DominantDirectional/Sphere.h
  DominantDirectional/Triangle.h
  DominantDirectional/Vector.h
  DominantDirectional/Geometry_Common.h
  )


set( DTIPrep_UIS
  gui/MainWindow.ui
  gui/Dicom2NrrdPanel.ui
  gui/IntensityMotionCheckPanel.ui
  gui/ImageView2DPanelWithControls.ui
)

set(DTIPrep_RCCS gui/DTIPrep.qrc)

# generate rules for building source files from the resources
QT4_ADD_RESOURCES(RCC_SRCS ${DTIPrep_RCCS})

QT4_WRAP_UI( UIHeaders ${DTIPrep_UIS} )
QT4_WRAP_CPP( MOCSrcs ${DTIPrep_MOC_HDRS} )

#add_definitions(-DQT_GUI_LIBS -DQT_CORE_LIB -DQT3_SUPPORT)

set_source_files_properties(${DTIPrep_SRCS} PROPERTIES
  OBJECT_DEPENDS "${UIHeaders}")


set( DTIPrep_Libs
  ModuleDescriptionParser
  ${QT_LIBRARIES}
  ${QT_QTDBUS_LIBRARY}
  ${ITK_LIBRARIES}
  ${VTK_LIBRARIES}
  BRAINSCommonLib
  ${ANTs_LIBS}
  ITKOptimizersv4
)

if( VTK_MAJOR_VERSION VERSION_LESS 6 )
  list(APPEND DTIPrep_Libs
       QVTK
      )
endif()

#message(STATUS "XXXXXXX ${DTIPrep_Libs}")

if( DTIPrep_BUILD_SLICER_EXTENSION )
  add_executable( DTIPrep
    ${DTIPrep_SRCS}
    ${UISrcs}
    ${MOCSrcs}
    ${RCC_SRCS}
  )
  target_link_libraries( DTIPrep ${DTIPrep_Libs} )
  add_executable( DTIPrepLauncher Launcher.cxx ${DTIPrep_SRCS_CLP} )
  
  set(HIDDEN_CLI_INSTALL_DIR ${Slicer_INSTALL_CLIMODULES_BIN_DIR}/../hidden-cli-modules )
  install(TARGETS DTIPrep DESTINATION ${HIDDEN_CLI_INSTALL_DIR} )
  install(TARGETS DTIPrepLauncher DESTINATION ${Slicer_INSTALL_CLIMODULES_BIN_DIR} )
else()
  if( UNIX AND NOT APPLE )
    SET( CMAKE_INSTALL_RPATH "\$ORIGIN" )
  endif()
  add_executable( DTIPrep
    MACOSX_BUNDLE
    ${DTIPrep_SRCS}
    ${UISrcs}
    ${MOCSrcs}
    ${RCC_SRCS}
  )
  target_link_libraries( DTIPrep ${DTIPrep_Libs} )
  install(TARGETS
          DTIPrep
                 BUNDLE DESTINATION  bin
                 RUNTIME DESTINATION bin
                 LIBRARY DESTINATION lib
                 ARCHIVE DESTINATION lib/static)


  set(plugin_dest_dir bin)
  set(qtconf_dest_dir bin)
  set(APPS "\${CMAKE_INSTALL_PREFIX}/bin/DTIPrep")
  if(APPLE)
    set(plugin_dest_dir DTIPrep.app/Contents/MacOS)
    set(qtconf_dest_dir DTIPrep.app/Contents/Resources)
    set(APPS "\${CMAKE_INSTALL_PREFIX}/bin/DTIPrep.app")
  endif()
  if(WIN32)
    set(APPS "\${CMAKE_INSTALL_PREFIX}/bin/DTIPrep.exe")
  endif()

  #--------------------------------------------------------------------------------
  # Install needed Qt plugins by copying directories from the qt installation
  # One can cull what gets copied by using 'REGEX "..." EXCLUDE'
  #install(DIRECTORY "${QT_PLUGINS_DIR}/imageformats" DESTINATION ${plugin_dest_dir}/plugins COMPONENT Runtime)

  if(APPLE)
  #--------------------------------------------------------------------------------
  # install a qt.conf file
  # this inserts some cmake code into the install script to write the file
  install(CODE "
    file(WRITE \"\${CMAKE_INSTALL_PREFIX}/bin/${qtconf_dest_dir}/qt.conf\" \"\")
    " COMPONENT Runtime)
  install(CODE "
    execute_process(COMMAND cp -r \"${QT_LIBRARY_DIR}/QtGui.framework/Resources/qt_menu.nib\" \".\" WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/bin/${qtconf_dest_dir})")
  endif()
  #--------------------------------------------------------------------------------
  # Use BundleUtilities to get all other dependencies for the application to work.
  # It takes a bundle or executable along with possible plugins and inspects it
  # for dependencies.  If they are not system dependencies, they are copied.

  set(DIRS
  ${QT_LIBRARY_DIRS}
  ${ITK_DIR}
  ${VTK_DIR}
  ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lib
  )

  # Now the work of copying dependencies into the bundle/package
  # The quotes are escaped and variables to use at install time have their $ escaped
  # An alternative is the do a configure_file() on a script and use install(SCRIPT  ...).
  # Note that the image plugins depend on QtSvg and QtXml, and it got those copied
  # over.
  install(CODE "
     include(BundleUtilities)
      fixup_bundle(\"${APPS}\" \"\${QTPLUGINS}\" \"${DIRS}\")
      " COMPONENT Runtime)


  # To Create a package, one can run "cpack -G DragNDrop CPackConfig.cmake" on Mac OS X
  # where CPackConfig.cmake is created by including CPack
  # And then there's ways to customize this as well
  set(CPACK_BINARY_DRAGNDROP ON)
  include(CPack)
endif()
