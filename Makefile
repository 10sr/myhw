project_root_dir := $(PWD)

brew_dir ?= $(project_root_dir)/.brew
brew_repository ?= https://github.com/Homebrew/linuxbrew.git

brew := PATH=$(brew_dir)/bin:$$PATH brew

formulae := $(wildcard Formula/*.rb)
formulae := $(formulae:Formula/%.rb=%)

.PHONY: check prepare $(formulae)

check: prepare $(formulae)

prepare:
	test -d $(brew_dir) || git clone $(brew_repository) $(brew_dir) --depth=5
	cd $(brew_dir) && git fetch origin && git checkout -f origin/master

$(formulae):
	$(brew) audit $(project_root_dir)/Formula/$@.rb
	$(brew) $(brew) unlink $@ || true
	# NOTE: Dirty fix for erutaso and pyonpyon that tries to install twice
	# For more information (in japanese):
	# http://10sr-p.hateblo.jp/entry/2015/08/14/143207
	$(brew) install $(project_root_dir)/Formula/$@.rb || \
		$(brew) install $(project_root_dir)/Formula/$@.rb
