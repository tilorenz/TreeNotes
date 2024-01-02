add_library(treenotesplugin SHARED
	treenotesplugin.cpp
	displaykdirmodel.cpp
)

target_link_libraries(treenotesplugin
	KF6::KIOWidgets
	KF6::I18n
	Qt6::Gui
	Qt6::Qml
)

install(TARGETS treenotesplugin DESTINATION ${KDE_INSTALL_QMLDIR}/com/github/tilorenz/treenotes)
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/com/github/tilorenz/treenotes)

