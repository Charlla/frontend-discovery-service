import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({
    endpoint: process.env.AWS_ENDPOINT_URL || 'http://localhost:4566',
    region: process.env.AWS_REGION || 'us-east-1'
});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event));

    try {
        if (event.httpMethod === 'GET' && event.path.includes('/microFrontends')) {
            const projectId = event.pathParameters?.projectId;
            
            if (projectId) {
                const result = await docClient.send(new QueryCommand({
                    TableName: process.env.FRONTEND_STORE,
                    IndexName: 'ProjectIndex',
                    KeyConditionExpression: 'projectId = :projectId',
                    ExpressionAttributeValues: {
                        ':projectId': projectId
                    }
                }));

                return {
                    statusCode: 200,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    body: JSON.stringify({
                        microFrontends: result.Items
                    })
                };
            }
        }

        return {
            statusCode: 404,
            body: JSON.stringify({ message: 'Not Found' })
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Internal Server Error' })
        };
    }
};
