/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "displaykdirmodel.h"

void DisplayKDirModel::setBasePath(const QString &path) {
	if (path == m_basePath) {
		return;
	}
	m_basePath = path;
	KDirModel::openUrl(QUrl::fromLocalFile(m_basePath));

	Q_EMIT basePathChanged();
}

void DisplayKDirModel::setNotePath(const QString &path) {
	if (path == m_notePath) {
		return;
	}
	m_notePath = path;
	Q_EMIT basePathChanged();
}

QString DisplayKDirModel::getPath(int row) {
	return itemForIndex(index(row, 0)).localPath();
}

QHash<int, QByteArray> DisplayKDirModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[DisplayRole] = "display";
    roles[PathRole] = "filePath";
    return roles;
}

QVariant DisplayKDirModel::data(const QModelIndex &index, int role) const {
	const KFileItem item = qvariant_cast<KFileItem>(KDirModel::data(index, KDirModel::FileItemRole));

	switch (role) {
		case DisplayRole:
			return item.name();
		case PathRole:
			return item.localPath();
	}

	qWarning() << "Invalid role requested: " << role << "(index: " << index << ")";
	return QVariant();
}



