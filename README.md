# eks-with-day-two-operations

## THE WHY?

To demonstrate automation of AWS EKS with an ecosystem that empowers Day 2 Operations from dev to production


## The What

- `terraform` to provision aws resources including EKS
  - offers tf environments to reuse code to build sandbox, qa, and production environments
  - vpc
  - public/private subnets
  - optional bastion
  - locked down eks control plane by default
  - eks nodes in private subnets
  - s3 bucket for cluster backups with velero
  - optional workstation to interact with cluster
- `ansible` leveraging community helm charts to manage tooling on k8s
  - offers ansible environments to reuse code to build sandbox, qa, and production environments
  - logging: logs sent to AWS Cloudwatch
  - disaster recovery: automated cluster backups with velero (daily default backups)
  - metrics/alerting: view system wide metrics and configure alerts with grafana, prometheus, & alertmanger
  - ingress: using aws-alb-ingress-controller for dynamic lb creation and leverage AWS Certificate Manager for tls on ingress objects
  - dynamic cnames: leveraging external-dns to dynamically create cnames
  - encryption-at-rest: leveraging the gp2 storageclass for encrypted ebs volumes
  - fine-grain-app-permissions: leverages kube2iam to give least privileged permissions to pods
  - authentication: leverages AWS Cognito for app authentication


- ansible-vault password is '.'


## DOCS

### TO start up

- prep to execute tf
  - install tf v0.11.2 (the scripts assume that version for now)
  - create bucket for tf state (cs-eks-example-solution)
    - and update the modules main.tf for remote state
  - create pem key
    - and update var accordingly
  - create role/user [with Admin privileges] to run tf and assign to workstation
    - and update the var for workstation
      - the tf-privileged role in this example has the AdministratorAccess policy applied to it
        - it essentially will need access to create other iam roles, vpc, subnets, eks-cluster, etc
      - in workstation module variables
        ```
        #NOTE: this is a role created outside of this tf.
        variable "workstation_instance_profile_name" {
          default = "tf-privileged"
        }
        ```
  - update region var
  - update velero s3 bucket var
  - update ami_id or leverage the ami filter in vpc/workstation modules
    - if leverage the ami filter, the be sure to update module main.tf/variables.tf

- terraform plan/apply
  - 00-base-infra
  - 01-eks
  - 02-workstation (highly recommended),

- create a wildcard ssl cert in aws certificate manager and update the ansible variable of  aws_cert_manager_wildcard_arn
  - don't feel obligated to have a wildcard cert. Manage the your certs the way you see fit with your ecosystem (automation may change a bit)

- (optional) cognito-create userpool/clientid
  - IF YOU DON'T want this, then update ingress annotations that leverage cognito auth
  - setup instructions
    - https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/cognito/setup/
  - example alb ingress cognito for reference (automation adds auth ingress annotations)
    - https://kubernetes-sigs.github.io/aws-alb-ingress-controller/examples/cognito-ingress-template.yaml

- execute ansible against newly created cluster
  - automation is assumed to run on the workstation that leverages the same credentials leveraged in provisioning the eks-cluster
    - see notes on AUTH for other users/roles
  - see the top of the `ansible/environments/000_cross_env_vars.yml` file for vars to update
    - those are the defaults for all ansible environments
    - for env specific leverage the `ansible/environments/<env>/group_vars/all/<env>.yml`
    - for env specific secret variables, see the ansible-vault file at `ansible/environments/<env>/group_vars/all/secrets.yml`
  - NOTE: this article entails details for how the environments are setup:
    - https://www.digitalocean.com/community/tutorials/how-to-manage-multistage-environments-with-ansible
      - the 000_cross_env_vars.yml is symlink'd from within the <env>/group_vars/all

### TO Delete

1. delete k8s resources for the apps on top of it with:
  `ansible-playbook  -i environments/<environment> delete_k8s_cluster_app_resources.yml --ask-vault-pass`
    - the resources the script removes are the following:
      - deletes helm/ns resources
      - deletes cw log group - it has a retention of less than a week
      - delete items velero backups in s3 to prepare for tf script to delete the bucket
      - deletes dangling ebs volumes and lbs  
2. (optional) delete cnames in r53. NOTE: not charged for these
3. delete resources with `terraform destroy`:
  - 02-workstation (if existing),
  - 01-eks
  - may need to manually delete the eks security group created via aws (in the vpc we're about to delete)
    - See bug report for further details: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/285
  - 00-base-infra
4. (optional) delete the cognito user pool
5. Double check no billable resources exist


## AUTH for other users/roles

- NOTE: whatever iam user/role is leveraged to create the eks cluster, that user/role
will have default admin credentials to the cluster
  - to grant other roles/users access to the cluster, you'll need to update the aws-auth configmap
  in the kube-system namespace. For example:

```
apiVersion: v1
kind: ConfigMap
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::<account-id>:role/<node-iam-role>
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
    - userarn: arn:aws:iam::<account-id>:role/<your-role-to-grant-admin-access>
      username: admin
      groups:
        - system:masters
.
.
.

```

## Steps to add for workstation or bastion
- NOTE: not using workstation, but the bastion instead, then see the section below with leveraging bastion
  - MOST the steps for configuring workstation are already done for you
- add ssh key for github/bitbucket auth
   - either use ssh-keygen to generate keys or cp/paste them:
       - they should end up in `/root/.ssh/id_rsa` and `/root/.ssh/id_rsa.pub` with chmod 600 permissions

- clone and execute ansible
```
git clone <repo here>
cd eks-with-day-two-operations/ansible
/usr/local/bin/aws2 eks update-kubeconfig --name dev-eks-cluster
ansible-playbook -i environments/dev dev.yml --ask-vault-pass
```



## To interact with cluster on bastion (when workstation not around)

0) setup ability to talk to control plane

add the sg of `eks-cluster-sg-*` to the bastion to interact with the control plane
AND add iam credentials leveraged for provisioning cluster to be able to obtain creds with awscli  

1) run some commands to communicate with cluster (run as sudo)
```
EKS_CLUSTER_NAME=dev-eks-cluster
KUBECTL_VERSION=1.14.0

# setup with awscli v2
apt-get update
apt-get install git vim wget -y
apt install unzip -y
apt install python-pip -y
apt install jq -y

curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
/usr/local/bin/aws2 eks update-kubeconfig --name ${EKS_CLUSTER_NAME}
pip install awscli
pip install ansible==2.6.5

# kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl


```
3) be sure to validate interacting with cluster
```
# To validate
kubectl get po --all-namespaces
kubectl get nodes

```

## TODOS

#### cluster todos
- add autoscaling
- look into fargate
- add scenario for upgrading (multiple ways to do this depending on workflow/ecosystem)

#### terraform todos
- upgrade tf v0.12
- handle the manual step in teardown process
  - See bug report for further details: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/285
