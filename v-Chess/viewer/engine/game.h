/*
 *  game.h
 *  vChess
 *
 *  Created by Sergey Seitov on 9/18/10.
 *  Copyright 2010 V-Channel. All rights reserved.
 *
 */

#ifndef __VCHESS_GAME__
#define __VCHESS_GAME__

#include <string>
#include <vector>
#include "turn.h"

namespace vchess_viewer {

	class Game {
	public:
		Game();
		Game(std::string white, std::string black);
		Game(const std::vector<std::string> &textTurns, std::string white, std::string black);
		~Game();
		
		std::string& white() { return mWhiteName; }
		std::string& black() { return mBlackName; }
		std::string& result() { return mResult; }
		unsigned char positionAt(int i) { return mPosition[i]; }
		bool possibleForFigure(unsigned char figure) { return COLOR(figure) == mCurrentColor; }
		
		
		bool hasNextTurn();
		bool hasPrevTurn();
		Turn nextTurn();
		Turn prevTurn();
		bool addTurn(Turn& turn);
		const std::vector<Turn>& turns() { return mTurns; }
		
		static const int POSITION_SIZE = 16*16;
		
	private:
		std::string mWhiteName;
		std::string mBlackName;
		std::string mResult;
		unsigned char mPosition[POSITION_SIZE];
		int	mTurnIndex;
		std::vector<Turn>	mTurns;
		unsigned char mCurrentColor;
		
		void resetPosition();
		void printPosition();
		int possibleBack(const Turn& turn);
		int possiblePawnBack(const Turn& t);
		bool possiblePawnForward(Turn& t);
		bool possibleKingForward(Turn& t);
		bool possibleForward(Turn& turn);
		int kingPosition(unsigned char color);
		bool doCheck(Turn turn);
		bool isCheck(unsigned char color);
		void correctCheck(std::vector<int> &possible, unsigned char color);
	};
}

#endif
