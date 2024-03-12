#!/bin/bash

# Function to unzip the contents and copy the "build" directory
unzip_contents() {
    local zip_file="$1"
    local target_dir='/tmp/deploy'


    rm -rf "${target_dir:?}" >/dev/null 2>&1

    # Create a temporary directory
    temp_dir=$(mktemp -d)

    # Extract the contents of the ZIP file into the temporary directory
    unzip -o "${zip_file}" -d "${temp_dir}"

    # Check if the "build" directory exists in the temporary directory
    if [ -d "${temp_dir}/build" ]; then
        # Create the target directory if it doesn't exist
        mkdir -p "${target_dir}"

        # Copy the contents of the "build" directory to the target directory
        cp -r "${temp_dir}/build/"* "${target_dir}/"
    else
        # Check if there are files or directories in the root of the temporary directory
        if [ "$(ls -A "${temp_dir}")" ]; then
            # Create the target directory if it doesn't exist
            mkdir -p "${target_dir}"

            # Copy the entire contents of the ZIP file to the target directory
            cp -r "${temp_dir}/"* "${target_dir}/"
        else
            echo "Error: The ZIP file is empty."
            rm -rf "${temp_dir}"
        fi
    fi

    # Remove the temporary directory
    rm -rf "${temp_dir}"
    echo "Extracted website content into ${target_dir}"
    echo "-------------------------"
}
# Function to sync and invalidate cache
sync_and_invalidate() {
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI not found." >&2
        return 1
    fi

    # Hardcoded constants
    local s3_bucket=<Your-bucket-URL>
    local cloudfront_dist_id=<Cloudfront-ID>
    local local_dir="/tmp/deploy/"

    # Perform S3 sync operation
    echo "Syncing $local_dir to S3 bucket $s3_bucket/$remote_dir"
    aws s3 sync "$local_dir" "s3://$s3_bucket/$remote_dir" --delete

    # Create CloudFront invalidation request
    echo "Invalidating CloudFront cache for distribution $cloudfront_dist_id"
    aws cloudfront create-invalidation --distribution-id "$cloudfront_dist_id" --paths "/*"
}

# Check if the filename argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename.zip>"
    exit 1
fi

zip_file="$1"

# Call the unzip_contents function with the provided ZIP file
unzip_contents "$zip_file"

# Call the sync_and_invalidate function
sync_and_invalidate

