include(common.pri)
PROJECT_NAME = meego-app-contacts
TEMPLATE = subdirs
CONFIG += ordered
SUBDIRS += lib plugin

QML_FILES = *.qml

OTHER_FILES += $${QML_FILES}

qmlfiles.files += $${QML_FILES}
qmlfiles.path += $$INSTALL_ROOT/usr/share/$${PROJECT_NAME}

desktop.files += contacts-settings.desktop
desktop.path += $$INSTALL_ROOT/usr/share/meego-ux-settings/apps/

INSTALLS += qmlfiles desktop

TRANSLATIONS += *.qml
PROJECT_NAME = meego-app-contacts
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION} &&
dist.commands += git clone . $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}/.git &&
dist.commands += rm -f $${PROJECT_NAME}-$${VERSION}/.gitignore &&
dist.commands += mkdir -p $${PROJECT_NAME}-$${VERSION}/ts &&
dist.commands += lupdate $${TRANSLATIONS} -ts $${PROJECT_NAME}-$${VERSION}/ts/$${PROJECT_NAME}.ts &&
dist.commands += tar jcpvf $${PROJECT_NAME}-$${VERSION}.tar.bz2 $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}
QMAKE_EXTRA_TARGETS += dist
