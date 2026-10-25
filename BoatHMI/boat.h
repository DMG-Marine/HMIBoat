#ifndef BOAT_H
#define BOAT_H

#include <QObject>
#include <QQmlPropertyMap>
#include <QtMqtt/QMqttClient>
#include <QVariant>
#include <QMap>

#include "sqlite3.h"

class Boat : public QObject
{
    Q_OBJECT
public:
    explicit Boat(QObject *parent = nullptr);
    ~Boat();

    // --- Pour QML ---
    Q_PROPERTY(QQmlPropertyMap* rootMap READ rootMap CONSTANT)
    QQmlPropertyMap* rootMap() const { return m_rootMap; }

    // --- Historique SQL ---
    Q_INVOKABLE QVariantList getHistory(const QString &key, int limit = 1000);

signals:
    void valueUpdated(const QString &key, double value);
private:
    // --- MQTT ---
    QMqttClient *m_client;

    // --- QML map ---
    QQmlPropertyMap *m_rootMap;

    // --- SQLite ---
    sqlite3 *m_db;
    QMap<QString, double> m_lastValues;  // pour vérifier le seuil avant d'archiver

    void handleMessage(const QByteArray &message, const QMqttTopicName &topic);
    void insertValue(QQmlPropertyMap *map, const QStringList &keys, const QVariant &value);

    // --- DB ---
    void initDatabase();
    void archiveValue(const QString &key, double value, double offset = 0.0);
};

#endif // BOAT_H
