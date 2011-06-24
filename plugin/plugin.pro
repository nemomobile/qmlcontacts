include(../common.pri)
TEMPLATE = lib
TARGET = Contacts

QT += declarative
CONFIG += qt \
        plugin \
        link_pkgconfig \
        mobility

PKGCONFIG += QtContacts QtVersit

TARGET = $$qtLibraryTarget($$TARGET)
DESTDIR = $$TARGET
OBJECTS_DIR = .obj
MOC_DIR = .moc

# For building within the tree
INCLUDEPATH += ../lib /usr/include/mlite
LIBS += -L../lib -lmeegocontacts

# Input
SOURCES += \
    contacts.cpp
HEADERS += \
    contacts.h

qmldir.files += $$TARGET
qmldir.path += $$[QT_INSTALL_IMPORTS]/MeeGo/App
INSTALLS += qmldir

DEFINES += QMLJSDEBUGGER
