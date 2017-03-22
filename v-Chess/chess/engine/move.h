//
//  move.h
//  Pocket Chess
//
//  Created by Sergey Seitov on 04.08.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#ifndef __Pocket_Chess__move__
#define __Pocket_Chess__move__

#include "position.h"
#include <string>

namespace vchess {
	
	enum MoveType {
		NotMove,
		Normal,
		Capture,
		EnPassant,			// взятие пешкой через битое поле
		QueenCastling,		// рокировки
		KingCastling
	};
	
	struct Move {
		Figure figure;
		Position from;
		Position to;
		MoveType moveType;
		bool promote;				// превращение пешки
		bool firstMove;				// первый ход
		unsigned char captureFigure;
		Position capturePosition;
		
		Move()
			: moveType(NotMove), promote(false), firstMove(false), captureFigure(0)
		{}
		Move(const Move& other)
			: figure(other.figure), from(other.from), to(other.to), moveType(other.moveType), promote(other.promote), firstMove(other.firstMove),
			captureFigure(other.captureFigure), capturePosition(other.capturePosition)
		{}
		Move(Figure _figure, Position _from, Position _to, MoveType _moveType)
			: figure(_figure), from(_from), to(_to), moveType(_moveType), promote(false), firstMove(false), captureFigure(0)
		{}
		
        Move(const std::string& description)
            : moveType(NotMove), promote(false), firstMove(false), captureFigure(0)
        {
            char f = description[0];
            switch (f) {
                case 'K':
                    figure = KING;
                case 'Q':
                    figure = QUEEN;
                case 'R':
                    figure = ROOK;
                case 'B':
                    figure = BISHOP;
                case 'N':
                    figure = KNIGHT;
                default:
                    figure = PAWN;
            }
            from = Position(description.substr(1,2));
            to = Position(description.substr(3,2));
            std::string t = description.substr(5,3);
            if (t == "NOR")
                moveType = Normal;
            else if (t == "CAP")
                moveType = Capture;
            else if (t == "ENP")
                moveType = EnPassant;
            else if (t == "QUE")
                moveType = QueenCastling;
            else if (t == "KIN")
                moveType = KingCastling;
            else
                moveType = NotMove;
            promote = description[8] == 'Y';
            firstMove = description[9] == 'Y';
            captureFigure = description[10];
            if (captureFigure > 0) {
                capturePosition = Position(description.substr(11,2));
            }
        }
        
        std::string textDesctiption() const {
            std::string text;
            switch (FIGURE(figure)) {
                case KING:
                    text = "K";
                    break;
                case QUEEN:
                    text = "Q";
                    break;
                case ROOK:
                    text = "R";
                    break;
                case BISHOP:
                    text = "B";
                    break;
                case KNIGHT:
                    text = "N";
                    break;
                default:
                    text = "p";
                    break;
            }
            text += from.notation();
            text += to.notation();
            switch (moveType) {
                case Normal:
                    text += "NOR";
                    break;
                case Capture:
                    text += "CAP";
                    break;
                case EnPassant:			// взятие пешкой через битое поле
                    text += "ENP";
                    break;
                case QueenCastling:		// рокировки
                    text += "QUE";
                    break;
                case KingCastling:
                    text += "KIN";
                    break;
                default:                // NotMove,
                    text += "NOT";
                    break;
            }
            if (promote)
                text += "Y";
            else
                text += "N";
            if (firstMove)
                text += "Y";
            else
                text += "N";
            text += captureFigure;
            if (captureFigure > 0) {
                text += capturePosition.notation();
            }
            return text;
        }
        
		std::string notation() const
		{
			if (moveType != NotMove) {
				if (moveType == QueenCastling) {
					return "O-O-O";
				} else if (moveType == KingCastling) {
					return "O-O";
				} else {
					std::string text;
					switch (FIGURE(figure)) {
						case KING:
							text = "K";
							break;
						case QUEEN:
							text = "Q";
							break;
						case ROOK:
							text = "R";
							break;
						case BISHOP:
							text = "B";
							break;
						case KNIGHT:
							text = "N";
							break;
						default:
							break;
					}
					
					text += (from.notation() + to.notation());
					if (moveType == Capture || moveType == EnPassant || !capturePosition.isNull())
						text += "x";
					return text;
				}
			} else {
				return "";
			}
		}
		
		std::string shortNotation() const
		{
			if (moveType == NotMove) {
				return "";
			} else {
				return (from.notation() + to.notation());
			}
		}

		bool operator==(const Move& move)
		{
			return (from == move.from && to == move.to && moveType == move.moveType);
		}
	};
	
	typedef std::vector<Move> Moves;
}

#endif /* defined(__Pocket_Chess__move__) */
