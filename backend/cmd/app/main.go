package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"strings"
	"time"
)

const (
	port     = ":8019"
	id       = "0e9cccb4"
	dataFile = "/data/message.txt"
)

func main() {
	api := http.NewServeMux()

	api.HandleFunc("/api", logger(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	api.HandleFunc("/api/info", logger(getInfo))

	slog.Info("server started", "port", port)
	if err := http.ListenAndServe(port, api); err != nil {
		slog.Error("error occurred", err)
		return
	}
}

func getInfo(w http.ResponseWriter, r *http.Request) {
	hostname, err := os.Hostname()
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	message, err := os.ReadFile(dataFile)
	if err != nil {
		slog.Error("read data file", "path", dataFile, "err", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	resp := fmt.Sprintf("Георгий Штыфман вариант 19 %s\nhostname: %s\nmessage: %s",
		id, hostname, strings.TrimSpace(string(message)))

	w.WriteHeader(http.StatusOK)
	w.Write([]byte(resp))
}

func logger(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		next.ServeHTTP(w, r)

		slog.Info("request received",
			"method", r.Method,
			"path", r.URL.Path,
			"time", time.Since(start),
		)
	}
}
