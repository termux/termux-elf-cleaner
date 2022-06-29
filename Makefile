CXXFLAGS += -std=c++11 -Wall -Wextra -pedantic
PREFIX ?= /usr/local

elf-cleaner: elf-cleaner.cpp

clean:
	rm -f elf-cleaner

install: elf-cleaner
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install elf-cleaner $(DESTDIR)$(PREFIX)/bin/termux-elf-cleaner

uninstall:
	rm -f $(PREFIX)/bin/termux-elf-cleaner

.PHONY: clean install uninstall
