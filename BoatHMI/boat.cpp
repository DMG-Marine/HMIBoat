#include "boat.h"
#include <QDebug>
#include <QtMqtt/QMqttClient>
#include <QtMqtt/QMqttTopicFilter>
#include <QDateTime>
#include <QVariantMap>

Boat::Boat(QObject *parent)
    : QObject(parent),
    m_rootMap(new QQmlPropertyMap(this)),
    m_db(nullptr)
{
    qDebug() << "[Boat] Constructor called";

    // --- Init MQTT ---
    m_client = new QMqttClient(this);
    m_client->setHostname("localhost");
    m_client->setPort(1883);

    connect(m_client, &QMqttClient::connected, this, [=]() {
        qDebug() << "Connected to MQTT broker!";
        QMqttTopicFilter filter("boat/#");
        QMqttSubscription *sub = m_client->subscribe(filter, 0);
        if (!sub) qDebug() << "Failed to subscribe!";
    });

    connect(m_client, &QMqttClient::messageReceived, this, &Boat::handleMessage);

    m_client->connectToHost();

    // --- Init SQLite DB ---
    initDatabase();
}

Boat::~Boat()
{
    if (m_db) {
        sqlite3_close(m_db);
        m_db = nullptr;
    }
}

void Boat::initDatabase()
{
    QString dbPath = "boat_log.db";
    if (sqlite3_open(dbPath.toUtf8().constData(), &m_db) != SQLITE_OK) {
        qDebug() << "Cannot open DB:" << sqlite3_errmsg(m_db);
        m_db = nullptr;
        return;
    }

    // ← Timeout 5 secondes si DB occupée
    sqlite3_busy_timeout(m_db, 5000);

    // ← WAL mode : lectures et écritures simultanées sans blocage
    sqlite3_exec(m_db, "PRAGMA journal_mode=WAL;", nullptr, nullptr, nullptr);
    sqlite3_exec(m_db, "PRAGMA synchronous=NORMAL;", nullptr, nullptr, nullptr);

    const char *sql =
        "CREATE TABLE IF NOT EXISTS logs ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "key TEXT,"
        "timestamp INTEGER,"
        "value REAL"
        ");";
    char *err = nullptr;
    if (sqlite3_exec(m_db, sql, nullptr, nullptr, &err) != SQLITE_OK) {
        qDebug() << "DB create table error:" << err;
        sqlite3_free(err);
    }

    // ← Index sur key+timestamp pour accélérer getHistory()
    sqlite3_exec(m_db,
                 "CREATE INDEX IF NOT EXISTS idx_key_ts ON logs(key, timestamp);",
                 nullptr, nullptr, nullptr);

    qDebug() << "[DB] Initialized with WAL mode";
}

// --- Traitement des messages MQTT ---
void Boat::handleMessage(const QByteArray &message, const QMqttTopicName &topic)
{
    QStringList parts = topic.name().split("/");
    if (parts.size() < 2 || parts[0] != "boat") return;

    double value = message.toDouble();
    insertValue(m_rootMap, parts.mid(1), value);

    QString fullKey = parts.mid(1).join(".");
    archiveValue(fullKey, value, 0.1);

    emit valueUpdated(fullKey, value);
    qDebug() << "[Boat] emit valueUpdated:" << fullKey << value;
}

// --- Insertion récursive dans rootMap ---
void Boat::insertValue(QQmlPropertyMap *map, const QStringList &keys, const QVariant &value)
{
    if (keys.isEmpty() || !map) return;

    QString key = keys.first();
    if (keys.size() == 1) {
        map->insert(key, value);
        qDebug() << "Updated" << key << "->" << value;
    } else {
        QVariant v = map->value(key);
        QQmlPropertyMap *subMap = nullptr;
        if (!v.canConvert<QQmlPropertyMap*>()) {
            subMap = new QQmlPropertyMap(map);
            map->insert(key, QVariant::fromValue(subMap));
        } else {
            subMap = v.value<QQmlPropertyMap*>();
        }
        insertValue(subMap, keys.mid(1), value);
    }
}

// --- Archivage SQLite ---
void Boat::archiveValue(const QString &key, double value, double offset)
{
    if (!m_db) return;

    bool firstTime = !m_lastValues.contains(key); // ← détecter premier appel
    double lastVal = m_lastValues.value(key, value);

    if (!firstTime && qAbs(lastVal - value) < offset) return;

    m_lastValues[key] = value;

    sqlite3_stmt *stmt;
    const char *sql = "INSERT INTO logs (key, timestamp, value) VALUES (?,?,?)";
    if (sqlite3_prepare_v2(m_db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        qDebug() << "Prepare error:" << sqlite3_errmsg(m_db);
        return;
    }

    QByteArray keyBytes = key.toUtf8();
    sqlite3_bind_text(stmt, 1, keyBytes.constData(), -1, SQLITE_TRANSIENT); // ← TRANSIENT
    sqlite3_bind_int64(stmt, 2, QDateTime::currentMSecsSinceEpoch());
    sqlite3_bind_double(stmt, 3, value);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        qDebug() << "DB insert error:" << sqlite3_errmsg(m_db);
    } else {
        qDebug() << "[Archive] Saved:" << key << value;
    }
    sqlite3_finalize(stmt);
}
// --- Lecture historique pour QML ---
QVariantList Boat::getHistory(const QString &key, int limit)
{
    QVariantList list;
    if (!m_db) return list;

    const char *sql = "SELECT timestamp, value FROM logs WHERE key=? ORDER BY timestamp ASC LIMIT ?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(m_db, sql, -1, &stmt, nullptr) != SQLITE_OK)
        return list;

    QByteArray keyBytes = key.toUtf8();
    sqlite3_bind_text(stmt, 1, keyBytes.constData(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 2, limit);

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        qint64 ts = sqlite3_column_int64(stmt, 0);
        double val = sqlite3_column_double(stmt, 1);
        QVariantMap point;
        point["time"] = ts;
        point["value"] = val;
        list.append(point);
    }
    sqlite3_finalize(stmt);
    return list;
}
