 #ifndef MQTTMANAGER_H
#define MQTTMANAGER_H
#include <QObject>
#include <QtMqtt/QMqttClient>

class MqttManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)

public:
    explicit MqttManager(QObject *parent = nullptr);

    double speed() const { return m_speed; }

signals:
    void speedChanged();

private:
    QMqttClient *m_client;
    double m_speed = 0.0;
};

#endif // MQTTMANAGER_H
