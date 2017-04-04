CXXFLAGS += -std=c++11 -Wall -Wextra -pedantic
PREFIX ?= /usr/local

termux-elf-cleaner: termux-elf-cleaner.cpp

clean:
	rm -f termux-elf-cleaner

install: termux-efl-cleaner
	mkdir -p $(PREFIX)/bin

uninstall:
	rm -f $(PREFIX)/bin/termux-elf-cleaner

.PHONY: clean install uninstall
