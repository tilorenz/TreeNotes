import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import QtQuick.Controls as QQC

KCM.SimpleKCM {
	id: configGeneralRoot

	property alias cfg_wrapLines: wrapLines.checked
	property alias cfg_renderMarkdown: renderMarkdown.checked

	Kirigami.FormLayout {
		id: layoutGeneral

		QQC.CheckBox {
			id: wrapLines
			text: "Wrap long lines"
		}
		QQC.CheckBox {
			id: renderMarkdown
			text: "Render Markdown"
		}
	}
}

