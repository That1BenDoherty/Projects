#  File:                sumMaze.py
#  Description:         Find path through maze using depth first search
#  Student's Name:      Ben Doherty
#  Student's UT EID:    bjd2332
#  Course Name:         CS 313E 
#  Unique Number:       51826
#
#  Date Created:        4/17/2019
#  Date Last Modified:  4/17/2019

##############################################################################
import copy
import os

# Class that holds all the information
# Has the current grid with our path, current position, and sum
# When created will add our current position to the path and sum, then mark
#  our position with an X on the grid
class State:
    def __init__(self,grid,path,row,col):
        self.grid = grid        # 2d list of the maze, with our path marked
        self.path = path        # List of where we've been
        self.row = row          # Our position
        self.col = col          
        self.curSum = 0         # Sum of our path

        path.append(grid[row][col])         # adding position to path
        self.curSum = sum(self.path)        # calculating sum from path
        grid[row][col] = "X"                # replaceing position on grid with a "X"

    # Str prints out our formated gird, then shows our current path, position, and sum.
    # - From the grid it takes each row and formats the values to be 5 char long.
    #       It can then join them into a string and print the row
    # - For the path, position and sum it just takes their values from _init_

    def __str__(self):
        
        print("   Grid:")
        for row in range(len(self.grid)):   # Printing grid
            formatedList = [format(str(value),"5s") for value in self.grid[row]]
            print(" "*5,"".join(formatedList))

        print("   history:", self.path)
        print("   start point: ("+str(self.row)+","+str(self.col)+")")
        print("   sum so far:",self.curSum)
        return ""
    
    # isValid determines if our next move is valid.
    # Tests if we're trying to move off the edge of the grid or moving somewhere we've
    #   already been
    # If we're moving off the edge then we'll get an error when we go past the index.
    #   We can except this error and send that it's not a valid move
    # If we're moving somewhere we've already been the we'll be running into an "X".
    #   We can determine this by testing if the value is an integer.
    # Will return False if it's not a valid move or True if it is.
    def isValid(self,target,goalRow,goalCol):
        try:
            self.grid[goalRow][goalCol]     # If we're moving off edge
        except IndexError:                  
            return False
    
        if type(self.grid[goalRow][goalCol]) is not int:  # If moving into an "X"
            return False

        return True     # If it's a valid move
        

# This function is used to solve the maze. Will test if we've reached the
#   finish, otherwise will try moving in a direction.
# We can move by creating a new state one value away. If we can't move anywhere
#   then we backtrack to the last state and keep going. This is done by returning
#   None, which will bring us back to the middle of the last state we were in.
def solve(state,target):

    print("Is this a goal state?")
    
    if state.curSum == target:
        print("Solution found!")
        return state.path # If we've found the end, return our path

    if state.curSum > target:   # If we run into a wall then back up
        print("No. Target exceeded:  abandoning path")
        return None

# Here we start trying to move in a direction

    print("No.  Can I move right?") # Test if we can move using isValid
    if state.isValid(target,state.row, state.col+1):
        print("Yes!\n\nProblem is now:")
        
    # Creating new state, need deepcopy so that we have unique states, otherwise
    #   our past state would change to match our new state.
        newState = State(copy.deepcopy(state.grid),copy.deepcopy(state.path),\
                         state.row, state.col+1)
        print(newState)

        result = solve(newState,target)     # Keep going into maze
        if result != None:          # If we solved the maze pass back the solution
            return result
        
# If that direction didn't work, keep trying with other directions
    print("No.  Can I move up?")
    if state.isValid(target,state.row-1,state.col):
        print("Yes!\n\nProblem is now:")
        
        newState = State(copy.deepcopy(state.grid),copy.deepcopy(state.path),\
                         state.row-1,state.col)
        print(newState)

        result = solve(newState,target)
        if result != None:
            return result

    print("No.  Can I move down?")
    if state.isValid(target,state.row+1, state.col):
        print("Yes!\n\nProblem is now:")
        
        newState = State(copy.deepcopy(state.grid),copy.deepcopy(state.path),\
                         state.row+1,state.col)
        print(newState)

        result = solve(newState,target)
        if result != None:
            return result

    print("No.  Can I move left?")
    if state.isValid(target,state.row,state.col-1):
        print("Yes!\n\nProblem is now:")
        
        newState = State(copy.deepcopy(state.grid),copy.deepcopy(state.path),\
                         state.row,state.col-1)
        print(newState)

        result = solve(newState,target)
        if result != None:
            return result

    #If we're at a square and can't move in any direction we go back and look
    #  for the next valid path
    print("Couldn't move in any direction.  Backtracking.")
    return None
        

# Here is where we set up the maze to solve it
# First we open our data and grab all the variables from the frist line.
#   We do this by converting it to a list of integers, then set our variables
#   equal to it's entries
# Next we make our grid
#   For this we read each row, making it a list of integers and adding it to the grid
# We then create our starting state from the grid and starting positions
# Finally we push our starting state to our solve function. We take the solution and
#   print it (if there is one, otherwise print that there isn't)
def main():
    path = str(os.path.abspath(__file__))[:-10]
    rawData = open(path+"mazedata.txt","r") #opeing our data

    var = list(map(int, rawData.readline().split()))    # Makes line a list of ints
    target,grid_rows,grid_cols,start_row,start_col,end_row,end_col = var

    grid = []
    for row in range(grid_rows):
        grid.append(list(map(int, rawData.readline().split()))) # add int list to grid

    start = State(grid, [], start_row, start_col) # Create starting state
    print(start)

    solution = solve(start,target)  # Solving the maze
    if solution == None:
        print("\nNo solution exists")
    else:
        print(solution)
    

main()
