/*
 *  game.cpp
 *  vChess
 *
 *  Created by Sergey Seitov on 9/18/10.
 *  Copyright 2010 V-Channel. All rights reserved.
 *
 */

#include "game.h"
#include <stdexcept>

namespace vchess_viewer {

	Game::Game() {
		resetPosition();
		mTurnIndex = -1;
		mCurrentColor = CWHITE;
	}
	
	Game::Game(std::string white, std::string black) : mWhiteName(white), mBlackName(black) {
		resetPosition();
		mTurnIndex = -1;
		mCurrentColor = CWHITE;
	}
	
	Game::Game(const std::vector<std::string> &textTurns, std::string white, std::string black) : mWhiteName(white), mBlackName(black) {
		
		resetPosition();
		
		bool color = true;
		for (std::vector<std::string>::const_iterator p = textTurns.begin(); p != textTurns.end(); p++) {
			std::string text = *p;
			if (text.empty()) {
				continue;
			}
			if (text == "1-0" || text == "0-1" || text == "1/2-1/2") {
				mResult = text;
				break;
			} else {
				Turn t(text, color);
				if (TURN(t.turnType) != KingCastling && TURN(t.turnType) != QueenCastling) {
					t.fromPos = possibleBack(t);
					if (t.fromPos < 0) {
//						printPosition();
						std::string error = "PGN IS AMBIGUITY " + text;
						throw std::logic_error(error);
					}
					if (!IS_PROMOTE(t.turnType)) {
						t.figure = mPosition[t.fromPos];
					}
				}
				// make turn
				if (TURN(t.turnType) == Capture) {
					unsigned char figure = mPosition[t.toPos];
					if (figure > 0) {
						if (COLOR(figure) == OP_COLOR(t.figure)) {
							t.eatFigure = positionAt(t.toPos);
						} else {
//							printPosition();
							throw std::logic_error("Error parse " + t.turnText);
						}
					} else {
						unsigned char x, y;
						POS_FROM_NUM(t.toPos, x, y);
						y = (COLOR(t.figure) == CWHITE) ? 4 : 3;
						figure = mPosition[NUM_FROM_POS(x, y)];
						if (FIGURE(figure) == PAWN && COLOR(figure) == OP_COLOR(t.figure)) {
							t.eatFigure = figure;
							t.eatPos = NUM_FROM_POS(x, y);
						} else {
//							printPosition();
							throw std::logic_error("Error parse " + t.turnText);
						}
					}
				}
				mPosition[t.toPos] = t.figure;
				mPosition[t.fromPos] = 0;
				if (TURN(t.turnType) == KingCastling || TURN(t.turnType == QueenCastling)) {
					mPosition[t.rockToPos] = mPosition[t.rockFromPos];
					mPosition[t.rockFromPos] = 0;
				}
				if (t.eatPos > 0) {
//					printf("eat pos %d\n", t.eatPos);
					mPosition[t.eatPos] = 0;
				}
				mTurns.push_back(t);
 				color = !color;
			}
		}
 
		resetPosition();
		mTurnIndex = 0;
	}
	
	Game::~Game() {
	}
	
	static unsigned char emptyDesk[16*16] = {
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK,
		OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK, OUT_OF_DESK
	};
	
	void Game::resetPosition() {
		memcpy(mPosition, emptyDesk, sizeof(mPosition));
		
		for (int i=0; i<8; i++) {
			mPosition[NUM_FROM_POS(i, 1)] = PAWN | CWHITE;
		}
		mPosition[NUM_FROM_POS(4, 0)] = KING | CWHITE;
		mPosition[NUM_FROM_POS(3, 0)] = QUEEN | CWHITE;
		mPosition[NUM_FROM_POS(2, 0)] = BISHOP | CWHITE;
		mPosition[NUM_FROM_POS(1, 0)] = KNIGHT | CWHITE;
		mPosition[NUM_FROM_POS(0, 0)] = ROCK | CWHITE;
		mPosition[NUM_FROM_POS(5, 0)] = BISHOP | CWHITE;
		mPosition[NUM_FROM_POS(6, 0)] = KNIGHT | CWHITE;
		mPosition[NUM_FROM_POS(7, 0)] = ROCK | CWHITE;
		
		for (int i=0; i<8; i++) {
			mPosition[NUM_FROM_POS(i, 6)] = PAWN | CBLACK;
		}
		mPosition[NUM_FROM_POS(4, 7)] = KING | CBLACK;
		mPosition[NUM_FROM_POS(3, 7)] = QUEEN | CBLACK;
		mPosition[NUM_FROM_POS(2, 7)] = BISHOP | CBLACK;
		mPosition[NUM_FROM_POS(1, 7)] = KNIGHT | CBLACK;
		mPosition[NUM_FROM_POS(0, 7)] = ROCK | CBLACK;
		mPosition[NUM_FROM_POS(5, 7)] = BISHOP | CBLACK;
		mPosition[NUM_FROM_POS(6, 7)] = KNIGHT | CBLACK;
		mPosition[NUM_FROM_POS(7, 7)] = ROCK | CBLACK;
		
	}
	
	void Game::printPosition() {
		for (int i=7; i>=0; i--) {
			for (int j=0; j<8; j++) {
				printf("0x%x ", positionAt(NUM_FROM_POS(j, i)));
			}
			printf("\n");
		}
		printf("\n");
	}
	
	bool Game::hasNextTurn() {
		return (mTurnIndex < mTurns.size());
	}
	
	bool Game::hasPrevTurn() {
		return (mTurnIndex > 0);
	}
	
	Turn Game::nextTurn() {
		Turn t = mTurns[mTurnIndex];
		mPosition[t.toPos] = mPosition[t.fromPos];
		mPosition[t.fromPos] = 0;
		if (TURN(t.turnType) == KingCastling || TURN(t.turnType == QueenCastling)) {
			mPosition[t.rockToPos] = mPosition[t.rockFromPos];
			mPosition[t.rockFromPos] = 0;
		}
		if (t.eatPos >= 0) {
			mPosition[t.eatPos] = 0;
		}
//		printPosition();
		mTurnIndex++;
		return t;
	}
	
	Turn Game::prevTurn() {
		mTurnIndex--;
		Turn t = mTurns[mTurnIndex];
		mPosition[t.fromPos] = mPosition[t.toPos];
		mPosition[t.toPos] = 0;
		if (TURN(t.turnType) == KingCastling || TURN(t.turnType == QueenCastling)) {
			mPosition[t.rockFromPos] = mPosition[t.rockToPos];
			mPosition[t.rockToPos] = 0;
		}
		if (TURN(t.turnType) == Capture) {
			if (t.eatPos >= 0) {
				mPosition[t.eatPos] = t.eatFigure;
			} else {
				mPosition[t.toPos] = t.eatFigure;
			}
		}
		if (IS_PROMOTE(t.turnType)) {
			mPosition[t.fromPos] = COLOR(mPosition[t.toPos]) | PAWN;
		}
//		printPosition();
		return t;
	}
	
	static int deltaPos[5][9] = {
		{32+1, 32-1, 16+2, 16-2, -(32+1), -(32-1), -(16+2), -(16-2), 0},	// KNIGHT
		{17, -17, 15, -15, 0, 0, 0, 0, 0},									// BISHOP
		{16, -16, 1, -1, 0, 0, 0, 0, 0},									// ROCK
		{16, -16, 1, -1, 17, -17, 15, -15, 0},								// QUEEN
		{16, -16, 1, -1, 17, -17, 15, -15, 0}								// KING
	};
	static bool makeLine[5] = {false, true, true, true, false};
/*
	static void printAmbiguity(std::vector<int> &possible, int suppX, int suppY)
	{
		printf("IS AMBIGUITY. SUPPLEMENTAL %d %d\n", suppX, suppY);
		for (size_t i=0; i<possible.size(); i++) {
			printf("%d - %s\n", possible[i], POSITION_TEXT(possible[i]).data());
		}
	}
*/	
	static void correctPossible(std::vector<int> &possible, int suppX, int suppY)
	{
		std::vector<int>::iterator it = possible.begin();
		while (it != possible.end()) {
			unsigned char x,y;
			POS_FROM_NUM(*it, x, y);
			if (x != suppX && y != suppY) {
				it = possible.erase(it);
			} else {
				it++;
			}
		}
	}
	
	void Game::correctCheck(std::vector<int> &possible, unsigned char color)
	{
		std::vector<int>::iterator it = possible.begin();
		while (it != possible.end()) {
			int pos = *it;
			unsigned char f = mPosition[pos];
			mPosition[pos] = 0;
			if (isCheck(color)) {
				it = possible.erase(it);
			} else {
				it++;
			}
			mPosition[pos] = f;
		}
	}

	int Game::possibleBack(const Turn& t)
	{
		unsigned char figure = t.figure;
		if (IS_PROMOTE(t.turnType)) {
			figure = FIGURE_FLAGS(t.figure) | COLOR(t.figure) | PAWN;
		}
		if  (FIGURE(figure) == PAWN) {
			return possiblePawnBack(t);
		} else {
			int index = KNIGHT - FIGURE(figure);
			int *delta = deltaPos[index];
			bool line = makeLine[index];
			std::vector<int> possible;
			int i = 0;
			while  (delta[i]) {
				int pos = t.toPos + delta[i];
				if (line) {
					while (mPosition[pos] == 0) {
						pos += delta[i];
					}
				}
				unsigned char ff = mPosition[pos];
				if (FIGURE(ff) == FIGURE(figure) && COLOR(ff) == COLOR(t.figure)) {
					possible.push_back(pos);
				}
				i++;
			}
			if (t.suppX != -1 || t.suppY != -1) {
				correctPossible(possible, t.suppX, t.suppY);
			}
			if (possible.size() > 1) {
				correctCheck(possible, COLOR(t.figure));
			}
			return (possible.size() == 1) ? possible[0] : -1;
		}
	}
	
	int Game::possiblePawnBack(const Turn& t)
	{
		int direction = COLOR(t.figure) == CWHITE ? -1 : 1;
		if (TURN(t.turnType) == Capture) {
			std::vector<int> possible;
			static int addPos[2] = {15, 17};
			for (int i=0; i<2; i++) {
				int pos = t.toPos + direction*addPos[i];
				if (FIGURE(mPosition[pos]) == PAWN && COLOR(mPosition[pos]) == COLOR(t.figure)) {
					possible.push_back(pos);
				}
			}
			if (t.suppX != -1 || t.suppY != -1) {
				correctPossible(possible, t.suppX, t.suppY);
			}
			if (possible.size() > 1) {
				correctCheck(possible, COLOR(t.figure));
			}
			return (possible.size() == 1) ? possible[0] : -1;
		} else {
			int pos = t.toPos + direction*16;
			if (FIGURE(mPosition[pos]) == PAWN && COLOR(mPosition[pos]) == COLOR(t.figure)) {
				return pos;
			}
			if (!IS_MOVED(t.figure)) {
				pos = t.toPos + direction*32;
				if (FIGURE(mPosition[pos]) == PAWN && COLOR(mPosition[pos]) == COLOR(t.figure)) {
					return pos;
				}
			}
//			printf("NOT POSSIBLE\n");
			return -1;
		}
	}
	
	bool Game::possiblePawnForward(Turn& t)
	{
		t.figure = CLEAR_ENPASSAT(t.figure);
		int direction = COLOR(t.figure) == CWHITE ? 1 : -1;
		int pos = t.fromPos + direction*16;
		if (pos == t.toPos && mPosition[pos] == 0) {
			t.figure |= MOVED;
			return true;
		}
		if (!IS_MOVED(t.figure)) {
			pos = t.fromPos + direction*32;
			if (pos == t.toPos && mPosition[pos] == 0) {
				t.figure |= PAWN_ENPASSAT;
				return true;
			}
		}
		static int addPos[2] = {15, 17};
		for (int i=0; i<2; i++) {
			int capturePos = t.fromPos + direction*addPos[i];
			unsigned char captureFigure = mPosition[capturePos];
			if (!captureFigure) {
				captureFigure = mPosition[capturePos - direction*16];
				if (captureFigure) {
					if (IS_ENPASSAT(captureFigure)) {
						t.eatFigure = captureFigure;
						t.eatPos = capturePos - direction*16;
					} else {
						captureFigure = 0;
					}
				}
			}
			if (capturePos == t.toPos && captureFigure && COLOR(captureFigure) != COLOR(t.figure)) {
				t.turnType = Capture;
				unsigned char x,y;
				POS_FROM_NUM(t.fromPos, x, y);
				t.suppX = x;
				t.figure |= MOVED;
				return true;
			}
		}
		return false;
	}
	
	bool Game::possibleKingForward(Turn& turn) 
	{
		if (!IS_MOVED(turn.figure)) {
			if (turn.toPos == (COLOR(turn.figure) == CWHITE ? NUM_FROM_POS(6, 0) : NUM_FROM_POS(6, 7))) {
				int rockFromPos = COLOR(turn.figure) == CWHITE ? NUM_FROM_POS(7, 0) : NUM_FROM_POS(7, 7);
				unsigned char f = mPosition[rockFromPos];
				if (f && !IS_MOVED(f)) {
					turn.turnType = KingCastling;
					turn.rockFromPos = rockFromPos;
					turn.rockToPos = COLOR(turn.figure) == CWHITE ? NUM_FROM_POS(5, 0) : NUM_FROM_POS(5, 7);
					mPosition[turn.rockToPos] = mPosition[rockFromPos] | MOVED;
					mPosition[rockFromPos] = 0;
					turn.figure |= MOVED;
					return true;
				} else {
					return false;
				}
			} else if (turn.toPos == (COLOR(turn.figure) == CWHITE ? NUM_FROM_POS(2, 0) : NUM_FROM_POS(2, 7))) {
				int rockFromPos = COLOR(turn.figure) == CWHITE ? NUM_FROM_POS(0, 0) : NUM_FROM_POS(0, 7);
				unsigned char f = mPosition[rockFromPos];
				if (f && !IS_MOVED(f)) {
					turn.turnType = QueenCastling;
					turn.rockFromPos = rockFromPos;
					turn.rockToPos = COLOR(turn.figure) == CWHITE ? NUM_FROM_POS(3, 0) : NUM_FROM_POS(3, 7);
					mPosition[turn.rockToPos] = mPosition[rockFromPos] | MOVED;
					mPosition[rockFromPos] = 0;
					turn.figure |= MOVED;
					return true;
				} else {
					return false;
				}
			}
		}
		return possibleForward(turn);
	}
	
	bool Game::possibleForward(Turn& turn) 
	{
		int index = KNIGHT - FIGURE(turn.figure);
		int *delta = deltaPos[index];
		bool line = makeLine[index];
		std::vector<int> possible;
		int i = 0;
		
		while  (delta[i]) {
			int pos = turn.toPos + delta[i];
			if (line) {
				while (mPosition[pos] == 0) {
					pos += delta[i];
				}
			}
			unsigned char ff = mPosition[pos];
			if (FIGURE(ff) == FIGURE(turn.figure) && COLOR(ff) == COLOR(turn.figure)) {
				possible.push_back(pos);
			}
			i++;
		}
		if (possible.size() < 1 || possible.size() > 2) {
			return false;
		}
		if (possible.size() == 2) {
			int otherPos = (possible[0] == turn.fromPos ? possible[1] : possible[0]);
			unsigned char x, y, otherX, otherY;
			POS_FROM_NUM(turn.fromPos, x, y);
			POS_FROM_NUM(otherPos, otherX, otherY);
			if (x != otherX) {
				turn.suppX = x;
			} else if (y != otherY) {
				turn.suppY = y;
			} else {
				return false;
			}
		}
		unsigned char captureFigure = mPosition[turn.toPos];
		if (captureFigure) {
			if (COLOR(captureFigure) != COLOR(turn.figure)) {
				turn.turnType = Capture;
				return true;
			} else {
				return false;
			}
		} else {
			turn.turnType = Normal;
			return true;
		}
	}
	
	bool Game::addTurn(Turn& turn) 
	{
		if (turn.toPos < 0) return false;
		if (turn.toPos == turn.fromPos) return false;
		
		turn.figure = mPosition[turn.fromPos];
			
		if (FIGURE(turn.figure) == KING) {
			if (!possibleKingForward(turn)) return false;
		} else if (FIGURE(turn.figure) == PAWN) {
			if (!possiblePawnForward(turn)) return false;
		} else {
			if (!possibleForward(turn)) return false;
		}
		
		if (turn.turnType == KingCastling) {
			turn.turnText = "O-O";
		} else if (turn.turnType == QueenCastling) {
			turn.turnText = "O-O-O";
		} else {
			turn.turnText = FIGURE_TEXT(mPosition[turn.fromPos]);
			if (turn.suppX >= 0) {
				turn.turnText.append(1, 'a' + turn.suppX);
			}
			if (turn.suppY >= 0) {
				turn.turnText.append(1, '1' + turn.suppY);
			}
			if (turn.turnType & Capture) {
				turn.turnText += "x";
			}
			turn.turnText += POSITION_TEXT(turn.toPos);
		}
		
		unsigned char oldFromPos = mPosition[turn.fromPos];
		unsigned char oldToPos = mPosition[turn.toPos];
		
		mPosition[turn.toPos] = turn.figure | MOVED;
		mPosition[turn.fromPos] = 0;
		
		if (FIGURE(turn.figure) == PAWN) {
			int promotePos = (COLOR(turn.figure) == CWHITE ? 7 : 0);
			unsigned char x, y;
			POS_FROM_NUM(turn.toPos, x, y);
			if (y == promotePos) {
				turn.turnType |= PROMOTE;
				mPosition[turn.toPos] = QUEEN | COLOR(turn.figure);
			}
		}
				
		if (isCheck(COLOR(turn.figure))) {
			mPosition[turn.fromPos] = oldFromPos;
			mPosition[turn.toPos] = oldToPos;
			return false;
		}
		if (doCheck(turn)) {
			turn.turnText += "+";
		}
		
		mTurns.push_back(turn);
		mTurnIndex++;
		
		if (mCurrentColor == CWHITE) {
			mCurrentColor = CBLACK;
		} else {
			mCurrentColor = CWHITE;
		}
		return true;
	}
	
	int Game::kingPosition(unsigned char color) {
		for (int i = 0; i < POSITION_SIZE; i++) {
			unsigned char figure = mPosition[i];
			if (FIGURE(figure) == KING && COLOR(figure) == color) {
				return i;
			}
		}
		return -1;
	}
	
	bool Game::doCheck(Turn turn) {
		if (FIGURE(turn.figure) == KING) return false;
		turn.fromPos = turn.toPos;
		turn.toPos = kingPosition(OP_COLOR(turn.figure));
		turn.turnType = Capture;
		if (FIGURE(turn.figure) == PAWN) {
			return possiblePawnForward(turn);
		} else {
			return possibleForward(turn);
		}
	}
	
	bool Game::isCheck(unsigned char color) {
		
		int king = kingPosition(color);
		bool check = false;
		for (int i = 0; i < POSITION_SIZE; i++) {
			if (mPosition[i] > 0 && mPosition[i] < OUT_OF_DESK && OP_COLOR(mPosition[i]) == color) {
				Turn turn;
				turn.figure = mPosition[i];
				turn.fromPos = i;
				turn.toPos = king;
				turn.turnType = Capture;
				if (FIGURE(turn.figure) == PAWN) {
					check = possiblePawnForward(turn);
				} else {
					check = possibleForward(turn);
				}
				if (check) {
					break;
				}
			}
		}
		return check;
	}
}
