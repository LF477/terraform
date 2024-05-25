import boto3


def lambda_handler(event, context):
    s3 = boto3.resource('s3')

    bucket_from = s3.Bucket("s3-start")
    bucket_to = "s3-finish"

    for obj in bucket_from.objects.filter(Prefix=''):
        copy_source = {'Bucket': "s3-start", 'Key': obj.key}

        bucket_to_name = obj.key
        s3.meta.client.copy(copy_source, bucket_to, bucket_to_name)
