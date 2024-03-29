/*
    SPDX-FileCopyrightText: 2024 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier:  GPL-3.0-or-later
*/

#include "displaykdirmodel.h"
#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>

void DisplayKDirModel::setBasePath(const QString &path) {
	if (path == m_basePath) {
		return;
	}
	m_basePath = path;
	QFileSystemModel::setRootPath(m_basePath);

	Q_EMIT basePathChanged();
}

void DisplayKDirModel::setNotePath(const QString &path) {
	if (path == m_notePath) {
		return;
	}
	m_notePath = path;
	Q_EMIT notePathChanged();
}

QHash<int, QByteArray> DisplayKDirModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[DisplayRole] = "display";
    roles[PathRole] = "filePath";
    roles[IsDirRole] = "isDirectory";
    return roles;
}

QVariant DisplayKDirModel::data(const QModelIndex &index, int role) const {
	//qWarning() << "dkdm: data: " << index << ", role: " << role;

	switch (role) {
		case DisplayRole:
			{
				return QFileSystemModel::data(index, QFileSystemModel::FileNameRole);
			}
		case PathRole:
			{
				QVariant path = QFileSystemModel::data(index, QFileSystemModel::FilePathRole);
				//qWarning() << "dkdm path:: " << path;
				return path;
			}
		case IsDirRole:
			{
				return QFileSystemModel::isDir(index);
			}
	}

	qWarning() << "Invalid role requested: " << role << "(index: " << index << ")";
	return QVariant();
}

void DisplayKDirModel::cdUp() {
	// note: somewhat unintuitively, QFileInfo::path() gives the containing directory
	setBasePath(QFileInfo(m_basePath).path());
}

QDir DisplayKDirModel::getBaseDir(const QString &path) {
	QFileInfo info(path);
	if (info.isDir()) {
		return QDir(info.absoluteFilePath());
	}
	return info.dir();
}

void DisplayKDirModel::openExternally(const QString &path) {
	QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void DisplayKDirModel::openContainingFolder(const QString &path) {
	QString containingPath = QFileInfo(path).absolutePath();
	QDesktopServices::openUrl(QUrl::fromLocalFile(containingPath));
}

void DisplayKDirModel::newFile(const QString &dirPath, const QString &name) {
	QString path = getBaseDir(dirPath).absolutePath();
	path += QChar::fromLatin1('/') + name;
	QFile file(path);
	if (file.exists()) {
		Q_EMIT notificationForUser(QStringLiteral("%1 already exists").arg(path));
		//qWarning() << "File " << path << " already exists";
		return;
	}
	if (!file.open(QIODevice::WriteOnly | QIODevice::NewOnly)) {
		qWarning() << "Couldn't open file " << path;
		return;
	}
	file.close();
}

void DisplayKDirModel::newDir(const QString &dirPath, const QString &name) {
	QDir dir(getBaseDir(dirPath));
	if (dir.exists(name)) {
		Q_EMIT notificationForUser(QStringLiteral("%1/%2 already exists").arg(dirPath).arg(name));
		//qWarning() << "Dir " << name << " already exists";
		return;
	}
	dir.mkdir(name);
}

