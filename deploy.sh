API_KEY=$(cat api_key)
VERSION="$1"

if [[ -z "$VERSION" ]]; then
  echo "No version set as \$1 arg"
  exit 1
fi

specfile="laura-$VERSION.rockspec"

echo "Pushing to git..."
git tag "$VERSION"
git push origin "$VERSION"

echo "Packing rock..."
luarocks pack "$specfile"

echo "Uploading rock..."
luarocks upload "$specfile" --api-key="$API_KEY"

echo "Deployed $VERSION"