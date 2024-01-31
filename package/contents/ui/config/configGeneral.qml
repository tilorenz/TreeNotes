/*
    SPDX-FileCopyrightText: 2024 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier:  GPL-3.0-or-later
*/

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs as QQDialogs

KCM.SimpleKCM {
	id: configGeneralRoot

	property alias cfg_wrapLines: wrapLines.checked
	property alias cfg_renderMarkdown: renderMarkdown.checked
	property alias cfg_basePath: basePathField.text

	Kirigami.FormLayout {
		id: layoutGeneral

		CheckBox {
			id: wrapLines
			text: "Wrap long lines"
		}
		CheckBox {
			id: renderMarkdown
			text: "Render Markdown"
		}

		RowLayout {
			TextField {
				id: basePathField
			}

			Button {
				id: basePathChooserBtn
				icon.name: "document-open"
				onClicked: {
					basePathDialog.show()
				}
			}
		}
	}

	QQDialogs.FolderDialog {
		id: basePathDialog
		function show() {
			// having QUrl exposed to QML would be too clean and easy -.-
			var u = new URL("file://" + cfg_basePath)
			currentFolder = u
			selectedFolder = u

			open()
		}

		onAccepted: {
			var u = new URL(selectedFolder)
			basePathField.text = u.pathname
		}
	}
}

