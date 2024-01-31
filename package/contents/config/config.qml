/*
    SPDX-FileCopyrightText: 2024 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier:  GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
	ConfigCategory {
		name: i18n("General")
		icon: "preferences-desktop-plasma"
		source: "config/configGeneral.qml"
	}
}

