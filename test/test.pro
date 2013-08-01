TARGET =    tst_meego-app-contacts
TEMPLATE =  app

QT += declarative testlib
CONFIG += qt \
        mobility \
        link_pkconfig

PKGCONFIG += QtContacts QtVersit icu-uc icu-i18n

DESTDIR = $$TARGET
OBJECTS_DIR = .obj
MOC_DIR = .moc
LIBS += -licuuc -licui18n

MOBILITY = contacts versit

SOURCES += load_vcard.cpp

