package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/keyvault/azsecrets"
	"k8s.io/klog/v2"
)

func main() {
	keyvaultURL := os.Getenv("KEYVAULT_URL")
	if keyvaultURL == "" {
		klog.Fatal("KEYVAULT_URL environment variable is not set")
	}
	secretName := os.Getenv("SECRET_NAME")
	if secretName == "" {
		klog.Fatal("SECRET_NAME environment variable is not set")
	}
	clientIDGetSecret := os.Getenv("AZURE_CLIENT_ID_GET_SECRET")
	if clientIDGetSecret == "" {
		klog.Fatal("AZURE_CLIENT_ID_GET_SECRET environment variable is not set")
	}
	clientIDSetSecret := os.Getenv("AZURE_CLIENT_ID_SET_SECRET")
	if clientIDSetSecret == "" {
		klog.Fatal("AZURE_CLIENT_ID_SET_SECRET environment variable is not set")
	}

	// initialize keyvault client
	clientGetSecret, err := getKeyVaultClient(keyvaultURL, clientIDGetSecret)
	if err != nil {
		klog.Fatal(err)
	}
	clientSetSecret, err := getKeyVaultClient(keyvaultURL, clientIDSetSecret)
	if err != nil {
		klog.Fatal(err)
	}

	for {
		secretBundle, err := clientGetSecret.GetSecret(context.Background(), secretName, "", nil)
		if err != nil {
			klog.ErrorS(err, "failed to get secret from keyvault", "keyvault", keyvaultURL, "secretName", secretName)
			os.Exit(1)
		}
		klog.InfoS("successfully got secret", "secret", *secretBundle.Value, "client-id", clientIDGetSecret)

		newSecretValue := fmt.Sprintf("Hello at %s", time.Now().Format(time.RFC3339Nano))
		params := azsecrets.SetSecretParameters{
			Value: &newSecretValue,
		}
		_, err = clientSetSecret.SetSecret(context.Background(), secretName, params, nil)
		if err != nil {
			klog.ErrorS(err, "failed to set secret in keyvault", "keyvault", keyvaultURL, "secretName", secretName)
			os.Exit(1)
		}
		klog.InfoS("successfully set secret", "secret", newSecretValue, "client-id", clientIDSetSecret)

		// wait for 60 seconds before polling again
		time.Sleep(60 * time.Second)
	}
}

func getKeyVaultClient(keyvaultURL, clientID string) (*azsecrets.Client, error) {
	options := &azidentity.WorkloadIdentityCredentialOptions{
		ClientID: clientID,
	}

	cred, err := azidentity.NewWorkloadIdentityCredential(options)
	if err != nil {
		return nil, err
	}

	client, err := azsecrets.NewClient(keyvaultURL, cred, &azsecrets.ClientOptions{})
	if err != nil {
		return nil, err
	}

	klog.InfoS("successfully got keyvault client", "keyvaultURL", keyvaultURL, "client-id", clientID)

	return client, nil
}
