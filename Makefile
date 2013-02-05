all:
	jison src/pgn.y
	mv pgn.js lib/pgn.js