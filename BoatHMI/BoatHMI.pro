QT += quick \
      widgets \
      core \
      gui \
      concurrent \
      positioning \        # ← QtPositioning
      location \           # ← QtLocation (carte OSM)
      charts \             # ← QtCharts (GraphBoat)
      mqtt                 # ← si possible via Qt6Mqtt

# Ne pas mettre mqtt ici si Qt Creator ne le détecte pas automatiquement
# On va l'ajouter via INCLUDEPATH / LIBS

CONFIG += console

# Sources
SOURCES += \
    boat.cpp \
    main.cpp \
    thirdparty/sqlite3/sqlite3.c

# Headers
HEADERS += \
    boat.h \
    thirdparty/sqlite3/sqlite3.h

# QML / images
RESOURCES += qml.qrc \
             images.qrc

# Translations
TRANSLATIONS += BoatHMI_fr_FR.ts
CONFIG += lrelease
CONFIG += embed_translations

# Include & Lib pour Qt6Mqtt compilé à la main
INCLUDEPATH += /home/jonathan/qtmqtt/include
LIBS += -L/home/jonathan/qtmqtt/build -lQt6Mqtt

# Deployment paths
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
