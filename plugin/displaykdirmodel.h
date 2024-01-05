/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef DISPLAYKDIRMODEL_H
#define DISPLAYKDIRMODEL_H

#include <KDirModel>
#include <QUrl>

class DisplayKDirModel: public KDirModel {
	Q_OBJECT

	Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
	DisplayKDirModel(QObject *parent = nullptr) :
		KDirModel(parent)
	{

	}

	QUrl url() const {
		return m_url;
	}

	void setUrl(QUrl url);

	// For some reason, KDirModel::canFetchMore returns false if the folder is on the network.
	// Also, there is currently a bug in KDirModel that falsely assumes empty URLs are
	// on the network. see:
	// https://invent.kde.org/frameworks/kio/-/issues/29
	// https://invent.kde.org/frameworks/kio/-/merge_requests/1508
	//Q_INVOKABLE bool canFetchMore(const QModelIndex &parent) const override {
		//bool tmp =  hasChildren(parent) && rowCount(parent) == 0;
		//qWarning() << "cfm: " << parent << ": " << tmp;
		//return tmp;
	//}

	// We only want the file name
	virtual int columnCount(const QModelIndex &parent = QModelIndex()) const override {
		Q_UNUSED(parent);
		return 1;
	}

Q_SIGNALS:
	void urlChanged();

private:
	QUrl m_url;
};

#endif
