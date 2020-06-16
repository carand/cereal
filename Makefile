CMAKE = cmake
#Switch to activatad Build Type
BUILD_TYPE=Debug
# BUILD_TYPE=Release
# BUILD_TYPE=RelWithDebInfo
# BUILD_TYPE=MinSizeRel

# DEFAULT_RUN_ARGS= " -w -v -k -d -f -a -o -r"

SRC_DIR=./src
INC_DIR=./include
CMAKE_BUILD_DIR= build
BROWSER=sensible-browser
HTML_INDEX_FILE=${CMAKE_BUILD_DIR}/doc/html/index.html
compile_commands=$(CMAKE_BUILD_DIR)/compile_commands.json

APP_NAME=cereal
APP_TEST=unittests_$(APP_NAME)


SPELLGEN=./support/generateSpellingListFromCTags.py
SPELLFILE=$(APP_NAME)FromTags
# TEST_APP_NAME=rfidTestApp
CMAKE_TEST_APP_DIR= $(CMAKE_BUILD_DIR)

# Switch to your prefered build tool.
BUILD_TOOL = "Unix Makefiles"
# BUILD_TOOL = "CodeBlocks - Unix Makefiles"
# BUILD_TOOL = "Eclipse CDT4 - Unix Makefiles"

# -DCMAKE_BUILD_TYPE=Debug -DCMAKE_ECLIPSE_GENERATE_SOURCE_PROJECT=TRUE -DCMAKE_ECLIPSE_MAKE_ARGUMENTS=-j3 -DCMAKE_ECLIPSE_VERSION=4.1

default: $(APP_NAME)

$(CMAKE_BUILD_DIR): generate_build_tool

$(APP_NAME): | $(CMAKE_BUILD_DIR)
	$(MAKE) -C $(CMAKE_BUILD_DIR) default_target
##
## @brief DocTest
##
##
all: | $(CMAKE_BUILD_DIR)
	$(MAKE) -C $(CMAKE_BUILD_DIR) all
##
#
# clean:
clean: clean_spell
	$(RM) -r tags
	$(RM) -r cscope.out
	cd $(CMAKE_BUILD_DIR) &&  $(MAKE) clean $(ARGS); cd ..
	# $(MAKE) -C $(CMAKE_BUILD_DIR) clean

# $(APP_TEST): | $(CMAKE_BUILD_DIR)
	# $(MAKE) -C $(CMAKE_BUILD_DIR) $(APP_TEST)

utest: $(APP_TEST) | $(CMAKE_BUILD_DIR)
	$(MAKE) -C $(CMAKE_BUILD_DIR) test

build: generate_build_tool
	# $(CMAKE) --build $(CMAKE_BUILD_DIR)
	# $(MAKE) all

# run: $(APP_NAME)
	# @( $(MAKE) -C  $(CMAKE_BUILD_DIR) link_target  )
	# cd $(CMAKE_BUILD_DIR) &&  ./$(APP_NAME) $(ARGS); cd ..



# gdb_run: $(APP_NAME)
# gdb_run:
#	@( $(MAKE) -C  $(CMAKE_BUILD_DIR) link_target  )
#	cd $(CMAKE_BUILD_DIR) && tgdb --args $(APP_NAME) $(ARGS); cd ..
	# cd $(CMAKE_BUILD_DIR) && gdb --args $(APP_NAME) $(ARGS); cd ..

	# cd $(CMAKE_BUILD_DIR) &&  valgrind --leak-check=full -v ./$(APP_NAME) $(ARGS); cd ..

# memcheck: $(APP_NAME)
#	@( $(MAKE) -C  $(CMAKE_BUILD_DIR) link_target  )
#	# cd $(CMAKE_BUILD_DIR) && valgrind --leak-check=full  --track-origins=yes -v ./$(APP_NAME) $(ARGS); cd ..
#	# cd $(CMAKE_BUILD_DIR) && valgrind --leak-check=full -v ./$(APP_NAME) $(ARGS); cd ..
#	cd $(CMAKE_BUILD_DIR) && valgrind --leak-check=full --show-leak-kinds=all -v ./$(APP_NAME) $(ARGS); cd ..



# vmemcheck: $(APP_NAME)
# ifeq ($(ARGS),)
#	$(MAKE) ARGS=$(DEFAULT_RUN_ARGS) memcheck
# else
#	@( $(MAKE) -C  $(CMAKE_BUILD_DIR) link_target  )
#	# cd $(CMAKE_BUILD_DIR) && valgrind --leak-check=full  --track-origins=yes -v ./$(APP_NAME) $(ARGS); cd ..
#	# cd $(CMAKE_BUILD_DIR) && valgrind --leak-check=full -v ./$(APP_NAME) $(ARGS); cd ..
#	cd $(CMAKE_BUILD_DIR) && valgrind --leak-check=full --vgdb=yes --vgdb-error=0 ./$(APP_NAME) $(ARGS); cd ..
# endif

# memcheck_test: $(APP_TEST)
#	cd $(CMAKE_BUILD_DIR) &&  valgrind --leak-check=full -v ./$(APP_TEST); cd ..

# cppcheck:
#	cppcheck --enable=all $(INC_DIR) $(SRC_DIR)

# # cppcheck: | $(compile_comands)
#	# cd $(CMAKE_BUILD_DIR) && cppcheck --project=compile_commands.json; cd ..


compile_commands: $(compile_comands)

$(compile_commands): $(APP_NAME) | $(CMAKE_BUILD_DIR)
	$(MAKE) -C $(CMAKE_BUILD_DIR) $(APP_NAME)


generate_build_tool:
	$(CMAKE) -H. -B$(CMAKE_BUILD_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -G $(BUILD_TOOL)


docs: | $(CMAKE_BUILD_DIR)
	$(MAKE) -C $(CMAKE_BUILD_DIR) doc

viewHtmlDoc: docs
	@($(BROWSER) $(HTML_INDEX_FILE))


coverage: | $(CMAKE_BUILD_DIR)
	@($(MAKE) -C $(CMAKE_BUILD_DIR) coverage && ${BROWSER} assets/coverage/index.html)


tags: | $(CMAKE_BUILD_DIR)
	@($(MAKE) -C $(CMAKE_BUILD_DIR) tags)

genspell: docs tags | $(CMAKE_BUILD_DIR)
	 python $(SPELLGEN) -o ~/.vim/spell -t tags -i $(CMAKE_BUILD_DIR)/doc/xml/index.xml $(SPELLFILE)

.PHONY: clean_spell
clean_spell:
	python2 $(SPELLGEN) -o ~/.vim/spell --clear $(SPELLFILE)

spell:
	mdspell --en-us --de-de --ignore-numbers ./doc/*.md


rtags: compile_commands
	rc -J $(compile_commands)


.PHONY: distclean
distclean:  clean
	$(RM) -r $(CMAKE_BUILD_DIR)
	$(RM) -r Release
	$(RM) -r Debug
	$(RM) -r CodeblocksDebug
	$(RM) -r CodeblocksRelease
	$(RM) tags
	$(RM) cscope.out
	$(RM) cscope.out.*
	$(RM) *.orig
	$(RM) ncscope.out.*

