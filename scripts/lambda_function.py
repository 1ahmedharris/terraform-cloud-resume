import json
import boto3
import os 

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME']) # Enviroment variable from lambda.tf


def lambda_handler(event, context):
    response = table.get_item(Key={'id':'counter'})
    views = int(response['Item']['views']) 
    views += 1
    
    response = table.update_item(
        Key={'id':'counter'},
        UpdateExpression='SET #v = :val',
        ExpressionAttributeNames={'#v': 'views'},
        ExpressionAttributeValues={':val': views}
    )
    
    return {
    'statusCode': 200,
    'body': json.dumps({'views': views})
}
