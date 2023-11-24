all:

install:
	set -- -f; bash bootstrap.sh

clean:
	rm -f ~/.cvsrc
