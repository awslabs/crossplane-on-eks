import os
import boto3

REGION = os.environ.get('AWS_DEFAULT_REGION', 'us-east-1')
EC2_CLIENT = boto3.client('ec2', region_name=REGION)

def remove_security_group_rules(security_group_id):
    try:
        sg_details = EC2_CLIENT.describe_security_groups(GroupIds=[security_group_id])
        sg = sg_details['SecurityGroups'][0]

        if sg['IpPermissions']:
            EC2_CLIENT.revoke_security_group_ingress(
                GroupId=security_group_id,
                IpPermissions=sg['IpPermissions']
            )

        if sg['IpPermissionsEgress']:
            EC2_CLIENT.revoke_security_group_egress(
                GroupId=security_group_id,
                IpPermissions=sg['IpPermissionsEgress']
            )
    except Exception as e:
        print(f"Error removing rules from {security_group_id}: {str(e)}")

def delete_all_security_groups():
    try:
        response = EC2_CLIENT.describe_security_groups()
        for sg in response['SecurityGroups']:
            # Skip deleting default security groups or any critical system security group
            if sg['GroupName'] == 'default' or 'default' in sg['GroupName']:
                print(f"Skipping default security group: {sg['GroupId']} ({sg['GroupName']})")
                continue

            try:
                remove_security_group_rules(sg['GroupId'])
                EC2_CLIENT.delete_security_group(GroupId=sg['GroupId'])
                print(f"Deleted security group: {sg['GroupId']}")
            except Exception as e:
                print(f"Failed to delete {sg['GroupId']}: {str(e)}")
    except Exception as e:
        print(f"Failed to process security groups: {str(e)}")

if __name__ == '__main__':
    delete_all_security_groups()
