import json

def handler(event, context):
    # Return an HTTP redirect response
    return {
        'statusCode': 302,
        'headers': {
            'Location': 'http://3.0.189.27/wordpress/',
        },
        'body': json.dumps('Redirecting to the home page'),
    }
