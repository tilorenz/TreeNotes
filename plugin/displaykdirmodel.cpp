/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "displaykdirmodel.h"

void DisplayKDirModel::setUrl(QUrl url) {
	if (url == m_url) {
		return;
	}
	m_url = url;
	KDirModel::openUrl(m_url);
	Q_EMIT urlChanged();
}

