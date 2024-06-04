import os
import boto3

REGION = os.environ.get('AWS_DEFAULT_REGION', 'us-east-1')
ELB_CLIENT = boto3.client('elbv2', region_name=REGION)

def delete_target_groups(target_group_arns):
    for tg_arn in target_group_arns:
        ELB_CLIENT.delete_target_group(TargetGroupArn=tg_arn)

def delete_listeners(listener_arns):
    for listener_arn in listener_arns:
        ELB_CLIENT.delete_listener(ListenerArn=listener_arn)

def delete_load_balancers():
    response = ELB_CLIENT.describe_load_balancers()

    for lb in response['LoadBalancers']:
        lb_arn = lb['LoadBalancerArn']
        listeners = ELB_CLIENT.describe_listeners(LoadBalancerArn=lb_arn)
        listener_arns = [listener['ListenerArn'] for listener in listeners['Listeners']]

        delete_listeners(listener_arns)

        target_groups = ELB_CLIENT.describe_target_groups(LoadBalancerArn=lb_arn)
        target_group_arns = [tg['TargetGroupArn'] for tg in target_groups['TargetGroups']]

        delete_target_groups(target_group_arns)
        
        ELB_CLIENT.delete_load_balancer(LoadBalancerArn=lb_arn)

if __name__ == '__main__':
    delete_load_balancers()
