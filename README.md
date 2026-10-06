# aws-lab

Terraform for a small AWS lab environment: a VPC with public and private subnets, two EC2 instances and an S3 bucket.

## Structure

```
modules/
  network/    VPC, subnets, internet gateway, NAT gateway, route tables, NACL, flow logs
  instance/   one EC2 instance with the latest Ubuntu 24.04
  storage/    S3 bucket with read-only and read-write IAM roles
envs/
  lab/        the lab environment, it uses the modules
```

- Modules don't know about environments, everything comes in through variables.
- A new environment is a new folder in `envs/` with its own `terraform.tfvars`.

## What it creates

### Network

- VPC `10.0.0.0/16`.
- Public subnet `10.0.1.0/24`: instances get a public IP, `0.0.0.0/0` goes to the internet gateway.
- Private subnet `10.0.2.0/24`: no public IPs, `0.0.0.0/0` goes to the NAT gateway.
- Flow logs of the whole VPC go to CloudWatch `/lab/vpc-flow-logs` and are kept 7 days.
- All resources have the tags `Project`, `Environment` and `ManagedBy`.

### Traffic rules

NACL of the public subnet:

- In: SSH and HTTP only from `my_ip`.
- In: everything from the VPC, the private subnet goes out through the NAT gateway here.
- In: TCP 1024-65535 from anywhere, these are answers to connections from inside, a NACL is stateless.
- Out: HTTP and HTTPS to the internet, everything to the VPC, TCP 1024-65535 for the answers.
- Everything else is denied by the default `*` rule.

Security group `lab-web`:

- In: SSH and HTTP only from `my_ip`.
- Out: HTTP and HTTPS for apt, everything to the VPC for SSH to the app instance.

Security group `lab-app`:

- In: SSH only from `lab-web`, ping from the VPC.
- Out: HTTP and HTTPS through the NAT gateway.

### Instances

- `lab-web` in the public subnet with nginx, `lab-app` in the private subnet.
- `t3.micro` (2 vCPU, 1 GB), it's in the free tier.
- The latest Ubuntu 24.04, its ID comes from the SSM parameter that Canonical keeps up to date.
- 8 GB gp3 root disk, encrypted.
- SSH key from `ssh_public_key`, the user is `ubuntu`, `sudo` for root.

### Storage

- S3 bucket `lab-files-<random>`: public access blocked, AES256 encryption, versioning on.
- Role `lab-s3-readonly`: list and download.
- Role `lab-s3-readwrite`: list, download, upload and delete.
- Both roles can be assumed by the users of this account.

## Usage

Needs Terraform 1.6 or newer and the AWS CLI after `aws configure`.

```bash
cd envs/lab
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

- `terraform output` shows the IPs, the SSH commands, the bucket name and the role ARNs.
- SSH to web: `ssh -i ~/.ssh/lab_ed25519 ubuntu@<web_public_ip>`.
- SSH to app through web: `ssh-add ~/.ssh/lab_ed25519`, then `ssh -J ubuntu@<web_public_ip> ubuntu@<app_private_ip>`.
- `terraform destroy` removes everything. The NAT gateway is paid by the hour, so destroy the lab when it's not needed.

## Variables

- `region`: default `eu-central-1`.
- `environment`: default `lab`, goes to the names and the `Environment` tag.
- `vpc_cidr`, `public_subnet_cidr`, `private_subnet_cidr`: the address ranges.
- `my_ip`: required, your public IP as a CIDR, e.g. `203.0.113.10/32`.
- `instance_type`: default `t3.micro`.
- `ssh_public_key`: required, the public key for both instances.

## Branches and versions

- `main` is the stable code, it changes only through a pull request from `develop`.
- `develop` is for work in progress.
- Commit messages are `type: description`, the types are `feat`, `fix`, `docs` and `chore`.
- Releases are tags on `main` with semantic versions: `v1.1.0` for new features, `v1.0.1` for fixes.
- Rollback: `git checkout v1.0.0` and `terraform apply`.

## Contributing

- Make the changes on `develop` or on a branch from it, keep them small.
- Run `terraform fmt -recursive` and `terraform validate` before a commit.
- Read `terraform plan` before `apply`, nothing should be replaced or destroyed by surprise.
- Never commit `terraform.tfvars`, state files or keys, they are in `.gitignore`.
