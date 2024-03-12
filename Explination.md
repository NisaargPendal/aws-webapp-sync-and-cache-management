Detailed explanation of the code.

```bash
# Function to unzip the contents and copy the "build" directory
unzip_contents() {
    local zip_file="$1"
    local target_dir='/tmp/deploy'
    rm -rf "${target_dir:?}" >/dev/null 2>&1
```
 This is the beginning of a function named `unzip_contents`. 
 The purpose of this function is to unzip the contents of a provided ZIP file and copy the "build" directory (or the entire contents if there is no "build" directory) to a target directory `/tmp/deploy`.

 The function takes one argument, which is the path to the ZIP file. It also declares a local variable `target_dir` with the value `/tmp/deploy`, which will be used as the destination directory for the extracted contents.

 The `rm -rf "${target_dir:?}" >/dev/null 2>&1` command removes the `target_dir` directory and its contents, if it exists. The `>/dev/null 2>&1` part redirects both standard output and standard error to the null device (`/dev/null`), effectively suppressing any output from the `rm` command.

```bash
    # Create a temporary directory
    temp_dir=$(mktemp -d)
```
 This line creates a temporary directory using the `mktemp` command with the `-d` option, which stands for "directory". The name of the temporary directory is stored in the `temp_dir` variable.

```bash
    # Extract the contents of the ZIP file into the temporary directory
    unzip -o "${zip_file}" -d "${temp_dir}"
```
 This command uses the `unzip` utility to extract the contents of the ZIP file specified by `${zip_file}` into the temporary directory `${temp_dir}`. The `-o` option tells `unzip` to overwrite any existing files without prompting.

```bash
    # Check if the "build" directory exists in the temporary directory
    if [ -d "${temp_dir}/build" ]; then
        # Create the target directory if it doesn't exist
        mkdir -p "${target_dir}"
        # Copy the contents of the "build" directory to the target directory
        cp -r "${temp_dir}/build/"* "${target_dir}/"
```
This block of code checks if a "build" directory exists within the temporary directory. If it does, it creates the `target_dir` if it doesn't already exist (using `mkdir -p`), and then copies the contents of the "build" directory to the `target_dir` using the `cp -r` command (recursive copy).

```bash
    else
        # Check if there are files or directories in the root of the temporary directory
        if [ "$(ls -A "${temp_dir}")" ]; then
            # Create the target directory if it doesn't exist
            mkdir -p "${target_dir}"
            # Copy the entire contents of the ZIP file to the target directory
            cp -r "${temp_dir}/"* "${target_dir}/"
```
This `else` block is executed if the "build" directory doesn't exist in the temporary directory. It first checks if there are any files or directories in the root of the temporary directory using the `ls -A` command (list all except "." and ".."). If there are files or directories, it creates the `target_dir` if it doesn't exist, and then copies the entire contents of the temporary directory to the `target_dir` using the `cp -r` command.

```bash
        else
            echo "Error: The ZIP file is empty."
            rm -rf "${temp_dir}"
        fi
    fi
```
If the temporary directory is empty (i.e., the ZIP file was empty), it prints an error message "Error: The ZIP file is empty." and removes the temporary directory using `rm -rf`.

```bash
    # Remove the temporary directory
    rm -rf "${temp_dir}"
    echo "Extracted website content into ${target_dir}"
    echo "-------------------------"
}
```
After copying the contents to the `target_dir`, the temporary directory is removed using `rm -rf "${temp_dir}"`. Finally, it prints a message indicating that the website content has been extracted into the `target_dir`, followed by a separator line.

```bash
# Function to sync and invalidate cache
sync_and_invalidate() {
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI not found." >&2
        return 1
    fi
```
This is the beginning of another function named `sync_and_invalidate`. Its purpose is to sync the contents of the `target_dir` to an Amazon S3 bucket and invalidate the cache for a specified CloudFront distribution.

The function first checks if the AWS Command Line Interface (AWS CLI) is installed by running the `command -v aws` command. If the AWS CLI is not found, it prints an error message and returns with an exit code of 1 (indicating failure).

```bash
    # Hardcoded constants
    local s3_bucket=<Your-bucket-URL>
    local cloudfront_dist_id=<Cloudfront-ID>
    local local_dir="/tmp/deploy/"
```
This section declares three local variables: `s3_bucket`, `cloudfront_dist_id`, and `local_dir`. These variables store the Amazon S3 bucket URL, CloudFront distribution ID, and the local directory path (`/tmp/deploy/`), respectively. You would need to replace `<Your-bucket-URL>` and `<Cloudfront-ID>` with your actual S3 bucket URL and CloudFront distribution ID.

```bash
    # Perform S3 sync operation
    echo "Syncing $local_dir to S3 bucket $s3_bucket/$remote_dir"
    aws s3 sync "$local_dir" "s3://$s3_bucket/$remote_dir" --delete
```
This block of code performs the S3 sync operation. It first prints a message indicating that it is syncing the contents of the `local_dir` to the specified S3 bucket and remote directory (`$remote_dir`). The `aws s3 sync` command is used to synchronize the contents of the local directory with the S3 bucket. The `--delete` option ensures that any files or directories that exist in the S3 bucket but not in the local directory are removed from the S3 bucket.

```bash
    # Create CloudFront invalidation request
    echo "Invalidating CloudFront cache for distribution $cloudfront_dist_id"
    aws cloudfront create-invalidation --distribution-id "$cloudfront_dist_id" --paths "/*"
}
```
After the S3 sync operation, this block of code creates a CloudFront invalidation request for the specified distribution ID (`$cloudfront_dist_id`). It first prints a message indicating that it is invalidating the CloudFront cache for the given distribution. The `aws cloudfront create-invalidation` command is used to create an invalidation request, specifying the distribution ID and the path pattern `/*` to invalidate the entire distribution's cache.

```bash
# Check if the filename argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename.zip>"
    exit 1
fi

zip_file="$1"
```
This section checks if a filename argument is provided when running the script. If no argument is provided (`$1` is empty), it prints a usage message showing how to run the script with a filename as an argument, and then exits with an exit code of 1 (indicating failure). If an argument is provided, it is stored in the `zip_file` variable.

```bash
# Call the unzip_contents function with the provided ZIP file
unzip_contents "$zip_file"
```
This line calls the `unzip_contents` function, passing the provided ZIP file (`$zip_file`) as an argument.

```bash
# Call the sync_and_invalidate function
sync_and_invalidate
```
Finally, this line calls the `sync_and_invalidate` function to perform the S3 sync and CloudFront cache invalidation operations.

# Final Keythings

## 1. `unzip_contents` function: Extracts the contents of a provided ZIP file, either copying the "build" directory or the entire contents if no "build" directory is present, to a target directory (`/tmp/deploy`).

## 2. `sync_and_invalidate` function: Syncs the contents of the `target_dir` (`/tmp/deploy`) to an Amazon S3 bucket, and then creates a CloudFront invalidation request to clear the cache for the specified CloudFront distribution.

## The script is designed to automate the deployment process by extracting website content from a ZIP file, uploading it to an S3 bucket, and invalidating the CloudFront cache to ensure that the latest content is served to end-users.
