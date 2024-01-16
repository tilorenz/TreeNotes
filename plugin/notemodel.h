/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef NOTEMODEL_H
#define NOTEMODEL_H

#include <QFile>
#include <QString>
#include <QByteArray>
#include <QUrl>
#include <qtmetamacros.h>
#include <QFileSystemWatcher>

class NoteModel: public QObject {
	Q_OBJECT

	Q_PROPERTY(QString notePath READ notePath WRITE setNotePath NOTIFY notePathChanged)
	Q_PROPERTY(QString basePath READ basePath WRITE setBasePath NOTIFY basePathChanged)
	Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
	Q_PROPERTY(bool textSetFromModel READ textSetFromModel WRITE setTextSetFromModel)

public:
	NoteModel(QObject *parent = nullptr):
		QObject(parent),
		m_file(QFile(this)),
		m_watcher(this),
		m_textSetFromModel(false),
		m_dirty(false)
	{
		connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, &NoteModel::handleFileChangedOnDisk);
	}

	QString notePath() {
		return m_notePath;
	}

	QString basePath() {
		return m_basePath;
	}

	QString text() {
		return m_text;
	}

	bool textSetFromModel() {
		return m_textSetFromModel;
	}

	void setTextSetFromModel(bool textSetFromModel) {
		m_textSetFromModel = textSetFromModel;
	}

	void setNotePath(const QString &path);
	void setBasePath(const QString &path);
	void setText(const QString &text);

	Q_INVOKABLE void save();
	Q_INVOKABLE QString getDefaultBasePath();

	// only load up to this many bytes. this shouldn't get in the way when working with
	// reasonably sized text files but prevent crashes when accidentally clicking on a 10GB file
	const static int MAX_FILE_SIZE = 100000;

public Q_SLOTS:
	void handleFileChangedOnDisk(const QString &filePath);

Q_SIGNALS:
	void notePathChanged();
	void basePathChanged();
	void textChanged();
	void notificationForUser(const QString &message);

private:
	// returns a path like m_basePath/Note<datetime>.md where things can be saved
	QString getAutosavePath();

	QFile m_file;
	QFileSystemWatcher m_watcher;
	QString m_text;
	QString m_notePath;
	QString m_basePath;
	bool m_textSetFromModel;
	bool m_dirty; // if we have unsaved changes
};

#endif
