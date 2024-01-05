/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

import com.github.tilorenz.treenotes as TreeNotesPlugin

PlasmoidItem {
	TreeNotesPlugin.DirModel {
		id: dirMod
		url: new URL("file:///tmp/")
	}

    fullRepresentation: ColumnLayout {
        anchors.fill: parent

		TreeView {
			id: fileTree
			model: dirMod
			clip: true
			Layout.fillWidth: true
			Layout.fillHeight: true

			delegate: TreeViewDelegate { }
		}

    }
}

