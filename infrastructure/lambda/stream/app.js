const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({
    endpoint: process.env.AWS_ENDPOINT_URL || 'http://localhost:4566',
    region: process.env.AWS_REGION || 'us-east-1'
});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    console.log('Stream event:', JSON.stringify(event));

    try {
        for (const record of event.Records) {
            if (record.eventName === 'INSERT' || record.eventName === 'MODIFY') {
                // Process stream events here
                console.log('Processing record:', record);
            }
        }
        return { statusCode: 200, body: 'Success' };
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
};
