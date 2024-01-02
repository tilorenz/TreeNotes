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

Q_SIGNALS:
	void urlChanged();

private:
	QUrl m_url;
};

#endif
