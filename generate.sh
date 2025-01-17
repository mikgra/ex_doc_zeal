#!/bin/bash

PACKAGE=$1
DOCSETS_PATH=~/.local/share/Zeal/Zeal/docsets
# Download and move to input
rm -rf ~/.hex/docs/hexpm/${PACKAGE}
rm -rf _input
mkdir _input

mix hex.docs fetch ${PACKAGE}
mv ~/.hex/docs/hexpm/${PACKAGE}/*/*.tar.gz _input/doc.tar.gz

# Generate and move to output/install

rm -rf _output
mkdir -p _output/${PACKAGE}.docset/Contents/Resources/Documents

echo "{\"name\": \"${PACKAGE}\",\"revision\": \"0\",\"title\": \"${PACKAGE}\",\"version\": \"0.0.1\"}" > _output/${PACKAGE}.docset/meta.json
cp -rf icon.png _output/${PACKAGE}.docset/icon.png
cp -rf icon@2x.png _output/${PACKAGE}.docset/icon@2x.png
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><plist version=\"1.0\"><dict><key>CFBundleIdentifier</key><string>${PACKAGE}</string><key>CFBundleName</key><string>${PACKAGE}</string><key>DocSetPlatformFamily</key><string>${PACKAGE}</string><key>dashIndexFilePath</key><string>api-reference.html</string><key>isDashDocset</key><true/><key>DashDocSetFamily</key><string>dashtoc</string><key>isJavaScriptEnabled</key><true/><key>DashDocSetDeclaredInStyle</key><string>originalName</string><key>DashDocSetPluginKeyword</key><string>elixir</string></dict></plist>" > _output/${PACKAGE}.docset/Contents/Info.plist
tar zxf _input/doc.tar.gz -C _output/${PACKAGE}.docset/Contents/Resources/Documents

# Build sqlite3 DB

cd _output/${PACKAGE}.docset/Contents/Resources/Documents
echo "CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"  | sqlite3 ../docSet.dsidx
#find . -name "*.html" | xargs -n 1 ruby ../../../../../src/generate.rb
find . -name "*.html" | xargs -n 1 ruby ../../../../../src/generate.rb | sqlite3 ../docSet.dsidx

# Copy everything to docsets folder

cd -
rm -rf "${DOCSETS_PATH}/${PACKAGE}.docset"
mkdir -p "${DOCSETS_PATH}/${PACKAGE}.docset"
cp -r "_output/${PACKAGE}.docset" "${DOCSETS_PATH}"
