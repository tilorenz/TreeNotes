/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef DISPLAYKDIRMODEL_H
#define DISPLAYKDIRMODEL_H

#include <KDirModel>
#include <QUrl>
#include <QDir>

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

	Q_INVOKABLE void openExternally(const QString &path);
	Q_INVOKABLE void openContainingFolder(const QString &path);
	Q_INVOKABLE void newFile(const QString &dirPath, const QString &name);
	Q_INVOKABLE void newDir(const QString &dirPath, const QString &name);

	Q_INVOKABLE void cdUp();

Q_SIGNALS:
	void notePathChanged();
	void basePathChanged();

private:
	// if path is a directory, it is returned.
	// if path is a file, its containing directory is returned.
	static QDir getBaseDir(const QString &path);

	QString m_notePath;
	QString m_basePath;
};

#endif
