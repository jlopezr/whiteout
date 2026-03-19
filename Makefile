APP=Whiteout
BIN=$(APP)
SRC=whiteout.swift
APPDIR=$(APP).app
MACOSDIR=$(APPDIR)/Contents/MacOS
CONTENTSDIR=$(APPDIR)/Contents
RESDIR=$(CONTENTSDIR)/Resources
ICON_MASTER=assets/master.png
ICONSET_DIR=Icon.iconset
ICNS_NAME=AppIcon.icns

all: $(APPDIR)

$(BIN): $(SRC)
	swiftc $(SRC) -o $(BIN)

$(APPDIR): $(BIN)
	mkdir -p $(MACOSDIR)
	cp $(BIN) $(MACOSDIR)/$(APP)
	mkdir -p $(RESDIR)
	# If a master icon exists, generate .icns and place in Contents/Resources
	if [ -f "$(ICON_MASTER)" ]; then \
		rm -rf "$(ICONSET_DIR)"; \
		mkdir -p "$(ICONSET_DIR)"; \
		sips -z 16 16   "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_16x16.png" >/dev/null 2>&1; \
		sips -z 32 32   "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_16x16@2x.png" >/dev/null 2>&1; \
		sips -z 32 32   "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_32x32.png" >/dev/null 2>&1; \
		sips -z 64 64   "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_32x32@2x.png" >/dev/null 2>&1; \
		sips -z 128 128 "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_128x128.png" >/dev/null 2>&1; \
		sips -z 256 256 "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_128x128@2x.png" >/dev/null 2>&1; \
		sips -z 256 256 "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_256x256.png" >/dev/null 2>&1; \
		sips -z 512 512 "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_256x256@2x.png" >/dev/null 2>&1; \
		sips -z 512 512 "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_512x512.png" >/dev/null 2>&1; \
		sips -z 1024 1024 "$(ICON_MASTER)" --out "$(ICONSET_DIR)/icon_512x512@2x.png" >/dev/null 2>&1; \
		iconutil -c icns "$(ICONSET_DIR)" -o "$(ICNS_NAME)" >/dev/null 2>&1 || true; \
		if [ -f "$(ICNS_NAME)" ]; then \
			mv "$(ICNS_NAME)" "$(RESDIR)/$(ICNS_NAME)"; \
		fi; \
		rm -rf "$(ICONSET_DIR)"; \
	fi
	# Write Info.plist (including icon file reference)
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
	'    <key>CFBundleIconFile</key>' \
	'    <string>AppIcon</string>' \
	'</dict>' \
	'</plist>' > $(CONTENTSDIR)/Info.plist

run: $(APPDIR)
	open $(APPDIR)

clean:
	rm -rf $(BIN) $(APPDIR) Icon.iconset AppIcon.icns

.PHONY: all run clean
