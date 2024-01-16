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

	Q_PROPERTY(QString notePath READ notePath WRITE setNotePath NOTIFY notePathChanged)
	Q_PROPERTY(QString basePath READ basePath WRITE setBasePath NOTIFY basePathChanged)

public:
	DisplayKDirModel(QObject *parent = nullptr) :
		KDirModel(parent)
	{

	}

	enum Roles{
		DisplayRole = Qt::DisplayRole,
		PathRole = Qt::UserRole,
		IsDirRole,
	};

	QHash<int, QByteArray> roleNames() const override;
	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

	QString notePath() {
		return m_notePath;
	}

	QString basePath() {
		return m_basePath;
	}

	void setNotePath(const QString &path);
	void setBasePath(const QString &path);

	// We only want the file name
	virtual int columnCount(const QModelIndex &parent = QModelIndex()) const override {
		Q_UNUSED(parent);
		return 1;
	}

	Q_INVOKABLE QString getPath(int row);

Q_SIGNALS:
	void notePathChanged();
	void basePathChanged();

private:
	QString m_notePath;
	QString m_basePath;
};

#endif
