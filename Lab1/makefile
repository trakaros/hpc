# Makefile. If you change it, remember than in makefiles multiple spaces
# ARE NOT EQUIVALENT to tabs. The line after a rule starts with a tab!




DIRECTORIES =  0_orig 1_loopInter 2_loopUnrol 3_loopFusion 4_funcInline 5_loopInvariant
targets = 0_orig/0_orig 1_loopInter/1_loopInter 2_loopUnrol/2_loopUnrol 3_loopFusion/3_loopFusion 4_funcInline/4_funcInline 5_loopInvariant/5_loopInvariant

#SRC_DIR = $(MODULES)
#BUILD_DIR = $(MODULES)

#SRC = $(foreach sdir, $(MODULES), $(*.c) )
#OBJ = $(patsubst %.c, %.o, $(SRC) )

#vpath %.c $(SRC_DIR)
#Add any executable you want to be created here.
#EXECUTABLES_O0	= 0_orig_O0 
#EXECUTABLES_FAST = 0_orig_fast 



#This is the compiler to use
CC = icc

#These are the flags passed to the compiler. Change accordingly
CFLAGS_O0 = -Wall -O0
CFLAGS_FAST = -Wall -fast

#These are the flags passed to the linker. Nothing in our case
#LDFLAGS = -lm


#$(CC) $(CFLAGS_FAST) -g $1/$1.c  -o $1/$1_fast
# my make
#define make-goal 
#$1/$1: 
#	$(CC) $(CFLAGS_O0) -c $1/$1.c  -o $1/$1_O0
#	$(CC) $(CFLAGS_FAST) -c $1/$1.c  -o $1/$1_fast	
#endef

.PHONY: all 
all: $(targets)
$(Directories): $(Directories)%.c
	$(CC) $(CFLAGS_O0) -g $(Directories)  -o mitsos#$(Directories)
	#$(CC) $(CFLAGS_FAST) -g $(Directories)  -o $(Directories)
	#$(foreach currDir,$(DIRECTORIES),$(eval $(call make-goal,$(currDir))))

	
# This is the rule to create any executable from the corresponding .c 
# file with the shttps://www.facebook.com/ame name.

# make clean will remove all executables, jpg files and the 
# output of previous executions.
clean:
	rm -f $(targets) *.jpg output_sobel.grey





# make image will create the output_sobel.jpg from the output_sobel.grey. 
# Remember to change this rule if you change the name of the output file.
image: output_sobel.grey
	convert -depth 8 -size 4096x4096 GRAY:output_sobel.grey output_sobel.jpg 

