import json
import gzip
import boto3
import os
import logging
from io import BytesIO
import urllib.parse

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize S3 client
s3 = boto3.client('s3')

def lambda_handler(event, context):
    """
    Lambda function to process AWS Config snapshot files.
    This function:
    1. Gets the gzipped Config snapshot file from S3
    2. Decompresses it
    3. Formats the JSON for better readability
    4. Saves the formatted JSON back to S3 with a _formatted.json suffix
    5. Optionally generates a summary file with resource counts
    """
    try:
        # Get environment variables
        generate_summary = os.environ.get('GENERATE_SUMMARY', 'true').lower() == 'true'
        
        # Get the S3 bucket and key from the event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
        
        logger.info(f"Processing file s3://{bucket}/{key}")
        
        # Skip processing if this is already a processed file
        if '_formatted.json' in key or '_summary.json' in key:
            logger.info(f"Skipping already processed file: {key}")
            return {
                'statusCode': 200,
                'body': 'Skipped already processed file'
            }
        
        # Download the gzipped file from S3
        response = s3.get_object(Bucket=bucket, Key=key)
        gzipped_content = response['Body'].read()
        
        # Decompress the gzipped content
        with gzip.GzipFile(fileobj=BytesIO(gzipped_content), mode='rb') as f:
            json_content = f.read().decode('utf-8')
        
        # Parse the JSON
        config_data = json.loads(json_content)
        
        # Format the JSON with proper indentation
        formatted_json = json.dumps(config_data, indent=2)
        
        # Generate the formatted file name
        formatted_key = key.replace('.json.json', '_formatted.json')
        if formatted_key == key:  # If the replacement didn't work
            formatted_key = key.replace('.json', '_formatted.json')
        
        # Upload the formatted JSON back to S3
        s3.put_object(
            Bucket=bucket,
            Key=formatted_key,
            Body=formatted_json,
            ContentType='application/json'
        )
        
        logger.info(f"Uploaded formatted file to s3://{bucket}/{formatted_key}")
        
        # Generate and upload a summary file if requested
        if generate_summary:
            summary = generate_config_summary(config_data)
            summary_json = json.dumps(summary, indent=2)
            
            # Generate the summary file name
            summary_key = key.replace('.json.json', '_summary.json')
            if summary_key == key:  # If the replacement didn't work
                summary_key = key.replace('.json', '_summary.json')
            
            # Upload the summary JSON to S3
            s3.put_object(
                Bucket=bucket,
                Key=summary_key,
                Body=summary_json,
                ContentType='application/json'
            )
            
            logger.info(f"Uploaded summary file to s3://{bucket}/{summary_key}")
        
        return {
            'statusCode': 200,
            'body': 'Successfully processed Config snapshot file'
        }
        
    except Exception as e:
        logger.error(f"Error processing Config snapshot: {str(e)}")
        raise

def generate_config_summary(config_data):
    """
    Generate a summary of the Config snapshot data
    """
    resource_counts = {}
    resource_details = {}
    
    # Count resources by type
    if 'configurationItems' in config_data:
        for item in config_data['configurationItems']:
            if 'resourceType' in item:
                resource_type = item['resourceType']
                
                # Increment count for this resource type
                if resource_type in resource_counts:
                    resource_counts[resource_type] += 1
                else:
                    resource_counts[resource_type] = 1
                    resource_details[resource_type] = []
                
                # Extract key information
                resource_info = {
                    'resourceId': item.get('resourceId', 'N/A'),
                    'resourceName': item.get('resourceName', 'N/A'),
                    'ARN': item.get('ARN', 'N/A'),
                    'awsRegion': item.get('awsRegion', 'N/A'),
                    'availabilityZone': item.get('availabilityZone', 'N/A'),
                    'configurationState': item.get('configurationItemStatus', 'N/A')
                }
                resource_details[resource_type].append(resource_info)
    
    # Create summary
    summary = {
        'totalResources': sum(resource_counts.values()),
        'resourceTypeCounts': resource_counts,
        'resourceDetails': resource_details
    }
    
    return summary
