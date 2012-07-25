VERSION = 0.0.1
PROJECT_NAME = vcardconverter
TEMPLATE = app
CONFIG += ordered mobility hide_symbols
MOBILITY += contacts versit
QT -= gui
TARGET = $$PROJECT_NAME
CONFIG -= app_bundle # OS X

SOURCES += main.cpp

target.path = $$INSTALL_ROOT/usr/bin/
INSTALLS += target
