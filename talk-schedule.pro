#-------------------------------------------------
#
# Project created by QtCreator 2014-01-17T12:39:08
#
#-------------------------------------------------

TALK_SCHEDULE_BACKEND_ID = 53eb4610e5bde51bac007bb1
TWITTER_KEY = aPU6stBUmqUEhE0fy8AktbVvi

QT += qml quick enginio svg xmlpatterns xml
TARGET = QtDevDays
TEMPLATE = app
SOURCES += src/main.cpp \
    src/theme.cpp \
    src/model.cpp \
    src/sortfiltermodel.cpp \
    src/fileio.cpp \
    src/applicationclient.cpp

OTHER_FILES += \
    qml/main.qml \
    qml/components/Event.qml \
    qml/components/TrackSwitcher.qml \
    qml/components/Track.qml \
    qml/components/ConferenceHeader.qml \
    qml/components/ConferenceSwitcher.qml \
    qml/components/TrackHeader.qml \
    qml/components/DaySwitcher.qml \
    qml/components/SubTitle.qml \
    qml/components/EventsList.qml \
    qml/components/ModelsSingleton.qml \
    qml/components/EventsListDelegate.qml \
    qml/components/EventsList.qml \
    fonts/OpenSans-Bold.ttf \
    fonts/OpenSans-Semibold.ttf \
    fonts/OpenSans-Regular.ttf \
    qml/components/HomeScreen.qml \
    qml/components/Feedback.qml \
    qml/components/DayTracksModel.qml \
    qml/components/TweetModel.qml \
    android/AndroidManifest.xml \
    qml/components/Floorplan.qml

RESOURCES += \
    resource.qrc

HEADERS += \
    src/theme.h \
    src/model.h \
    src/sortfiltermodel.h \
    src/fileio.h \
    src/applicationclient.h

DEFINES += \
    TALK_SCHEDULE_BACKEND_ID=$$TALK_SCHEDULE_BACKEND_ID \
    TWITTER_KEY=$$TWITTER_KEY \
    TWITTER_SECRET=$$TWITTER_SECRET

winrt: WINRT_MANIFEST.capabilities += internetClientServer

android: ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

ios: QMAKE_INFO_PLIST = ios/iosInfo.plist
