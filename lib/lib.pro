include(../common.pri)
TARGET = meegocontacts
TEMPLATE = lib

QT += declarative \
    dbus
CONFIG += qt \
        plugin \
        dbus \
        mobility \
        link_pkconfig


#PKGCONFIG += telepathy-qml-lib
PKGCONFIG += QtContacts QtVersit icu-uc icu-i18n

OBJECTS_DIR = .obj
MOC_DIR = .moc
LIBS += -licuuc -licui18n

MOBILITY = contacts versit

SOURCES += \    
    peoplemodel.cpp \
    proxymodel.cpp \    
    settingsdatastore.cpp \
    localeutils.cpp

INSTALL_HEADERS += \    
    peoplemodel.h \
    proxymodel.h \
    settingsdatastore.h \
    localeutils.h

HEADERS += peoplemodel_p.h \
    $$INSTALL_HEADERS

system(sed 's/__library_version__/$${VERSION}/g' meegocontacts.pc.in > meegocontacts.pc)

target.path = $$INSTALL_ROOT/usr/lib
INSTALLS += target

headers.files += $$INSTALL_HEADERS
headers.path += $$INSTALL_ROOT/usr/include/meegocontacts
INSTALLS += headers

pkgconfig.files += meegocontacts.pc
pkgconfig.path += $$INSTALL_ROOT/usr/lib/pkgconfig
INSTALLS += pkgconfig
