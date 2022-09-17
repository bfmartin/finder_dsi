# this duplicates some, but not all, of the Rakefile functionality

TXT := download/dialog-john.txt
JSN := data/dsidialog.json
REM := http://john.ccac.rwth-aachen.de:8000/ftp/dilbert/dilbert.txt

# run the unit tests
# download the dialog file and generate json file as pre-requisites
.PHONY: test
test:	$(JSN)
	@./test/run_suite.rb

clean:
	rm -rf $(TXT) $(JSN)

$(JSN):	$(TXT)
	./bin/dsi-generate-dialog.rb $(TXT) > $(JSN)

$(TXT):
	mkdir -p download
	wget -O $(TXT) $(REM)

# housekeeping tasks. only of interest to the author
SHX = bin/*.sh
RBX = bin/*.rb lib/*.rb lib/finderdsi/entry.rb lib/finderdsi/dialog.rb lib/finderdsi/ext.rb test/*.rb
XTRAC = Makefile
sinclude ~/bin/lib/Makefile-global
