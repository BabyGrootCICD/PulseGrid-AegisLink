package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/pion/webrtc/v4"
	"go.uber.org/zap"
)

type Room struct {
	ID       string
	Peers    map[string]*webrtc.PeerConnection
	TrackLocal *webrtc.TrackLocalStaticRTP
}

var (
	rooms    = make(map[string]*Room)
	logger   *zap.Logger
)

func main() {
	var err error
	logger, err = zap.NewProduction()
	if err != nil {
		log.Fatalf("Failed to initialize logger: %v", err)
	}
	defer logger.Sync()

	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(loggerMiddleware())

	r.GET("/health", healthCheck)
	r.POST("/rooms", createRoom)
	r.GET("/rooms/:id", getRoom)
	r.POST("/rooms/:id/join", joinRoom)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	logger.Info("SFU Server starting", zap.String("port", port))
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

func createRoom(c *gin.Context) {
	roomID := generateRoomID()
	rooms[roomID] = &Room{
		ID:    roomID,
		Peers: make(map[string]*webrtc.PeerConnection),
	}
	c.JSON(http.StatusOK, gin.H{"room_id": roomID})
}

func getRoom(c *gin.Context) {
	roomID := c.Param("id")
	room, exists := rooms[roomID]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "room not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"room_id": room.ID, "peers": len(room.Peers)})
}

func joinRoom(c *gin.Context) {
	roomID := c.Param("id")
	room, exists := rooms[roomID]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "room not found"})
		return
	}

	config := webrtc.Configuration{
		ICEServers: []webrtc.ICEServer{
			{URLs: []string{"stun:stun.l.google.com:19302"}},
		},
	}

	peerConnection, err := webrtc.NewPeerConnection(config)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	peerID := generatePeerID()
	room.Peers[peerID] = peerConnection

	c.JSON(http.StatusOK, gin.H{"peer_id": peerID, "room_id": roomID})
}

func generateRoomID() string {
	return "room-" + randomString(8)
}

func generatePeerID() string {
	return "peer-" + randomString(8)
}

func randomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyz0123456789"
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[i%len(charset)]
	}
	return string(b)
}
