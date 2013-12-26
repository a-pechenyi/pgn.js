all:
	./node_modules/.bin/jison src/pgn.y
	mv pgn.js lib/pgn.js