# this duplicates some, but not all, of the Rakefile functionality
# and adds a style target

TXT := download/dialog-john.txt
JSN := data/dsidialog.json
REM := http://john.ccac.rwth-aachen.de:8000/ftp/dilbert/dilbert.txt

# used for the count target. exclude stem.rb as it's external
FILES = bin/* test/*.rb Makefile lib/finderdsi/entry.rb lib/finderdsi/dialog.rb \
	lib/finderdsi/ext.rb lib/finderdsi.rb

# run the unit tests
# download the dialog file and generate json file as pre-requisites
.PHONY: test
test:	$(JSN)
	@./test/run_suite.rb

notes:
	@grep -ER '(FIXME|TODO|XXX|THINKME):' ./* || :
	@cat TODO.md

# run rubocop and shellcheck. rubocop uses .rubocop.yml (that config
# file excludes stem.rb as it is external)
style:
	-rubocop --cache=false lib bin test
	shellcheck bin/*.sh

clean:
	rm -rf $(TXT) $(JSN)

$(JSN):	$(TXT)
	./bin/dsi-generate-dialog.rb $(TXT) > $(JSN)

$(TXT):
	mkdir -p download
	wget -O $(TXT) $(REM)

count:
	@FCOUNT=$$(ls ${FILES} | wc -l) && \
		LCOUNT=$$(cat ${FILES} | sed "s/#.*//" | awk NF | wc -l) && \
		AVG=$$(echo "scale=1;$$LCOUNT/$$FCOUNT" | bc -l) && \
		echo $$(date +%Y-%m-%d), "$$LCOUNT", "$$FCOUNT", "$$AVG"
