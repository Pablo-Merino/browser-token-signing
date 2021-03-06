# EstEID Browser Plugin
ifeq ($(BUILD_NUMBER),)
BUILD_NUMBER = 0
endif
include VERSION.mk
CC = gcc
OUT = npesteid-firefox-plugin.so
PKCS11_DRIVER = opensc-pkcs11.so
COMMON_HEADERS = common/esteid_certinfo.h common/atr_fetcher.h common/pkcs11_path.h common/pkcs11_errors.h common/esteid_log.h common/esteid_sign.h common/esteid_timer.h common/esteid_time.h common/l10n.h common/labels.h common/esteid_map.h common/esteid_dialog_common.h common/dialogs.h
COMMON_SOURCES = common/esteid_certinfo.c common/atr_fetcher.c common/pkcs11_path.c common/pkcs11_errors.c common/esteid_log.c common/esteid_sign.c common/esteid_timer.c common/esteid_time.c common/l10n.c common/l10n-linux.c common/esteid_map.c common/esteid_dialog_common.c
C_FLAGS = -g -O2 -std=gnu99 -Wall $(CPPFLAGS)
I_FLAGS = -Iinclude -Icommon `pkg-config --cflags gtk+-2.0 libpcsclite`
L_FLAGS = -ldl -lcrypto -lpthread `pkg-config --libs gtk+-2.0 libpcsclite`
D_FLAGS = -DXP_UNIX -DMOZ_X11 -DVERSION=\"$(VERSION)\"
PLUGIN_HEADERS = firefox/plugin.h firefox/plugin-class.h firefox/cert-class.h
PLUGIN_SOURCES = firefox/plugin.c firefox/plugin-class.c firefox/cert-class.c firefox/dialogs-gtk.c

clean:
	rm -f test
	rm -f $(OUT)

plugin: $(COMMON_HEADERS) $(COMMON_SOURCES) $(PLUGIN_HEADERS) $(PLUGIN_SOURCES)
	$(CC) $(C_FLAGS) -fPIC -shared -o $(OUT) $(PLUGIN_SOURCES) $(COMMON_SOURCES) $(I_FLAGS) $(L_FLAGS) $(D_FLAGS) $(MODE_FLAG) -DPKCS11_DRIVER=\"$(PKCS11_DRIVER)\"

pluginlt: $(COMMON_HEADERS) $(COMMON_SOURCES) $(PLUGIN_HEADERS) $(PLUGIN_SOURCES)
	$(CC) $(C_FLAGS) -fPIC -shared -o npesteid-firefox-plugin-lt.so $(PLUGIN_SOURCES) $(COMMON_SOURCES) $(I_FLAGS) $(L_FLAGS) $(D_FLAGS) $(MODE_FLAG) -DPKCS11_DRIVER=\"/usr/lib/ccs/libccpkip11.so\"

pluginlv: $(COMMON_HEADERS) $(COMMON_SOURCES) $(PLUGIN_HEADERS) $(PLUGIN_SOURCES)
	$(CC) $(C_FLAGS) -fPIC -shared -o npesteid-firefox-plugin-lv.so $(PLUGIN_SOURCES) $(COMMON_SOURCES) $(I_FLAGS) $(L_FLAGS) $(D_FLAGS) $(MODE_FLAG) -DPKCS11_DRIVER=\"otlv-pkcs11.so\"

plugin-development:
	MODE_FLAG=-DDEVELOPMENT_MODE make plugin 

install: plugin
	install -d $(HOME)/.mozilla/plugins
	install $(OUT) $(HOME)/.mozilla/plugins

installall: plugin pluginlt pluginlv

maptest: plugin common/esteid_map_test.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(C_FLAGS) common/esteid_map.c common/esteid_map_test.c -o maptest
	./maptest
	rm maptest
