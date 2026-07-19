package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/eclipse/paho.mqtt.golang"
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
)

type IoTCommand struct {
	DeviceID  string      `json:"device_id"`
	Command   string      `json:"command"`
	Payload   interface{} `json:"payload"`
	Timestamp int64       `json:"timestamp"`
}

var (
	mqttClient mqtt.Client
	redisClient *redis.Client
	logger     *zap.Logger
)

func main() {
	var err error
	logger, err = zap.NewProduction()
	if err != nil {
		log.Fatalf("Failed to initialize logger: %v", err)
	}
	defer logger.Sync()

	redisClient = redis.NewClient(&redis.Options{
		Addr:     getEnv("REDIS_ADDR", "localhost:6379"),
		Password: getEnv("REDIS_PASSWORD", ""),
		DB:       0,
	})

	mqttOpts := mqtt.NewClientOptions().
		AddBroker(getEnv("MQTT_BROKER", "tcp://localhost:1883")).
		SetClientID("mqtt-broker-" + generateID()).
		SetAutoReconnect(true).
		SetConnectRetry(true).
		SetConnectRetryInterval(5 * time.Second)

	mqttClient = mqtt.NewClient(mqttOpts)
	if token := mqttClient.Connect(); token.Wait() && token.Error() != nil {
		logger.Fatal("Failed to connect to MQTT broker", zap.Error(token.Error()))
	}

	mqttClient.Subscribe("device/+/command", 1, handleDeviceCommand)
	mqttClient.Subscribe("device/+/status", 1, handleDeviceStatus)

	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(loggerMiddleware())

	r.GET("/health", healthCheck)
	r.POST("/devices/:id/command", sendDeviceCommand)
	r.GET("/devices/:id/status", getDeviceStatus)

	port := getEnv("PORT", "8081")
	logger.Info("MQTT Broker starting", zap.String("port", port))
	if err := r.Run(":" + port); err != nil {
		logger.Fatal("Failed to start server", zap.Error(err))
	}
}

func loggerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()
		logger.Info("Request",
			zap.String("method", c.Request.Method),
			zap.String("path", c.Request.URL.Path),
			zap.Int("status", c.Writer.Status()),
		)
	}
}

func healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "healthy"})
}

func sendDeviceCommand(c *gin.Context) {
	deviceID := c.Param("id")
	var cmd IoTCommand
	if err := c.ShouldBindJSON(&cmd); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	cmd.DeviceID = deviceID
	cmd.Timestamp = time.Now().UnixMilli()

	payload, err := json.Marshal(cmd)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	topic := "device/" + deviceID + "/command"
	token := mqttClient.Publish(topic, 1, false, payload)
	token.Wait()

	if token.Error() != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": token.Error().Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "command sent", "device_id": deviceID})
}

func getDeviceStatus(c *gin.Context) {
	deviceID := c.Param("id")
	ctx := c.Request.Context()

	status, err := redisClient.Get(ctx, "device:"+deviceID+":status").Result()
	if err == redis.Nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "device not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"device_id": deviceID, "status": status})
}

func handleDeviceCommand(client mqtt.Client, msg mqtt.Message) {
	logger.Info("Received device command",
		zap.String("topic", msg.Topic()),
		zap.ByteString("payload", msg.Payload()),
	)
}

func handleDeviceStatus(client mqtt.Client, msg mqtt.Message) {
	logger.Info("Received device status",
		zap.String("topic", msg.Topic()),
		zap.ByteString("payload", msg.Payload()),
	)

	topicParts := splitTopic(msg.Topic())
	if len(topicParts) >= 2 {
		deviceID := topicParts[1]
		ctx := msg.Context()
		redisClient.Set(ctx, "device:"+deviceID+":status", string(msg.Payload()), 10*time.Minute)
	}
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

func generateID() string {
	return time.Now().Format("20060102150405")
}

func splitTopic(topic string) []string {
	var parts []string
	current := ""
	for _, c := range topic {
		if c == '/' {
			if current != "" {
				parts = append(parts, current)
			}
			current = ""
		} else {
			current += string(c)
		}
	}
	if current != "" {
		parts = append(parts, current)
	}
	return parts
}
