include(../common.pri)
TARGET = meegocontacts
TEMPLATE = app

QT += declarative \
    dbus
CONFIG += qt \
        plugin \
        dbus \
        mobility \
        link_pkconfig

MOBILITY += contacts versit


PKGCONFIG += icu-uc icu-i18n mlite

OBJECTS_DIR = .obj
MOC_DIR = .moc
LIBS += -licuuc -licui18n -lseaside
INCLUDEPATH += /usr/include/mlite

MOBILITY = contacts versit

SOURCES += \
    main.cpp

system(sed 's/__library_version__/$${VERSION}/g' meegocontacts.pc.in > meegocontacts.pc)

target.path = $$INSTALL_ROOT/usr/lib
INSTALLS += target

pkgconfig.files += meegocontacts.pc
pkgconfig.path += $$INSTALL_ROOT/usr/lib/pkgconfig
INSTALLS += pkgconfig
