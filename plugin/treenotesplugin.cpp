/*
    SPDX-FileCopyrightText: 2023 Tino Lorenz <tilrnz@gmx.net>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "treenotesplugin.h"

// KF
#include <KLocalizedString>
// Qt
#include <QJSEngine>
#include <QQmlEngine>
#include <QQmlContext>
#include <QLatin1String>

static QJSValue singletonTypeExampleProvider(QQmlEngine* engine, QJSEngine* scriptEngine)
{
    Q_UNUSED(engine)

    QJSValue helloWorld = scriptEngine->newObject();
    helloWorld.setProperty(QLatin1String("text"), i18n("Hello world!"));
    return helloWorld;
}


void TreeNotesPlugin::registerTypes(const char* uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("com.github.tilorenz.treenotes"));

    qmlRegisterSingletonType(uri, 1, 0, "HelloWorld", singletonTypeExampleProvider);
}

#include "moc_treenotesplugin.cpp"
