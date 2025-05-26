run-all-tests:
	echo "A test with ARITHMETIC & LOGIC operations is starting...." && sleep 2 && \
	cd test/instructions && make arith_set && cd .. && make && \
	echo "Press Enter to continue..." && read && \
	echo "A test with JUMP & BRANCH operations is starting...." && sleep 2 && \
	cd instructions && make jb_set && cd .. && make && \
	echo "Press Enter to continue..." && read && \
	echo "A test with LOAD & STORE operations is starting...." && sleep 2 && \
	cd instructions && make ls_set && cd .. && make && \
	echo "Press Enter to continue..." && read && \
	echo "A test with MIXED with all type of operations is starting...." && sleep 2 && \
	cd instructions && make mixed_set && cd .. && make



# WORKING?? - I HOPE !
run-win:
	@echo "A test with ARITHMETIC & LOGIC operations is starting...."
	@sleep 2
	@cd test/instructions && $(MAKE) arith_set
	@cd test && $(MAKE)
	@read -p "Press Enter to continue..." dummy

	@echo "A test with JUMP & BRANCH operations is starting...."
	@sleep 2
	@cd test/instructions && $(MAKE) jb_set
	@cd test && $(MAKE)
	@read -p "Press Enter to continue..." dummy

	@echo "A test with LOAD & STORE operations is starting...."
	@sleep 2
	@cd test/instructions && $(MAKE) ls_set
	@cd test && $(MAKE)
	@read -p "Press Enter to continue..." dummy

	@echo "A test with MIXED with all type of operations is starting...."
	@sleep 2
	@cd test/instructions && $(MAKE) mixed_set
	@cd test && $(MAKE)
