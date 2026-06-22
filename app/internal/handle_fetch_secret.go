package secret

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/cyberark/conjur-api-go/conjurapi"
	"github.com/spiffe/go-spiffe/v2/svid/jwtsvid"
	"github.com/spiffe/go-spiffe/v2/workloadapi"
)

// SecretResult holds all the data from a secret fetch operation
type SecretResult struct {
	SVIDToken     string
	SpiffeID      string
	ServiceID     string
	SecretPath    string
	SecretValue   string
	ConjurURL     string
	ConjurAccount string
}

// FetchOnce performs the secret fetch and returns structured data
func FetchOnce() (*SecretResult, error) {
	// 1. Setup execution context and establish required variables
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	serviceID := os.Getenv("CONJUR_AUTHN_JWT_SERVICE_ID")
	secretID := os.Getenv("CONJUR_SECRET_ID")
	audience := os.Getenv("CONJUR_JWT_AUDIENCE")

	if serviceID == "" || secretID == "" || audience == "" {
		return nil, fmt.Errorf("CONJUR_AUTHN_JWT_SERVICE_ID, CONJUR_SECRET_ID, and CONJUR_JWT_AUDIENCE must be set")
	}

	// 2. Initialize SPIFFE Workload API Client.
	// This automatically searches for the SPIFFE_ENDPOINT_SOCKET environment variable.
	client, err := workloadapi.NewJWTSource(ctx)
	if err != nil {
		return nil, fmt.Errorf("unable to create SPIFFE JWT source: %w", err)
	}
	defer client.Close()

	// 3. Request a fresh JWT-SVID from the SPIRE Agent.
	params := jwtsvid.Params{
		Audience: audience,
	}

	svid, err := client.FetchJWTSVID(ctx, params)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch SPIFFE JWT-SVID: %w", err)
	}

	// 4. Load the base Conjur configuration (inherits CONJUR_APPLIANCE_URL and CONJUR_ACCOUNT)
	conjurCfg, err := conjurapi.LoadConfig()
	if err != nil {
		return nil, fmt.Errorf("failed to load base Conjur configuration: %w", err)
	}

	// 5. Populate specific settings for the explicit JWT Authenticator workflow
	conjurCfg.AuthnType = "jwt"
	conjurCfg.ServiceID = serviceID
	conjurCfg.JWTContent = svid.Marshal() // Extracts raw compact token string representation

	// 6. Initialize the explicit Conjur JWT client
	conjurClient, err := conjurapi.NewClientFromJwt(conjurCfg)
	if err != nil {
		return nil, fmt.Errorf("failed to instantiate Conjur JWT client: %w", err)
	}

	// 7. Execute secret retrieval
	secretBytes, err := conjurClient.RetrieveSecret(secretID)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve secret from Conjur: %w", err)
	}

	// Return structured result
	return &SecretResult{
		SVIDToken:     svid.Marshal(),
		SpiffeID:      svid.ID.String(),
		ServiceID:     serviceID,
		SecretPath:    secretID,
		SecretValue:   string(secretBytes),
		ConjurURL:     conjurCfg.ApplianceURL,
		ConjurAccount: conjurCfg.Account,
	}, nil
}

// Fetch is the original function that prints to stdout (kept for backwards compatibility)
func Fetch() {
	result, err := FetchOnce()
	if err != nil {
		log.Fatalf("Error: %v", err)
	}

	log.Printf("[DEBUG] SVID: %s", result.SVIDToken)
	log.Printf("[DEBUG] JWT Service ID: %s", result.ServiceID)
	log.Printf("[DEBUG] Secret ID: %s", result.SecretPath)
	log.Printf("[DEBUG] Secret fetched: %s", result.SecretValue)
	fmt.Printf("Successfully fetched secret! Length: %d bytes\n", len(result.SecretValue))
}
