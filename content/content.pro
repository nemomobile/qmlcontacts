include(../common.pri)
TARGET = contactsplugin
TEMPLATE = lib

CONFIG += plugin link_pkgconfig

PKGCONFIG += meego-ux-content QtContacts QtVersit


# use pkg-config paths for include in both g++ and moc
INCLUDEPATH += $$system(pkg-config --cflags meego-ux-content \
    | tr \' \' \'\\n\' | grep ^-I | cut -d 'I' -f 2-)

INCLUDEPATH += ../lib
LIBS += -L../lib -lmeegocontacts

OBJECTS_DIR = .obj
MOC_DIR = .moc

SOURCES += \
    contactsfeedmodel.cpp \
    contactsplugin.cpp \
    contactsservicemodel.cpp

HEADERS += \
    contactsfeedmodel.h \
    contactsplugin.h \
    contactsservicemodel.h

target.path = $$[QT_INSTALL_PLUGINS]/MeeGo/Content
INSTALLS += target
