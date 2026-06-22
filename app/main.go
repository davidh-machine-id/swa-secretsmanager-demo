package main

import (
	"embed"
	"encoding/base64"
	"encoding/json"
	"html/template"
	"log"
	"net/http"
	"strings"

	secret "demo-app/internal"
)

//go:embed index.html
var content embed.FS

func main() {
	// Setup HTTP handlers
	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/health", handleHealth)

	port := ":8080"
	log.Printf("Starting server on %s", port)
	log.Fatal(http.ListenAndServe(port, nil))
}

// handleRoot serves the main demo page
func handleRoot(w http.ResponseWriter, r *http.Request) {
	// Fetch secret using proven working code
	result, err := secret.FetchOnce()

	var errorMsg string
	if err != nil {
		errorMsg = err.Error()
	}

	// Decode JWT if we have a token
	var headerJSON, payloadJSON string
	if result != nil && result.SVIDToken != "" {
		header, payload, _ := decodeJWT(result.SVIDToken)
		if header != nil {
			headerBytes, _ := json.MarshalIndent(header, "", "  ")
			headerJSON = string(headerBytes)
		}
		if payload != nil {
			payloadBytes, _ := json.MarshalIndent(payload, "", "  ")
			payloadJSON = string(payloadBytes)
		}
	}

	// Prepare template data
	data := struct {
		Result  *secret.SecretResult
		Header  string
		Payload string
		Error   string
	}{
		Result:  result,
		Header:  headerJSON,
		Payload: payloadJSON,
		Error:   errorMsg,
	}

	// Execute template from embedded file
	tmpl, err := template.ParseFS(content, "index.html")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if err := tmpl.Execute(w, data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// handleHealth provides a health check endpoint
func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
}

// decodeJWT decodes a JWT token into header and payload maps
func decodeJWT(token string) (map[string]interface{}, map[string]interface{}, error) {
	parts := strings.Split(token, ".")
	if len(parts) < 3 {
		return nil, nil, nil
	}

	// Decode header
	var header map[string]interface{}
	if headerBytes, err := base64.RawURLEncoding.DecodeString(parts[0]); err == nil {
		json.Unmarshal(headerBytes, &header)
	}

	// Decode payload
	var payload map[string]interface{}
	if payloadBytes, err := base64.RawURLEncoding.DecodeString(parts[1]); err == nil {
		json.Unmarshal(payloadBytes, &payload)
	}

	return header, payload, nil
}
