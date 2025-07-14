import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
faq_table = dynamodb.Table(os.environ['FAQ_TABLE'])
fallback_table = dynamodb.Table(os.environ['FALLBACK_TABLE'])
ses = boto3.client('ses')

def handler(event, context):
    print("Event:", event)
    intent = event['sessionState']['intent']['name']
    user_input = event['inputTranscript']

    try:
        # Query FAQ table
        response = faq_table.get_item(Key={'Intent': intent})
        if 'Item' in response:
            answer = response['Item']['Answer']
            return {
                "sessionState": {
                    "dialogAction": {"type": "Close"},
                    "intent": {"name": intent, "state": "Fulfilled"}
                },
                "messages": [{"contentType": "PlainText", "content": answer}]
            }
        else:
            # Log fallback
            timestamp = datetime.now().isoformat()
            fallback_table.put_item(Item={
                'Timestamp': timestamp,
                'Question': user_input,
                'Intent': intent
            })
            # Send to support
            ses.send_email(
                Source=os.environ['SUPPORT_EMAIL'],
                Destination={'ToAddresses': [os.environ['SUPPORT_EMAIL']]},
                Message={
                    'Subject': {'Data': 'Unanswered Chatbot Query'},
                    'Body': {'Text': {'Data': f"User asked: {user_input} (intent: {intent})"}}
                }
            )
            return {
                "sessionState": {
                    "dialogAction": {"type": "Close"},
                    "intent": {"name": intent, "state": "Fulfilled"}
                },
                "messages": [{
                    "contentType": "PlainText",
                    "content": "Sorry, I couldn't find an answer. I've forwarded your question to IT support."
                }]
            }

    except Exception as e:
        print("Error:", e)
        raise
