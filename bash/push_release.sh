#!/bin/bash -e

PACKAGE_NAME="approval_tests"
VERSION=""

# Retrieve the current version from the pubspec.yaml file
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | tr -d "'\"")

# Fetch the HTML content from pub.dev
HTML_CONTENT=$(curl -s "https://pub.dev/packages/$PACKAGE_NAME")

# Attempt to extract the version using awk and sed
PUB_DEV_VERSION=$(echo "$HTML_CONTENT" | grep 'approval_tests' | sed -n 's/.*approval_tests \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/p' | head -1)

echo "Local version: $VERSION"
echo "Pub.dev version: $PUB_DEV_VERSION"

# Compare the local version with the version on pub.dev
if [ "$VERSION" = "$PUB_DEV_VERSION" ]; then
    echo "Error: The version $VERSION has already been published to pub.dev."
    exit 1
else
    echo "Version $VERSION is ready to be tagged and pushed."
    
    # Configure git user
    git config --local user.email "you@example.com"
    git config --local user.name "Your Name"

    # Fetch tags from the remote to update local reference
    git fetch --tags

    # Check if the tag already exists in the remote
    if git rev-parse "v$VERSION" >/dev/null 2>&1; then
        echo "Tag v$VERSION already exists. Skipping tag creation."
        exit 0
    else
        # Create a tag in Git with the new version
        echo "Publishing..."
        git tag -a "v$VERSION" -m "Release version $VERSION"
        git push origin "v$VERSION"
    fi
fi
