/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

import com.github.tilorenz.treenotes as TreeNotesPlugin

PlasmoidItem {
	id: root

	TreeNotesPlugin.DirModel {
		id: dirMod
		url: new URL("file:///tmp/")
	}

	switchHeight: Kirigami.Units.gridUnit * 10
	switchWidth: Kirigami.Units.gridUnit * 10
	Plasmoid.icon: 'folder-notes-symbolic'

// buttons:
// - toggle tree
// - dir up
// - pin (if expanded)
//
// right click menu of file items:
// - open in external program
// - open containing folder in file manager
// - new dir
// - new file
// - rename???
// - delete (or trash?)??? (these are potentially dangerous, so maybe leave them to a real file manager?)

    fullRepresentation: ColumnLayout {
		id: fRep

		//Layout.minimumHeight: root.switchHeight
		//Layout.minimumWidth: root.switchWidth
		Layout.preferredHeight: Kirigami.Units.gridUnit * 25
		Layout.preferredWidth: Kirigami.Units.gridUnit * 25

		Item {
			id: topToolBar
			//anchors {
				//left: parent.left
				//top: parent.top
				//right: parent.right
			//}

			implicitHeight: toggleTreeBtn.height

			PlasmaComponents.ToolButton {
				id: toggleTreeBtn
				anchors.left: parent.left
				icon.name: fileTree.expanded ? "sidebar-collapse" : "sidebar-expand"
				focusPolicy: Qt.TabFocus
				onClicked: fileTree.toggle()
				PlasmaComponents.ToolTip{
					text: fileTree.expanded ? "Collapse File Tree" : "Expand File tree"
				}
			}
		}

		SplitView {
			id: mainSplit
			Layout.fillWidth: true
			Layout.fillHeight: true

			TreeView {
				id: fileTree
				property bool expanded: true
				// setting the width directly rather than using saveState() / restoreState()
				// allows to animate collapsing and expanding
				property double oldWidth: parent.width * 0.4
				//property var svState
				SplitView.preferredWidth: parent.width * 0.4

				function toggle() {
					if (expanded) {
						oldWidth = width
						//svState = mainSplit.saveState()
						SplitView.preferredWidth = 0
					} else {
						SplitView.preferredWidth = oldWidth
						//mainSplit.restoreState(svState)
					}
					expanded = !expanded
				}

				onWidthChanged: {
					expanded = width != 0
				}

				Behavior on SplitView.preferredWidth {
					NumberAnimation {
						duration: Kirigami.Units.shortDuration
						easing.type: Easing.InOutQuad
					}
				}

				model: dirMod
				clip: true

				delegate: TreeViewDelegate { }
			}

			TextArea {
				id: txt
				Layout.fillWidth: true
			}
		}
    }
}

