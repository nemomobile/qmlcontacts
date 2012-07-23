VERSION = 0.3.5
PROJECT_NAME = qmlcontacts
TEMPLATE = app
CONFIG += ordered mobility
MOBILITY += contacts
QT += declarative

SOURCES += main.cpp
RESOURCES += res.qrc

QML_FILES = *.qml
JS_FILES = *.js

OTHER_FILES += $${QML_FILES} $${JS_FILES}

desktop.files = $${PROJECT_NAME}.desktop
desktop.path = $$INSTALL_ROOT/usr/share/applications
INSTALLS += desktop

TRANSLATIONS += *.qml
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION} &&
dist.commands += git clone . $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}/.git &&
dist.commands += rm -f $${PROJECT_NAME}-$${VERSION}/.gitignore &&
dist.commands += mkdir -p $${PROJECT_NAME}-$${VERSION}/ts &&
dist.commands += lupdate $${TRANSLATIONS} -ts $${PROJECT_NAME}-$${VERSION}/ts/$${PROJECT_NAME}.ts &&
dist.commands += tar jcpvf $${PROJECT_NAME}-$${VERSION}.tar.bz2 $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}
QMAKE_EXTRA_TARGETS += dist

