include(common.pri)
PROJECT_NAME = qmlcontacts
TEMPLATE = subdirs
CONFIG += ordered mobility
SUBDIRS += lib
MOBILITY += contacts
QT += declarative

QML_FILES = *.qml
JS_FILES = *.js

OTHER_FILES += $${QML_FILES} $${JS_FILES}

codefiles.files += $${QML_FILES} $${JS_FILES}
codefiles.path += $$INSTALL_ROOT/usr/share/$${PROJECT_NAME}

INSTALLS += codefiles

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
