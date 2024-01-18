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
	hideOnWindowDeactivate: !Plasmoid.configuration.pin

	TreeNotesPlugin.DirModel {
		id: dirModel

		// handle signals manually to make bidirectional binding
		onNotePathChanged: {
			//console.log('dm np changed')
			noteModel.notePath = notePath
		}
		onBasePathChanged: noteModel.basePath = basePath
	}

	TreeNotesPlugin.NoteModel {
		id: noteModel

		onNotePathChanged: {
			dirModel.notePath = notePath
			plasmoid.configuration.notePath = notePath
			//console.log('nm np changed')
		}
		onBasePathChanged: {
			dirModel.basePath = basePath
			plasmoid.configuration.basePath = basePath
		}
	}

	Component.onCompleted: {
		noteModel.basePath = plasmoid.configuration.basePath || noteModel.getDefaultBasePath()
		if (plasmoid.configuration.notePath) {
			noteModel.notePath = plasmoid.configuration.notePath
		}
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

		RowLayout {
			id: topToolBar

			implicitHeight: toggleTreeBtn.height
			Layout.preferredWidth: parent.width

			PlasmaComponents.ToolButton {
				id: toggleTreeBtn
				Layout.alignment: Qt.AlignLeft
				icon.name: fileTree.expanded ? "sidebar-collapse" : "sidebar-expand"
				focusPolicy: Qt.TabFocus
				onClicked: fileTree.toggle()
				PlasmaComponents.ToolTip{
					text: fileTree.expanded ? "Collapse File Tree" : "Expand File tree"
				}
			}

			PlasmaComponents.ToolButton {
				id: cdUpButton
				Layout.alignment: Qt.AlignLeft
				icon.name: "go-up"
				focusPolicy: Qt.TabFocus
				onClicked: dirModel.cdUp()
				PlasmaComponents.ToolTip{
					text: "Directory up"
				}
			}

			//PlasmaComponents.ToolButton {
				//id: expbtn
				//anchors.left: toggleTreeBtn.right
				//icon.name: fileTree.expanded ? "sidebar-collapse" : "sidebar-expand"
				//focusPolicy: Qt.TabFocus
				//onClicked: console.log("exp: ", Plasmoid.formFactor, Plasmoid.location)
				//PlasmaComponents.ToolTip{
					//text: "expand"
				//}
			//}

			PlasmaComponents.ToolButton {
				id: pinButton
				// TODO only show when expanded from panel (use Plasmoid.location ?)
				//visible:
				Layout.alignment: Qt.AlignRight
				checkable: true
				checked: Plasmoid.configuration.pin
				onToggled: Plasmoid.configuration.pin = checked
				icon.name: "window-pin"

				display: PlasmaComponents.AbstractButton.IconOnly
				text: "Keep Open"
				PlasmaComponents.ToolTip {
					text: parent.text
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

				model: dirModel
				clip: true

				selectionBehavior: TableView.SelectionDisabled
				// otherwise, pressAndHold doesn't work
				pointerNavigationEnabled: false

				delegate: TreeViewDelegate {
					onClicked: {
						if (isDirectory) {
							treeView.toggleExpanded(row)
						} else {
							console.log('filepath: ', filePath)
							// if the file was modified by the user, save it before switching to the new file and don't carry the timer over
							if (autoSaveTimer.running) {
								autoSaveTimer.stop()
								noteModel.save()
							}
							noteModel.notePath = filePath
						}
					}
					highlighted: filePath == noteModel.notePath

					function showContextMenu() {
						contextMenu.path = filePath
						contextMenu.isDirectory = isDirectory
						contextMenu.popup()
						//if (isDirectory) {

						//} else {

						//}
					}

					autoRepeat: false
					onPressAndHold: showContextMenu()

					TapHandler {
						acceptedButtons: Qt.RightButton
						onTapped: {
							//console.log('th:', filePath)
							parent.showContextMenu()
						}
					}
				}

				// to get a normal KDE menu, see KFileItemActions
				Menu {
					id: contextMenu
					property string path
					property bool isDirectory
					MenuItem {
						text: "Open externally"
						onTriggered: {
							dirModel.openExternally(contextMenu.path)
						}
					}
					MenuItem {
						text: "Open containing folder externally"
						onTriggered: {
							dirModel.openContainingFolder(contextMenu.path)
						}
					}
					MenuItem {
						text: "New note"
						onTriggered: {
							dirModel.newFile(contextMenu.path, "miau.md")
						}
					}
					MenuItem {
						text: "New directory"
						onTriggered: {
							dirModel.newDir(contextMenu.path, "my dir")
						}
					}
					MenuItem {
						text: "Set as root directory"
						visible: contextMenu.isDirectory
						onTriggered: {
							dirModel.basePath = contextMenu.path
						}
					}
				}
			}

			ScrollView {
				id: txtScroll
				Layout.fillWidth: true

				TextArea {
					id: txt
					//Layout.fillWidth: true
					text: noteModel.text

					onTextChanged: {
						noteModel.text = text
						// only start the autosave timer if the text was changed by the user
						// this prevents overwriting the previously open file since it may have changed on disk
						if (!noteModel.textSetFromModel) {
							autoSaveTimer.restart()
							noteModel.textSetFromModel = false
						}
					}

					textFormat: (noteModel.notePath.endsWith(".md") && plasmoid.configuration.renderMarkdown) ? TextEdit.MarkdownText : TextEdit.PlainText
					wrapMode: plasmoid.configuration.wrapLines ? TextEdit.Wrap : TextEdit.NoWrap

					Timer{
						id: autoSaveTimer
						onTriggered: {
							print("Timer saving")
							noteModel.save()
						}
						//TODO shorter time for testing, use 20s or so for production
						interval: 4000
					}
				}
			}
		}

		RowLayout {
			id: notificationBar
			property bool expanded: false
			clip: true
			Layout.maximumHeight: expanded ? Math.max(notificationLbl.implicitHeight, closeNotificationBtn.implicitHeight) : 0
			Layout.maximumWidth: parent.width

			Behavior on Layout.maximumHeight {
				NumberAnimation {
					duration: Kirigami.Units.shortDuration
					easing.type: Easing.InOutQuad
				}
			}

			Label {
				id: notificationLbl
				Layout.maximumWidth: parent.width - closeNotificationBtn.implicitWidth - parent.spacing
				wrapMode: Text.Wrap

				Connections {
					target: noteModel
					function onNotificationForUser(message) {
						notificationLbl.text = message
						notificationBar.expanded = true
					}
				}
			}

			PlasmaComponents.ToolButton {
				id: closeNotificationBtn
				Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
				icon.name: "dialog-close"
				focusPolicy: Qt.TabFocus
				onClicked: notificationBar.expanded = false
				PlasmaComponents.ToolTip{
					text: "Close notification"
				}
			}
		}
    }
}

