Nicholai Venetucci
CS457 Functional Programming
Winter 2020
Course Project my2048

> import Data.List
> import System.Random
> import System.IO

> type Board = [[Int]]

> fresh :: Board
> fresh = [[0,0,0,0]
>         ,[0,0,0,0]
>         ,[0,0,0,0]
>         ,[0,0,0,0]]

mergeTiles is a function that attempts to merge two tiles. If an empty tile (0)
tries to merge into t1, nothing happens. If t2 tries to merge into an empty
tile, it will take the place of the empty tile, and an empty tile will take the
place of where t2 once was. If t2 tries to merge into t1, they will merge by
addition only if they are equal, while an empty tile will take the place of
where t2 once was. If t2 and t1 are not equal, nothing happens.

> mergeTiles :: (Int,Int) -> (Int,Int)
> mergeTiles (t1,0) = (t1,0)
> mergeTiles (0,t2) = (t2,0)
> mergeTiles (t1,t2) = if t1 == t2 then (t1+t2,0) else (t1,t2)

mergeRows is a function that takes in two rows ([Int] -> [Int]) and returns a
list of two rows that represents the result of merging each tile of r2 into each
corresponding tile of r1. This is achieved by zipping together the input rows,
and then mapping mergeTiles onto each tile pair. This result is then unzipped
and converted to a list containing the two merged rows. 

> mergeRows :: [Int] -> [Int] -> [[Int]]
> mergeRows r1 r2 = (\(a,b) -> [a,b]) $ unzip $ map mergeTiles $ zip r1 r2

The functions topTwo, middleTwo, and bottomTwo each take in a Board and return
the resulting Board where the corresponding two rows have been merged together.
This process involves performing mergeRows on the desired two rows, then
appending or prepending the Board back together.

> topTwo :: Board -> Board
> topTwo (x:xs) = mergeRows x (head xs) ++ tail xs

> middleTwo :: Board -> Board
> middleTwo (x:xs) = x : topTwo xs

> bottomTwo :: Board -> Board
> bottomTwo (x:xs) = x : head xs : topTwo (tail xs)

mergeAll is a function that combines the merging of the top two, middle two,
and bottom two rows of a Board. This essentially represents the upward slide of
each tile on the Board by one. The function mergeAllX3 is just performing
mergeAll on a Board three times. This function is needed because for example, if
there was a 2 in the bottom row of an otherwise empty Board, the 2 is expected
to reach the top row of the Board, thus mergeAll will have to occur three times.

> mergeAll :: Board -> Board
> mergeAll = bottomTwo . middleTwo . topTwo

> mergeAllX3 :: Board -> Board
> mergeAllX3 = mergeAll . mergeAll . mergeAll

The functions slideUp, slideDown, slideLeft, and slideRight each perform
mergeAllX3 on a Board in the corresponding direction. Since mergeAllX3 only
represents the upward slide of a Board, depending on the direction, the Board is
transposed and/or reversed accordingly.

> slideUp :: Board -> Board
> slideUp = mergeAllX3

> slideDown :: Board -> Board
> slideDown = reverse . slideUp . reverse

> slideLeft :: Board -> Board
> slideLeft = transpose . slideUp . transpose

> slideRight :: Board -> Board
> slideRight = transpose . reverse . slideUp . reverse . transpose

showTile, showRow, and showBoard are functions that help to achieve the visual
rendering of a Board for output. Specifically, showTile accounts for Int
alignment, showRow adds a separator between tiles, and showBoard adds a divider
between rows.

> showTile :: Int -> String
> showTile t
>   | t >= 1024 = "" ++ show t
>   | t >= 128 = " " ++ show t
>   | t >= 16 = "  " ++ show t
>   | t >= 2 = "   " ++ show t
>   | otherwise = "    "

> showRow :: [Int] -> String
> showRow = concat . (["|"] ++) . (++ ["|"]) . intersperse "|" . map showTile

> showBoard :: Board -> String
> showBoard = unlines . ([divider] ++) . (++ [divider]) . intersperse divider . map showRow
>   where
>     divider = "+----+----+----+----+"

The functions getTile, allIndexes, isZero, and zeroIndexes deal with determining
which (row, col) indexes of a Board contain an empty tile. Knowing the position
of empty tiles comes in handy when needing to populate a Board.

> getTile :: Board -> (Int,Int) -> Int
> getTile b (r,c) = (b !! r) !! c

> allIndexes :: [(Int,Int)]
> allIndexes = [(r,c) | r <- [0..3], c <- [0..3]] 

> isZero :: Board -> (Int,Int) -> Bool
> isZero b i = getTile b i == 0

> zeroIndexes :: Board -> [(Int,Int)]
> zeroIndexes b = filter (isZero b) allIndexes

popTile and PopBoard are functions that accomplish the population of an empty
tile on a Board with the number 2. Essentially, popBoard is supplied the Board
to populate, along with the (row, col) index of an empty tile. This function is
necessary later when needing to randomly populate an empty tile with the number
2.

> popTile :: [Int] -> Int -> [Int]
> popTile r t = take t r ++ [2] ++ drop (t+1) r

> popBoard :: Board -> (Int,Int) -> Board
> popBoard b (r,c) = take r b ++ [popTile (b !! r) c] ++ drop (r+1) b

The readMove function simply returns Just a slide function or Nothing depending
on the String input. The String passed into the function is meant to be the
result of a getLine call. Basically, readMove is intended to examine user input
to determine if whatever they entered results in a function to slide the Board.

> readMove :: String -> Maybe (Board -> Board)
> readMove "up"    = Just slideUp
> readMove "down"  = Just slideDown
> readMove "left"  = Just slideLeft
> readMove "right" = Just slideRight 
> readMove "w"     = Just slideUp
> readMove "s"     = Just slideDown
> readMove "a"     = Just slideLeft
> readMove "d"     = Just slideRight 
> readMove _ = Nothing

playerAct is a function whose purpose is to prompt the user for input, and
eventually return a Board that's been slid in one of four directions. A case
statement is used to analyze the result of readMove on the user's input. If
their input checks out to be Just a slide function, playerAct returns the Board
resulted from the input Board applied to that slide function. If the readMove
returns Nothing, the user is displayed a message saying that their input was
invalid, and the playerAct function will rerun.

> playerAct :: Board -> IO (Board)
> playerAct b = do
>   putStr "Enter move: "
>   hFlush stdout
>   input <- getLine
>   let tryAgain msg = putStrLn msg >> playerAct b
>   case (readMove input) of
>     Just f -> let slide = f in
>       return $ slide b
>     Nothing -> tryAgain "Invalid input\n"

boardFull is a function that returns True or False given a Board as input. If
the Board contains no zeros, the function will return True. In other words, if
every tile on the Board is occupied (not empty), boardFull will return True.
Otherwise, if the Board does contain a zero (an empty tile), the function will
return False.

> boardFull :: Board -> Bool
> boardFull = all (== False) . map (elem 0)

numZeros is a function that returns the number of zeros on a given input Board.
The function getRandTile utilizes numZeros to generate a random number between 0
and the result of numZeros minus 1 (inclusive). The reason for this range is
because the randomly generated number will later be used to access an index from
the list returned by zeroIndexes.

> numZeros :: Board -> Int
> numZeros = sum . map length . map (filter (== 0))

> getRandTile :: Board -> StdGen -> (Int,StdGen)
> getRandTile b gen = randomR (0,(numZeros b)-1) gen :: (Int,StdGen)

boardsEq is a function that checks to see if the two input Boards are equal. If
the boards are equal, boardsEq will return True, False otherwise. The function
cantMove utilizes boardsEq to check whether the input Board can be slid in any
of the four directions. When boardsEq returns True, this means that the Board
has not changed as a result of the slide. Thus, cantMove returns True if all
boardsEq return True. That is, the Board does not change no matter which
direction it slides in (the Board can't move).

> boardsEq :: Board -> Board -> Bool
> boardsEq b1 b2 = (map (getTile b2) allIndexes) == (map (getTile b1) allIndexes)

> cantMove :: Board -> Bool
> cantMove b = boardsEq b (slideRight b)
>   && boardsEq b (slideLeft b)
>   && boardsEq b (slideDown b)
>   && boardsEq b (slideUp b)

play is the function that manages the core game loop. The first thing play
does is check whether the Board is full or not. If the Board is not full, play
will generate a random number used to index a (row, col) position within the
list returned by zeroIndexes. This randomly selected empty position will then
be used to populate the Board with a 2. If the Board is full, no random
generation and population will occur. The play function then checks if the Board
can move (slide). If the Board can't move, it's game over. But if the Board can
move, then playerAct will execute and the resulting Board will be used to call
play again.

> play :: Board -> StdGen -> IO ()
> play b gen = do
>   if not (boardFull b) then do
>     let (randTile, newGen) = getRandTile b gen
>     let b' = popBoard b (zeroIndexes b !! randTile)
>     putStrLn (showBoard b')
>     if cantMove b' then
>       putStrLn "Game over"
>     else do
>       b'' <- playerAct b'
>       play b'' newGen
>   else do
>     putStrLn (showBoard b)
>     if cantMove b then
>       putStrLn "Game over"
>     else do
>       b' <- playerAct b
>       play b' gen

The main function basically starts up the game. A list of acceptable moves is
outputted so the user knows what's considered valid input. A generator is
created with getStdGen to populate a random tile on the fresh Board. The Board
is then passed along to the play function, and the game loop begins.

> main = do
>   putStrLn "\nAccepted moves: \"up\" (or \"w\"), \"left\" (or \"a\"), \"down\" (or \"s\"), \"right\" (or \"d\")"
>   gen <- getStdGen
>   let (randTile, newGen) = getRandTile fresh gen
>   let b = popBoard fresh (zeroIndexes fresh !! randTile)
>   play b newGen
