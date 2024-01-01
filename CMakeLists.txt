cmake_minimum_required(VERSION 3.16)

project(plasmoid-treenotes)

set(QT_MIN_VERSION "6.6.0")
set(KF6_MIN_VERSION "5.240.0")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)

include(ECMQtDeclareLoggingCategory)
include(ECMGenerateExportHeader)
include(ECMInstallIcons)
include(KDEPackageAppTemplates)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)
include(KDEClangFormat)
include(KDEGitCommitHooks)
include(ECMDeprecationSettings)
include(ECMQmlModule)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    Plasma
    I18n
)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
	Qml
	Gui
    Core
)

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_com.github.tilorenz.treenotes\")
#ecm_add_qml_module(treenotesplugin URI com.github.tilorenz.treenotes)
plasma_install_package(package com.github.tilorenz.treenotes)

add_subdirectory(plugin)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

