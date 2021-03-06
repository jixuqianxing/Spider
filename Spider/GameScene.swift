//
//  GameScene.swift
//  Spider
//
//  Created by Matthew Olson on 1/5/16.
//  Copyright (c) 2016 Molson. All rights reserved.
//

import SpriteKit
import Foundation
import GameplayKit

class GameScene: SKScene {
    var cardValue: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    var cardSuit: [String] = ["Spades","Spades", "Spades", "Spades","Spades","Spades", "Spades", "Spades"]
    var fieldCards:[[Card]] = [[Card]]()
    var deck:[Card] = [Card]()
    var decksComplete: Int = 0
    var moves:[Move] = [Move]()
    var redoMoves:[Move] = [Move]()
    var cardsLeft:SKLabelNode = SKLabelNode(fontNamed:"Helvetica-Bold")
    var height:CGFloat = 0
    var width:CGFloat = 0
    var cannotSelectKings:[Card] = [Card]()
    
    // TODO LONG TERM: add animation
    // http://www.raywenderlich.com/76718/card-game-mechanics-sprite-kit-swift
    // http://www.gamefromscratch.com/page/SpriteKit-game-development-with-Swift-tutorial-series.aspx
    
    override func didMoveToView(view: SKView) {
        
        height = self.frame.size.height
        width = self.frame.size.width
        
        let background = SKSpriteNode(imageNamed: "FeltBackground")
        background.position = CGPoint(x:0,y:0)
        background.anchorPoint = CGPoint(x:0.0,y:0.0)
        background.size = view.bounds.size
        background.zPosition = 0
        self.addChild(background)
        
        let dealCard = DealCard.init(scene: self)
        dealCard.zPosition = 1
        self.addChild(dealCard)
        
        cardsLeft.text = "5"
        cardsLeft.zPosition = 1
        cardsLeft.fontSize = 15
        cardsLeft.position = CGPoint(x:width*13/14-75, y:30)
        self.addChild(cardsLeft)

        for mySuit in cardSuit {
            for myValue in cardValue {
                let myImageName = String(format: "Cards/%@%d.png",mySuit,myValue)
                let newCard = Card(scene:self, imageName: myImageName, suit: mySuit, value: myValue)
                deck.append(newCard)
            }
        }
        deck = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(deck) as! [Card]

        for i in 0...53 {
            let x = i%10
            let y = i/10
            let card = deck.removeFirst()
            if i < 44 {
                card.texture = SKTexture(imageNamed: "CardBack")
                card.isFlipped = true
            }
            card.zPosition = CGFloat(y+1)
            if i<10 {
                fieldCards.append([card])
            } else {
                fieldCards[x].append(card)
            }
            card.position = CGPointMake(width/10*CGFloat(x)+width/20,height-width/15-CGFloat(25*y))
            self.addChild(card)
        }
    }
    
    func numDecks(num: Int) {
        if (num == 1) {
            cardSuit = ["Spades","Spades", "Spades", "Spades","Spades","Spades", "Spades", "Spades"]
        } else if (num == 2) {
            cardSuit = ["Spades","Spades", "Hearts", "Hearts","Spades","Spades", "Hearts", "Hearts"]
        } else if (num == 4) {
            cardSuit = ["Spades","Clubs", "Hearts", "Diamonds","Spades","Clubs", "Hearts", "Diamonds"]
        }
    }
    
    func undoPressed() {
        if moves.count > 0 {
            while moves.last?.moveType == "King" {
                moves.last!.undoKing()
                redoMoves.append(moves.removeLast())
            }
            if moves.last?.moveType == "Shift" {
                moves.last!.undoShift()
            } else if moves.last?.moveType == "Deal" {
                moves.last!.undoDeal()
            }
            redoMoves.append(moves.removeLast())
        }
    }
    
    func redoPressed() {
        if redoMoves.count > 0 {
            if redoMoves.last?.moveType == "Shift" {
                redoMoves.last!.redoShift()
            } else if redoMoves.last?.moveType == "Deal" {
                redoMoves.last!.redoDeal()
            }
            moves.append(redoMoves.removeLast())
        }
        if redoMoves.count > 0 {
            while redoMoves.last?.moveType == "King"{
                redoMoves.last!.redoKing()
                moves.append(redoMoves.removeLast())
            }
        }
    }
}
