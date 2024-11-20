const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, GetCommand } = require('@aws-sdk/lib-dynamodb');
const { v4: uuidv4 } = require('uuid');

const client = new DynamoDBClient({
    endpoint: 'http://172.17.0.1:4566',
    region: process.env.AWS_REGION || 'us-east-1',
    credentials: {
        accessKeyId: 'test',
        secretAccessKey: 'test'
    }
});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    console.log('Event received:', JSON.stringify(event, null, 2));
    console.log('Environment:', process.env);

    try {
        switch (event.httpMethod) {
            case 'POST':
                if (event.path === '/admin/api/projects') {
                    console.log('Creating new project...');
                    const body = JSON.parse(event.body || '{}');
                    const projectId = uuidv4();
                    
                    const item = {
                        projectId,
                        name: body.name,
                        createdAt: new Date().toISOString()
                    };

                    console.log('Putting item into DynamoDB:', JSON.stringify(item, null, 2));
                    console.log('Using table:', process.env.PROJECT_STORE || 'ProjectStore');
                    
                    try {
                        await docClient.send(new PutCommand({
                            TableName: process.env.PROJECT_STORE || 'ProjectStore',
                            Item: item
                        }));
                        console.log('Successfully created project');
                    } catch (dbError) {
                        console.error('DynamoDB error:', dbError);
                        throw dbError;
                    }

                    const response = {
                        statusCode: 200,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*'
                        },
                        body: JSON.stringify({
                            id: projectId,
                            name: body.name,
                            createdAt: item.createdAt
                        })
                    };

                    console.log('Sending response:', JSON.stringify(response, null, 2));
                    return response;
                }
                break;

            case 'GET':
                if (event.path.startsWith('/admin/api/projects')) {
                    const projectId = event.pathParameters?.projectId;
                    console.log('Getting project:', projectId);
                    
                    if (projectId) {
                        const result = await docClient.send(new GetCommand({
                            TableName: process.env.PROJECT_STORE || 'ProjectStore',
                            Key: { projectId }
                        }));
                        console.log('Get result:', result);

                        return {
                            statusCode: 200,
                            headers: {
                                'Content-Type': 'application/json',
                                'Access-Control-Allow-Origin': '*'
                            },
                            body: JSON.stringify(result.Item)
                        };
                    }
                }
                break;
        }

        return {
            statusCode: 404,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({ message: 'Not Found' })
        };
    } catch (error) {
        console.error('Error in Lambda:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({ 
                message: 'Internal Server Error',
                error: error.message,
                stack: error.stack,
                event: event
            })
        };
    }
};
