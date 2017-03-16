/*
 *  turn.cpp
 *  vChess
 *
 *  Created by Sergey Seitov on 9/18/10.
 *  Copyright 2010 V-Channel. All rights reserved.
 *
 */

#include "turn.h"
#include <vector>
#include <stdexcept>
#include <iostream>
#include <sstream>

static int vSplit(const std::string &s, char delim, std::vector<std::string> &elems)
{
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
        elems.push_back(item);
    }
    return (int)elems.size();
}

namespace vchess_viewer {
		
	int hlat16[8][8] = {
		{68, 69, 70, 71, 72, 73, 74, 75},
		{84, 85, 86, 87, 88, 89, 90, 91},
		{100, 101, 102, 103, 104, 105, 106, 107},
		{116, 117, 118, 119, 120, 121, 122, 123},
		{132, 133, 134, 135, 136, 137, 138, 139},
		{148, 149, 150, 151, 152, 153, 154, 155},
		{164, 165, 166, 167, 168, 169, 170, 171},
		{180, 181, 182, 183, 184, 185, 186, 187}
	};
	
	int NUM_FROM_POS(unsigned char x, unsigned char y) {
		if (x < 8 && y < 8) {
			return hlat16[y][x];
		} else {
			return -1;
		}
	}
	
	std::string FIGURE_TEXT(unsigned char cell) {
		switch (FIGURE(cell)) {
			case KING:		return "K";
			case QUEEN:		return "Q";
			case ROCK:		return "R";
			case BISHOP:	return "B";
			case KNIGHT:	return "N";
			case PAWN:		return "";
			default:
				throw std::logic_error("Error figure type");
				break;
		}
	}
	
	std::string COLOR_TEXT(unsigned char cell) {
		switch (COLOR(cell)) {
			case CBLACK:	return "COLOR_BLACK";
			case CWHITE:	return "COLOR_WHITE";
			default:		return "COLOR_UNKNOWN";
		}
	}
	
	std::string POSITION_TEXT(int pos) {
		std::string text;
		unsigned char x,y;
		POS_FROM_NUM(pos, x, y);
		text.append(1, 'a' + x);
		text.append(1, '1' + y);
		return text;
	}
	
	std::ostream& operator << (std::ostream& out, const Turn& t) {
		out << t.turnText 
			<< t.turnType 
			<< t.fromPos 
			<< t.toPos 
			<< t.figure 
			<< t.eatPos 
			<< t.eatFigure 
			<< t.rockFromPos 
			<< t.rockToPos 
			<< t.suppX
			<< t.suppY;
		return out;
	}
	
	std::istream& operator >> (std::istream& in, Turn& t) {
		in >> t.turnText 
		   >> t.turnType
		   >> t.fromPos 
		   >> t.toPos 
		   >> t.figure 
		   >> t.eatPos 
		   >> t.eatFigure 
		   >> t.rockFromPos 
		   >> t.rockToPos 
		   >> t.suppX
		   >> t.suppY;
		return in;
	}
	
	Turn::Turn() : turnType(NotMove), fromPos(-1), toPos(-1), figure(0), eatPos(-1), eatFigure(0), rockFromPos(-1), rockToPos(-1), suppX(-1), suppY(-1) 
	{
	}

	Turn::Turn(std::string str, bool color) : turnText(str), turnType(NotMove), fromPos(-1), toPos(-1), eatPos(-1), eatFigure(0), rockFromPos(-1), rockToPos(-1), suppX(-1), suppY(-1) 
	{
		figure = (color) ? CWHITE : CBLACK;
		
		int end = (int)str.length() - 1;
		if (str[end] == '+') {
			turnType |= CHECK;
			str.erase(end);
		} else  if (str[end] == '#') {
			turnType |= CHECKMATE;
			str.erase(end);
		}
		if (str == "O-O") {
			turnType |= KingCastling;
			figure |= KING;
			fromPos = (color) ? NUM_FROM_POS(4, 0) : NUM_FROM_POS(4, 7);
			toPos = (color) ? NUM_FROM_POS(6, 0) : NUM_FROM_POS(6, 7);
			rockFromPos = (color) ? NUM_FROM_POS(7, 0) : NUM_FROM_POS(7, 7);
			rockToPos = (color) ? NUM_FROM_POS(5, 0) : NUM_FROM_POS(5, 7);
		} else if (str == "O-O-O") {
			turnType |= QueenCastling;
			figure |= KING;
			fromPos = (color) ? NUM_FROM_POS(4, 0) : NUM_FROM_POS(4, 7);
			toPos = (color) ? NUM_FROM_POS(2, 0) : NUM_FROM_POS(2, 7);
			rockFromPos = (color) ? NUM_FROM_POS(0, 0) : NUM_FROM_POS(0, 7);
			rockToPos = (color) ? NUM_FROM_POS(3, 0) : NUM_FROM_POS(3, 7);
		} else if (str.find('=') != std::string::npos) {
			turnType |= PROMOTE;
			std::vector<std::string> promote;
			vSplit(str, '=', promote);
			if (promote.size() != 2 || promote[0].length() < 2 || promote[1].length() < 1) {
				throw std::logic_error("Error parse " + turnText);
			}
			parse(promote[0]);
			figure |= figureType(promote[1][0]);
		} else {
			int index = parse(str);
			if (index >= 0) {
				figure |= figureType(str[index]);
			} else {
				figure |= PAWN;
			}
		}
	}
	
	int Turn::parse(std::string text) {
		int index = (int)text.length() - 1;
		if (index < 1) {
			throw std::logic_error("Error parse " + turnText);
		}
		int y = text[index] - '1';
		index--;
		int x = text[index] - 'a';
		index--;
		toPos = NUM_FROM_POS(x, y);
		if (index >= 0 && text[index] == 'x') {
			turnType |= Capture;
			index--;
		} else {
			turnType |= Normal;
		}
		if (index >= 0) {
			if (text[index] >= 'a' && text[index] <= 'h') {
				suppX = text[index] - 'a';
				index--;
			} else if (text[index] >= '1' && text[index] <= '8') {
				suppY = text[index] - '1';
				index--;
			}
		}
		return index;
	}
	
	unsigned char Turn::figureType(unsigned char f) {
		switch (f) {
			case 'B':
				return BISHOP;
			case 'N':
				return KNIGHT;
			case 'Q':
				return QUEEN;
			case 'R':
				return ROCK;
			case 'K':
				return KING;
			default:
				break;
		}
		throw std::logic_error("Eror parse " + turnText);
	}
	
}
