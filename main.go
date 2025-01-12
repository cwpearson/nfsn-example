package main

import (
	"log"
	"net/http"
	"os"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func mustBearerToken() string {
	val, ok := os.LookupEnv("BEARER_TOKEN")
	if !ok || val == "" {
		log.Fatalln("must provide BEARER_TOKEN")
	}
	return val
}

func main() {
	bearerToken := mustBearerToken()

	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello World")
	})

	e.POST("/shutdown", func(c echo.Context) error {
		token := c.Request().Header.Get("Authorization")
		expectedToken := "Bearer " + bearerToken

		if token != expectedToken {
			return echo.NewHTTPError(http.StatusUnauthorized, "Invalid token")
		}

		// allow some time to send a response before shutting down
		go func() {
			log.Println("Shutdown triggered via /shutdown: 5s...")
			time.Sleep(time.Second * time.Duration(5))
			os.Exit(42)
		}()

		return c.String(http.StatusOK, "shutdown in 5s\n")
	})

	e.Start(":8080")
}
