## aws-webapp-sync-and-cache-management
Automated content deployment from ZIPs to AWS S3. Implemented CloudFront cache invalidation for real-time updates. Optimized with temporary directories, reducing disk usage. Incorporated error handling and validation. Automated cache purging, diminishing manual effort. Developed modular, CI/CD-ready solution.

# Deployment Script for My Web Application

This script performs the following tasks:

1. Unzips the contents of a given ZIP file and copies the necessary files to a deployment directory.
2. Syncs those files with an Amazon S3 bucket using the AWS Command Line Interface (CLI).
3. Invalidates the CloudFront cache for the associated distribution to ensure that users see the most recent version of the site.

## Prerequisites

Before running this script, make sure you have the following prerequisites installed on your system:

- `aws` CLI tool (version >= 2.x.x)
- `unzip` utility
- `mk TempDir` utility

Additionally, you will need to configure your AWS credentials by setting the appropriate environment variables or creating a configuration file at `~/.aws/credentials`. For more information, refer to the official [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickref.html).

## Usage

To run the script, simply provide the name of the ZIP file as the first argument:
```sh
./deploy.sh myapp.zip
