API_KEY=$(cat api_key)
VERSION="$1"
GIT_BRANCH="$VERSION"

if [[ -z "$VERSION" ]]; then
  VERSION="dev-0"
  GIT_BRANCH="main"
fi

specfile="laura-$VERSION.rockspec"
rockfile="laura-$VERSION.src.rock"

echo "Pushing to git..."
if [ "$VERSION" != "dev-0" ]; then
  git tag "$VERSION"
fi
git push origin "$GIT_BRANCH"

echo "Packing rock..."
luarocks pack "$specfile"

rm "$rockfile"

echo "Uploading rock..."
luarocks upload "$specfile" --api-key="$API_KEY"

echo "Deployed $VERSION"