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

target.path = $$INSTALL_ROOT/usr/bin
INSTALLS += target
