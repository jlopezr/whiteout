APP=Whiteout
BIN=$(APP)
SRC=whiteout.swift
APPDIR=$(APP).app
MACOSDIR=$(APPDIR)/Contents/MacOS
CONTENTSDIR=$(APPDIR)/Contents

all: $(APPDIR)

$(BIN): $(SRC)
	swiftc $(SRC) -o $(BIN)

$(APPDIR): $(BIN)
	mkdir -p $(MACOSDIR)
	cp $(BIN) $(MACOSDIR)/$(APP)
	printf '%s\n' \
	'<?xml version="1.0" encoding="UTF-8"?>' \
	'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
	'<plist version="1.0">' \
	'<dict>' \
	'    <key>CFBundleExecutable</key>' \
	'    <string>$(APP)</string>' \
	'    <key>CFBundleIdentifier</key>' \
	'    <string>local.$(APP)</string>' \
	'    <key>CFBundleName</key>' \
	'    <string>$(APP)</string>' \
	'    <key>CFBundlePackageType</key>' \
	'    <string>APPL</string>' \
	'    <key>CFBundleVersion</key>' \
	'    <string>1.0</string>' \
	'    <key>CFBundleShortVersionString</key>' \
	'    <string>1.0</string>' \
	'</dict>' \
	'</plist>' > $(CONTENTSDIR)/Info.plist

run: $(APPDIR)
	open $(APPDIR)

clean:
	rm -rf $(BIN) $(APPDIR)

.PHONY: all run clean
