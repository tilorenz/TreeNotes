/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "notemodel.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>
#include <QFileSystemWatcher>

void NoteModel::setNotePath(const QString &path) {
	if (path == m_notePath) {
		return;
	}
	if (m_watcher.files().contains(m_notePath)) {
		m_watcher.removePath(m_notePath);
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
	m_dirty = false;
	m_textSetFromModel = true;
	Q_EMIT textChanged();

	m_watcher.addPath(path);

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
	m_dirty = true;
	Q_EMIT textChanged();
}

QString NoteModel::getDefaultBasePath() {
	//return QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).first();
	// for testing, I don't want to screw up my actual documents
	return QStringLiteral("/home/tino/pg");
}

QString NoteModel::getAutosavePath() {
	if (m_basePath.isEmpty()) {
		m_basePath = getDefaultBasePath();
		Q_EMIT basePathChanged();
	}
	QDir dir;
	if (!dir.mkpath(m_basePath)) {
		qWarning() << "Base path doesn't exist and can't make it: " << m_basePath;
		return QStringLiteral("");
	}

	// Note20240123-134523.md
	QString noteName = QDateTime::currentDateTime().toString(QStringLiteral("'/Note'yyyyMMdd-hhmmss'.md'"));
	return m_basePath + noteName;
}

void NoteModel::save() {
	// stop watching while we change the file ourself
	if (m_watcher.files().contains(m_notePath)) {
		m_watcher.removePath(m_notePath);
	}

	if (!m_file.isOpen() || (m_file.isOpen() && !m_file.exists())) {
		qWarning() << "File wasn't open or was open but didn't exist";
		m_notePath = getAutosavePath();
		m_file.setFileName(m_notePath);
		if (!m_file.open(QIODevice::ReadWrite | QIODevice::Text)) {
			qWarning() << "Couldn't open fallback file " << m_notePath;
			return;
		}
		Q_EMIT notePathChanged();
	}

	// write will append, so clear the file first
	m_file.resize(0);
	m_file.write(m_text.toUtf8());
	m_file.flush();

	m_dirty = false;
	m_watcher.addPath(m_notePath);
}

void NoteModel::handleFileChangedOnDisk(const QString &filePath) {
	qWarning() << "File changed. m_notePath: " << m_notePath << ", filePath: " << filePath;

	// when the file is moved. the filePath will be the old one
	if (filePath != m_notePath) {
		qWarning() << "File Changed: filePath != notePath. this shouldn't happen.";
		qWarning() << "filePath: " << filePath << ", notePath: " << m_notePath;
		m_watcher.removePath(filePath);
		return;
	}

	if (!m_file.isOpen()) {
		qWarning() << "File changed but wasn't open, this shouldn't happen.";
		return;
	}

	if (!m_file.exists()) {
		// looks like the file has been moved or deleted.
		// inform the user, there's not much more we can do here (I think)
		// if the file is dirty, it'll be autosaved, otherwise nothing else needs to happen
		// TODO make proper warning (in plasmoid or desktop notification or sth)
		qWarning() << "The open file has been moved or deleted.";
		if (m_watcher.files().contains(m_notePath)) {
			m_watcher.removePath(m_notePath);
		}
	}

	// file is still there, so it was modified
	if (m_dirty) {
		// there is a version conflict. attempting to handle this automatically may not be what
		// the user wants, so just save our changes somewhere else and notify the user
		m_file.close();
		m_notePath = getAutosavePath();
		m_file.setFileName(m_notePath);
		if (!m_file.open(QIODevice::ReadWrite | QIODevice::Text)) {
			qWarning() << "Couldn't open fallback file " << m_notePath;
			return;
		}
		Q_EMIT notePathChanged();
		qWarning() << "Note file changed on disk while editing note, saving edits to " << m_notePath;
	} else {
		// we have no unsaved edits, so just reload the file
		m_file.seek(0);
		m_text = QString::fromUtf8((m_file.read(MAX_FILE_SIZE)));
		m_textSetFromModel = true;
		Q_EMIT textChanged();
	}
}


