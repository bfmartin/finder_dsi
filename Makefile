# this duplicates some, but not all, of the Rakefile functionality
# and adds a style target

TXT := download/dialog-john.txt
JSN := data/dsidialog.json
REM := http://john.ccac.rwth-aachen.de:8000/ftp/dilbert/dilbert.txt

# run the unit tests
# download the dialog file and generate json file as pre-requisites
.PHONY: test
test:	$(JSN)
	@./test/run_suite.rb

notes:
	@grep -ER '(FIXME|TODO|XXX|THINKME):' ./* || :
	@cat TODO.md

# run rubocop and shellcheck. don't check stem.rb as it is external
style:
	-rubocop --cache=false bin test lib/finderdsi/entry.rb \
		lib/finderdsi/dialog.rb lib/finderdsi/ext.rb lib/finderdsi.rb
	shellcheck bin/*.sh

clean:
	rm -rf $(TXT) $(JSN)

$(JSN):	$(TXT)
	./bin/dsi-generate-dialog.rb $(TXT) > $(JSN)

$(TXT):
	mkdir -p download
	wget -O $(TXT) $(REM)
