#-------------------------------------------------
#
# Project created by QtCreator 2014-01-17T12:39:08
#
#-------------------------------------------------

TALK_SCHEDULE_BACKEND_ID = 53eb4610e5bde51bac007bb1

QT += qml quick enginio svg
TARGET = talk-schedule
TEMPLATE = app
SOURCES += src/main.cpp \
    src/theme.cpp \
    src/model.cpp \
    src/sortfiltermodel.cpp \
    src/fileio.cpp

OTHER_FILES += \
    qml/main.qml \
    qml/components/Event.qml \
    qml/components/TrackSwitcher.qml \
    qml/components/Track.qml \
    qml/components/ConferenceHeader.qml \
    qml/components/DropDownMenu.qml \
    qml/components/ListItem.qml \
    qml/components/TrackHeader.qml \
    qml/components/DaySwitcher.qml \
    qml/components/SubTitle.qml \
    qml/components/FavouritesView.qml \
    qml/components/EventsList.qml

RESOURCES += \
    resource.qrc

HEADERS += \
    src/theme.h \
    src/model.h \
    src/sortfiltermodel.h \
    src/fileio.h

DEFINES += \
    TALK_SCHEDULE_BACKEND_ID=$$TALK_SCHEDULE_BACKEND_ID
