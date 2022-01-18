#  File:                War.py
#  Description:         War card game
#  Student's Name:      Ben Doherty
#  Student's UT EID:    bjd2332
#  Course Name:         CS 313E 
#  Unique Number:       51826
#
#  Date Created:        2/19/2019
#  Date Last Modified:  2/27/2019

##################################################################
import random

# Creates card class, has a suit and rank and will display them when called
class Card:
    
    def __init__(self,suit,rank):
        self.suit = suit
        self.rank = rank

    def __str__(self):
        return self.rank+self.suit
    
    
class Deck:

    # Initiating a deck creates all 52 cards, 2 to Ace with all 4 suits
    def __init__(self):
        self.cardList = []
        for suit in ["C","D","H","S"]:
            for rank in ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]:
                self.cardList.append(Card(suit,rank))

    # Shuffling the deck using the import random from ealier
    def shuffle(self):
        random.shuffle(self.cardList)

    # Deal cards by poping them off the deck and putting in players hand
    def dealOne(self,player):
        player.hand.append(self.cardList.pop(0))

    # When called on the deck shows all cards in 4 rows of 13 elements    
    def __str__(self):
        for x in range(0,52):
            if x%13 == 0 and x != 0:
                print()
            print("%4s" %(self.cardList[x]), end = "")
        return "\n"


class Player:

    # Players have a hand that hold cards
    def __init__(self):
        self.hand = []

    # When called on they show their cards in a similar manner as the deck,
    #  in rows with 13 elements, but with a variable length
    def __str__(self):
        length = len(self.hand)
        for x in range(length):
            if x%13 == 0 and x != 0:
                print()
            print("%4s" %(self.hand[x]), end = "")
        return ""


def round(r,p1,p2):
    # Each round the players take the top card, put it on the table, and
    #  compare them. We do this by poping the card out of the hand and putting
    #  it on our table list
    # We then compare the cards by indexing them with our rank list. The higher
    #  the index the higher the rank. If one card is higher then it wins, else
    #  we start a war
    # Once someone wins they take all the cards by having the table extended to
    #  the end of their hand

    rank = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]
    table1 = []
    table2 = []
    
    print("\nROUND "+str(r)+":")
    print("Player 1 plays: %3s" %(p1.hand[0]))
    print("Player 2 plays: %3s" %(p2.hand[0]))
    print()

    # Loop continues untill someone has won the war
    while True:
        table1.append(p1.hand.pop(0)) # Placing cards on table
        table2.append(p2.hand.pop(0))

        if rank.index(table1[-1].rank) > rank.index(table2[-1].rank):
            print("Player 1 wins round "+str(r)+": %3s > %3s" \
                  %(table1[-1],table2[-1]))
            p1.hand.extend(table1) # Putting cards in winner's hand
            p1.hand.extend(table2)
            break
        elif rank.index(table1[-1].rank) < rank.index(table2[-1].rank):
            print("Player 2 wins round "+str(r)+": %3s > %3s" \
                  %(table2[-1],table1[-1]))
            p2.hand.extend(table1)
            p2.hand.extend(table2)
            break
        # When a war stars we place all face down cards on table and start the
        #  loop over to continue.
        else:
            print("War starts: %3s = %3s" %(table1[-1],table2[-1]))
            for x in range(3):
                print("Player 1 puts %3s face down" %(p1.hand[0]))
                table1.append(p1.hand.pop(0))
                print("Player 2 puts %3s face down" %(p2.hand[0]))
                table2.append(p2.hand.pop(0))
            print("Player 1 puts %3s face up" %(p1.hand[0]))
            print("Player 2 puts %3s face up" %(p2.hand[0]))            
                
        print()

def playGame(p1,p2):
    # Game starts by seeing players inital hands and entering the loop to start
    #  the first round.
    # We try to play each round, making a exception for index errors since
    #  this happens when a player has run out of cards mid way through. In this
    #  case we stop playing and break out of our loop
    # At the end of each round we show each players hands, and if one of them
    #  is empty then the game is over. We also incriment the round
    
    print("\n")
    print("Initial hands:")
    print("Player 1:")
    print(p1)
    print("\n\nPlayer 2:")
    print(p2)
    print("\n")
    
    playing  = True
    roundNum = 1

    while playing:

        # Checking for no cards mid war
        try:
            round(roundNum,p1,p2)
        except IndexError:
            if len(p1.hand) == 0:
                print("Player 1 ran out of cards")
            else:
                print("Player 2 ran out of cards")
            playing = False
            break

        print("\nPlayer 1 now has",len(p1.hand), "card(s) in hand:")
        print(p1)
        print("Player 2 now has",len(p2.hand), "card(s) in hand:")
        print(p2)
        print()

        # Checking for empty hand
        if (len(p1.hand) == 0) or (len(p2.hand) == 0):
            playing = False

        roundNum += 1        

# Only difference to main program is instead of using method to check if a
#  players hand is empty I just check the size of their hand
# Also I skipped a \n or two to match up with the output
def main():

    cardDeck = Deck()               # creates a deck of 52 cards
    print("Initial deck:")
    print(cardDeck)                 # print the deck so we can see it
    
    random.seed(15)             
    cardDeck.shuffle()              # shuffles the deck
    print("Shuffled deck:")
    print(cardDeck)                 # show's the deck is shuffled
                                    
    player1 = Player()              # create a player
    player2 = Player()              # create another player

    for i in range(26):             # deal 26 cards to each player, one at 
       cardDeck.dealOne(player1)    #   a time, alternating between players
       cardDeck.dealOne(player2)
    
    playGame(player1,player2)

    if len(player1.hand) == 0:
        print("\nGame over.  Player 2 wins!")
    else:
        print("\nGame over.  Player 1 wins!")

    print ("\n\nFinal hands:")    
    print ("Player 1:")
    print (player1)                 
    print ("\nPlayer 2:")
    print (player2)

main()

    
















