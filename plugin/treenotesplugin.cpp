/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "treenotesplugin.h"
#include "displaykdirmodel.h"

// KF
#include <KLocalizedString>
// Qt
#include <QQmlEngine>
#include <QLatin1String>

//static QJSValue singletonTypeExampleProvider(QQmlEngine* engine, QJSEngine* scriptEngine)
//{
    //Q_UNUSED(engine)

    //QJSValue helloWorld = scriptEngine->newObject();
    //helloWorld.setProperty(QLatin1String("text"), i18n("Hello world!"));
    //return helloWorld;
//}


void TreeNotesPlugin::registerTypes(const char* uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("com.github.tilorenz.treenotes"));

	qmlRegisterType<DisplayKDirModel>(uri, 1, 0, "DirModel");
}

#include "moc_treenotesplugin.cpp"
