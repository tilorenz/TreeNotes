/*
    SPDX-FileCopyrightText: 2024 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier:  GPL-3.0-or-later
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
		basePath: Plasmoid.configuration.basePath

		// handle signals manually to make bidirectional binding
		onNotePathChanged: {
			//console.log('dm np changed')
			noteModel.notePath = notePath
		}
		onBasePathChanged: noteModel.basePath = basePath
	}

	TreeNotesPlugin.NoteModel {
		id: noteModel
		basePath: Plasmoid.configuration.basePath

		onNotePathChanged: {
			dirModel.notePath = notePath
			plasmoid.configuration.notePath = notePath
			//console.log('nm np changed')
		}
		onBasePathChanged: {
			dirModel.basePath = basePath
			Plasmoid.configuration.basePath = basePath
		}
	}

	Component.onCompleted: {
		if (Plasmoid.configuration.basePath === "") {
			console.log('Base path empty, setting to default')
			Plasmoid.configuration.basePath = noteModel.getDefaultBasePath()
		}
		Plasmoid.configuration.valueChanged.connect((key, value) => {
			if (key === "basePath") {
				noteModel.basePath = Plasmoid.configuration.basePath
				//console.log("changing basePath::")
			}
		});
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

				Component.onCompleted: {
					fileTree.rootIndex = dirModel.indexForPath(dirModel.basePath)
				}

				Connections {
					target: dirModel
					function onBasePathChanged() {
						console.log("bpc, connection", dirModel.basePath)
						fileTree.rootIndex = dirModel.indexForPath(dirModel.basePath)
					}
				}

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
					id: treeDelegate
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
						contextMenu.row = row
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
					property int row
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
							nameQuerySheet.show(contextMenu.path, false)
						}
					}
					MenuItem {
						text: "New directory"
						onTriggered: {
							nameQuerySheet.show(contextMenu.path, true)
						}
					}
					MenuItem {
						text: "Set as root directory"
						visible: contextMenu.isDirectory
						onTriggered: {
							fileTree.rootIndex = fileTree.index(contextMenu.row, 0)
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
				Connections {
					target: dirModel
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

		Kirigami.OverlaySheet {
			id: nameQuerySheet
			property bool isForDir: false
			property string path

			function show(path, isForDir) {
				nameQuerySheet.path = path
				nameQuerySheet.isForDir = isForDir
				nameInputField.text = ""
				visible = true
				nameInputField.forceActiveFocus()
			}

			function acceptInput() {
				if (isForDir) {
					dirModel.newDir(path, nameInputField.text)
				} else {
					dirModel.newFile(path, nameInputField.text)
				}
				visible = false
			}

			title: isForDir ? "Create new Directory" :  "Create new Note"
			implicitWidth: fRep.width * 0.8

			ColumnLayout {
				id: dialogColumn

				TextField {
					id: nameInputField
					Layout.fillWidth: true
					placeholderText: nameQuerySheet.isForDir ? "DirectoryName" : "FileName.md"
					onAccepted: nameQuerySheet.acceptInput()
				}

				RowLayout {
					id: dialogButtonRow
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignRight

					Button {
						text: "Ok"
						icon.name: "dialog-ok"
						Layout.alignment: Qt.AlignRight
						enabled: nameInputField.text.length > 0
						onClicked: nameQuerySheet.acceptInput()
					}
					Button {
						text: "Cancel"
						icon.name: "dialog-cancel"
						Layout.alignment: Qt.AlignRight
						onClicked: nameQuerySheet.visible = false
					}
				}
			}
		}
    }
}

