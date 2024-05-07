NAME = FloatClock
PREFIX = /usr/local
BIN_DIR = $(PREFIX)/bin
LAUNCH_AGENTS_DIR = $(HOME)/Library/LaunchAgents

PLIST = $(NAME).plist
INSTALLED_PLIST = $(LAUNCH_AGENTS_DIR)/$(PLIST)

.PHONY: install uninstall all clean register unregister

all: $(NAME) ## Compile all

$(NAME): $(NAME).swift
	swiftc $< -o $@

$(PLIST): $(PLIST).in
	cat $< | sed 's,@BIN_DIR@,$(BIN_DIR),g;s,@NAME@,$(NAME),g' > $@

clean: ## Remove build files.
	rm -f $(NAME) $(PLIST)

install: $(NAME) $(PLIST) ## Install to bin directory.
	install -m 755 $(NAME) $(BIN_DIR)
	install -m 644 $(PLIST) $(INSTALLED_PLIST)

uninstall: unregister ## remove from bin directory.
	rm -f $(NAME) $(INSTALLED_PLIST)

unregister: ## Unregister from launchctl.
	test -f $(INSTALLED_PLIST) && launchctl unload $(INSTALLED_PLIST) || true

register: install ## register to launchctl.
	launchctl load $(INSTALLED_PLIST)

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

test: ## Run Test
	swift test