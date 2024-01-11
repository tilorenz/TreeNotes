/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "notemodel.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>

void NoteModel::setNotePath(const QString &path) {
	if (path == m_notePath) {
		return;
	}
	m_notePath = path;

	if (m_file.isOpen()) {
		m_file.close();
	}

	m_file.setFileName(path);
	if (!m_file.open(QIODevice::ReadWrite | QIODevice::Text)) {
		qWarning() << "Couldn't open file: " << path;
		Q_EMIT notePathChanged();
		return;
	}

	if (m_file.exists()) {
		m_text = QString::fromUtf8((m_file.read(MAX_FILE_SIZE)));
	} else {
		qInfo() << "File doesn't exist: " << path;
		m_text = QStringLiteral("");
	}
	m_textSetFromModel = true;
	Q_EMIT textChanged();

	Q_EMIT notePathChanged();
}

void NoteModel::setBasePath(const QString &path) {
	if (path == m_basePath) {
		return;
	}
	m_basePath = path;
	Q_EMIT basePathChanged();
}

void NoteModel::setText(const QString &text) {
	if (text == m_text) {
		return;
	}
	m_text = text;
	m_textSetFromModel = false;
	Q_EMIT textChanged();
}

QString NoteModel::getDefaultBasePath() {
	return QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).first();
}

void NoteModel::save() {
	if (!m_file.isOpen()) {
		// if we have no open file, construct a fallback path and open it
		QDir dir;
		if (!dir.mkpath(m_basePath)) {
			qWarning() << "Base path doesn't exist and can't make it: " << m_basePath;
			return;
		}
		// Note20240123-134523.md
		QString noteName = QDateTime::currentDateTime().toString(QStringLiteral("'/Note'yyyyMMdd-hhmmss'.md'"));
		m_file.setFileName(m_basePath + noteName);
		if (!m_file.open(QIODevice::ReadWrite | QIODevice::Text)) {
			qWarning() << "Couldn't open fallback file " << m_basePath + noteName;
			return;
		}
		Q_EMIT notePathChanged();
	}

	m_file.write(m_text.toUtf8());
	m_file.flush();
}


