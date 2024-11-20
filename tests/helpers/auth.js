import { CognitoIdentityProviderClient, InitiateAuthCommand } from "@aws-sdk/client-cognito-identity-provider";

export async function getAuthToken() {
  // For local testing, always return mock token
  console.log('Using mock token for local testing');
  return 'test-token';
} 