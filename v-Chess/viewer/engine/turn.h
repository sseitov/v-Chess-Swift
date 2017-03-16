/*
 *  turn.h
 *  vChess
 *
 *  Created by Sergey Seitov on 9/18/10.
 *  Copyright 2010 V-Channel. All rights reserved.
 *
 */
#ifndef __VCHESS_TURN__
#define __VCHESS_TURN__

#include <string>
#include <iostream>

namespace vchess_viewer {

	const unsigned char NotMove			= 0x00;
	const unsigned char Normal			= 0x01;
	const unsigned char Capture			= 0x02;
	const unsigned char FirstPawn		= 0x03;	// первый ход пешкой через клетку
	const unsigned char EnPassant		= 0x04;	// взятие пешкой через битое поле
	const unsigned char QueenCastling	= 0x05;
	const unsigned char KingCastling	= 0x06;
	const unsigned char CHECK			= 0x08;
	const unsigned char CHECKMATE		= 0x10;
	const unsigned char PROMOTE			= 0x20;	// превращение пешки
	
    const unsigned char KING			= 0x01;
    const unsigned char QUEEN			= 0x02;
    const unsigned char ROCK			= 0x03;
    const unsigned char BISHOP			= 0x04;
    const unsigned char KNIGHT			= 0x05;
    const unsigned char PAWN			= 0x06;
    const unsigned char PAWN_ENPASSAT	= 0x08; // пешка прошла через клетку
    const unsigned char MOVED			= 0x10;
    const unsigned char RIGHT			= 0x20;
    const unsigned char CBLACK			= 0x40;
    const unsigned char CWHITE			= 0x80;
    const unsigned char OUT_OF_DESK		= 0xFF;
	
	struct Turn {
		std::string		turnText;	// PGN нотация
		unsigned char	turnType;	// тип хода
		int				fromPos;	// откуда и куда пошла фигура
		int				toPos;
		unsigned char	figure;		// сама фигура
		int				eatPos;		// координата взятой фигуры при взятие пешкой 
									// через битое поле отличается от toPos
		unsigned char	eatFigure;	// взятая фигура
		int				rockFromPos;// откуда и куда пошла ладья при рокировке
		int				rockToPos;
		int				suppX;		// дополнительные поля (горизонталь или вертикаль) в случае неоднозначной позиции
		int				suppY;
		
		Turn();
		Turn(std::string str, bool color);
		
	private:
		friend std::ostream& operator << (std::ostream& out, const Turn& turn);
		friend std::istream& operator >> (std::istream& in, Turn& turn);
		
		int parse(std::string text);
		unsigned char figureType(unsigned char f);
	};

	inline bool IS_ENPASSAT(unsigned char cell) { return ((cell & PAWN_ENPASSAT) != 0); }
	inline unsigned char CLEAR_ENPASSAT(unsigned char cell) { return (cell & 0xf7); }
	inline bool IS_MOVED(unsigned char cell) { return ((cell & MOVED) != 0); }
	inline bool IS_PROMOTE(unsigned char cell) { return ((cell & PROMOTE) != 0); }
	inline unsigned char FIGURE(unsigned char cell) { return (cell & 7); }
	inline unsigned char FIGURE_FLAGS(unsigned char cell) { return (cell & 0xf8); }
	inline unsigned char COLOR(unsigned char cell) { return (cell & (CBLACK | CWHITE)); }
	inline unsigned char OP_COLOR(unsigned char cell) { return ((COLOR(cell) == CWHITE) ? CBLACK : CWHITE); }
	inline unsigned char TURN(unsigned char t) { return (t & 7); }
	inline void POS_FROM_NUM(int num, unsigned char &x, unsigned char &y) { x = (num & 15) - 4; y = (num >> 4) - 4; }
	int NUM_FROM_POS(unsigned char x, unsigned char y);
	std::string FIGURE_TEXT(unsigned char cell);
	std::string COLOR_TEXT(unsigned char cell);
	std::string POSITION_TEXT(int pos);
}

#endif // __VCHESS_TURN__
