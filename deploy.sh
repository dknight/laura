#!/bin/bash

result=0
make test
result=$?
if [[ $result -ne 0 ]]; then
  exit $result
fi

make lint
result=$?
if [[ $result -ne 0 ]]; then
  exit $result
fi

API_KEY=$(cat luarocks_apikey)
VERSION="$1"
GIT_BRANCH="$VERSION"
VERSION_FILE="./src/laura/version.lua"

if [[ -z "$VERSION" ]]; then
  VERSION="dev-0"
  GIT_BRANCH="main"
fi

specfile="laura-$VERSION.rockspec"
rockfile="laura-$VERSION.src.rock"

cp laura-dev-0.rockspec "$specfile"

sed -i -e "s/\"main\"/\"$VERSION\"/g" "$specfile"
sed -i -e "s/\"dev-0\"/\"$VERSION\"/g" "$specfile"

printf "return \"%s\"" "$VERSION" > "$VERSION_FILE"
cp "$specfile" rockspec
git add "$VERSION_FILE" "rockspec/$specfile"
git ci -m "release: $VERSION"

echo "Pushing to git..."
if [ "$VERSION" != "dev-0" ]; then
  git tag "$VERSION"
fi
git push origin "$GIT_BRANCH"

echo "Packing rock..."
luarocks pack "$specfile"

echo "Uploading rock..."
luarocks upload "$specfile" --api-key="$API_KEY"

rm -f "$rockfile" "$specfile"

echo "Deployed $VERSION"