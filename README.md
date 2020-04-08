# my2048-haskell

### Build and Run
I built using:
```
ghc --make my2048
```
then ran with:
```
./my2048
```

### Background Info
The game *2048* is a sliding tile puzzle game. The main objective is to combine  
alike numeric tiles with one another to create a large numbered (2048) tile.  
This is done by repeatedly sliding all the tiles on the board (4x4) in a  
direction (up, down, left, or right) of your choice. During this sliding  
process, if two matching tiles merge into each other, they will combine into  
one tile equaling the sum of the two tiles. For instance:
```
+----+----+----+----+                +----+----+----+----+
|   2|    |    |    |                |   4|  16|    |   4|
+----+----+----+----+                +----+----+----+----+
|   2|   8|    |   4|  after an      |    |    |    |   2|
+----+----+----+----+  upward slide  +----+----+----+----+
|    |    |    |    |  becomes -->   |    |    |    |    |
+----+----+----+----+                +----+----+----+----+
|    |   8|    |   2|                |    |    |    |    |
+----+----+----+----+                +----+----+----+----+
```

### My Approach
The first thing I did was define the `type Board = [[Int]]`. This proved to be  
pretty convenient, as many functions ended up taking `Board` as an input  
argument and/or return type. I initially thought about making a  
`type Row = [Int]` and `type Tile = Int`, but later decided that this might  
make things too complicated to read.

The first function that I attempted to write was `mergeRows`. This function  
takes in two "rows" (`[Int] -> [Int]`) and returns a list containing two rows  
(`[[Int]]`). It's kinda hard to explain why it would return this type, but  
hopefully the following helps:
```
mergeRows [2,2,2,2] [2,4,4,2]

[[4,2,2,4],[0,4,4,0]]
```
Essentially, the second input row attempts to merge into the first. We see that  
the outer 2's merge together resulting in outer 4's in the first return row.  
However, the inner 4's of the second input row cannot merge into the inner 2's  
of the first. Therefore, the inner values of both rows remain unchanged in the  
return rows.

In order to appropriately merge the "tiles" of the two rows, I had to make the  
function `mergeTiles`. This function takes in an `(Int,Int)` and returns an  
`(Int,Int)`. The reason for these tuples is because `mergeRows` zips the two  
input rows together. Using the last example, it would look like this:
```
zip [2,2,2,2] [2,4,4,2]

[(2,2),(2,4),(2,4),(2,2)]
```
Thus, `mergeTiles` is mapped over each tuple of this return list. `mergeTiles`  
will check to see whether the second value of each tuple can merge into the  
first value. Whether the merge is possible or not, `mergeTiles` will return the  
the proper resulting tuple. This looks like the following:
```
map mergeTiles [(2,2),(2,4),(2,4),(2,2)]

[(4,0),(2,4),(2,4),(4,0)]
```
After this is done, this list of tuples is unzipped to a `([Int],[Int])`, then  
converted to a `[[Int]]` containing our two "merged" rows. This concludes the  
`mergeRows` function, but this still only merges two rows. We need to merge  
together each row of our 4x4 `Board`. This is where the functions `topTwo`,  
`middleTwo`, and `bottomTwo` come in. These functions take in a `Board`,  
perform `mergeRows` on the corresponding two rows, then appends/prepends the  
`Board` back together for a result.

The function `mergeAll` combines the merging of all the rows into one function.  
Here's what `mergeAll` looks like in action:
```
mergeAll [[2,0,0,0]
         ,[2,0,0,0]
         ,[2,0,0,0]
         ,[2,0,0,2]]

[[4,0,0,0]
,[2,0,0,0]
,[2,0,0,2]
,[0,0,0,0]
```
But this isn't exacty the desired output we'd expect from sliding the `Board`  
up. At the very least, the 2 in the bottom right should be making its way up to  
the top right. This dilemma is fixed with the `mergeAllX3` function, which just  
calls `mergeAll` three times. Since this is basically the desired result  
we're looking for in an upward slide, the `slideUp` function is just made equal  
to `mergeAllX3`. This is what `slideUp` looks like:
```
slideUp [[2,0,0,0]
        ,[2,0,0,0]
        ,[2,0,0,0]
        ,[2,0,0,2]]

[[8,0,0,2]
,[0,0,0,0]
,[0,0,0,0]
,[0,0,0,0]
```
This works good enough for our purposes, but the other slide directions need to  
be accounted for as well. The functions `slideDown`, `slideLeft`, and  
`slideRight` all call `slideUp` within them. By utilizing the `reverse` and/or  
`transpose` functions, we can manipulate the `Board` to slide in the direction  
we desire, all while only needing to use `slideUp`.

The next functions I wrote were `showTile`, `showRow`, and `showBoard`. All  
together these functions help to create the visual representation of a `Board`  
that can be displayed for output. This visual representation is actually the  
exact same style of what I showed in the Background Info section of this  
writeup. The `putStrLn` of a `String` resulting from `showBoard` would look  
something like this:
```
putStrLn $ showBoard [[2,0,0,0],[0,16,0,0,],[0,0,128,0],[0,0,0,1024]]

+----+----+----+----+
|   2|    |    |    |
+----+----+----+----+
|    |  16|    |    |
+----+----+----+----+
|    |    | 128|    |
+----+----+----+----+
|    |    |    |1024|
+----+----+----+----+
```
If the length of the tile number was greater than 4 digits, it would actually  
break this output a bit. Side note: if I recall correctly, the `intersperse`  
function I used for `showRow` and `showBoard` required me to  
`import Data.List`.

I then wrote the four functions: `getTile`, `allIndexes`, `isZero`, and  
`zeroIndexes`. The first three are basically to help accomplish `zeroIndexes`.  
The `getTile` function returns the numeric value at a tile given a `Board`  
and an `(Int,Int)` tuple that represents a (row,col) index. Consider the  
following:
```
getTile [[0,0,0,0],[0,0,4,0],[0,0,0,0],[0,0,0,0]] (1,2)

4
```
The `allIndexes` function uses a list comprehension to return a list of all 16  
(row,col) indexes of the 4x4 board. Given a `Board` and a (row,col) index,  
`isZero` checks whether the tile at the supplied index has the value 0. These  
functions help to create `zeroIndexes`, which when supplied a `Board`, returns  
a list of all the (row,col) indexes that contain a 0 tile. Here's an example:
```
zeroIndexes [[0,2,2,2],[2,0,2,2],[2,2,0,2],[2,2,2,0]]

[(0,0),(1,1),(2,2),(3,3)]
```
The next two functions I created were `popTile` and `popBoard`. Together these  
functions achieve populating a `Board` with a tile of the value 2. I forgot to  
mention in Background Info, but after each slide the player makes, a random  
empty tile is populated with the number 2. Since we only need to populate one  
new tile at a time, given a (row,col) position `popBoard` simply returns a new  
`Board` where the tile at this position has been changed from 0 to 2. For  
instance:
```
popBoard [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]] (3,1)

[[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,2,0,0]]
```
The implementation of `popTile` and `popBoard` basically involve the tedious  
replacement and reconstruction (appending/prepending) of a row and board. When  
I created these functions, it took a bit of thinking. Walking through them with  
pen and paper definitely helped me in getting them right.

Going down the list, `readMove` is the next function. It's a very simple  
pattern matching function that matches a `String` to `Just` a slide function or  
`Nothing`. I needed to create `readMove` to be used in the following  
`playerAct` function. When `playerAct` is executed, the user is prompted for  
`input`. The `input` is passed into `readMove` and the result is evaluated  
using a case statement. In the case of `Just` a slide function, `playerAct`  
will return the `Board` resulting from this slide function. In the case of  
`readMove` returning `Nothing`, an error message will be displayed and  
`playerAct` will run again. Side note: `hFlush stdout` flushes the buffer,  
which I needed to do because I wanted to get user input on the same line using  
`putStr` instead of `putStrLn`. This flushing method required me to  
`import System.IO`.

Next we have `BoardFull`, which is a function that simply checks if the `Board`  
contains any 0's. If the `Board` contains no 0's, this means there are no empty  
tiles (each tile is occupied) and the `Board` is considered "full". `boardFull`  
will return `True` if the `Board` contains no 0's, `False` otherwise.

The function `numZeros` returns the number of 0's on a given `Board`. This is  
useful for the implementaton of our `getRandTile` function. `getRandTile`  
essentially generates a random number between 0 and `numZeros` minus 1  
(inclusive) for a given `Board`. This random number will then be used to index  
the list of tuples created by `zeroIndexes`, effectively getting a random  
(row,col) position of an empty tile. Although this process happens later in the  
`play` function.

`boardsEq` is a function that takes in 2 `Boards` and checks whether they are  
equal. The function `cantMove` utilizes `boardsEq` to check whether the given  
`Board` is able to slide in any direction. It does this by calling `boardsEq`  
on each `Board` resulting from every slide function, comparing them against  
the original `Board`. If all `boardsEq` return `True`, then `cantMove` will  
return `True` as well, meaning the tiles on the given `Board` are unable to  
move (merge) in any direction. Here's an example:
```
cantMove [[16,32,64,128],[8,16,32,64],[4,8,16,32],[2,4,8,16]]

         ( +----+----+----+----+
           |  16|  32|  64| 128|
           +----+----+----+----+
           |   8|  16|  32|  64|
           +----+----+----+----+
           |   4|   8|  16|  32|
           +----+----+----+----+
           |   2|   4|   8|  16|
           +----+----+----+----+ )

True
```
The next function we have is `play`, which pretty much handles our core game  
state. The first thing `play` does is check whether the `Board` is full or not.  
If the `Board` is not full, `play` will generate a random number in order to  
populate a random empty tile with the number 2. If the `Board` is full, no  
random generation or population will occur. The `play` function then proceeds  
to check whether the `Board` can move. If the `Board` can't move, it's game  
over. However, if the `Board` is able to slide in a direction, then `playerAct`  
will prompt the user for a direction. The `Board` returned from `playerAct` is  
then supplied to `play` and the process repeats itself.

The last function `main` basically just sets up our game. It first displays a  
`String` to the user describing accepted input. A generator is then created for  
our random number generation. The `Board` is randomly populated with a number 2  
tile, and passed along to `play`. `play` will go ahead and populate the `Board`  
at another randomly selected position. Now, when the user is prompted for input  
for the first time, the `Board` will already contain two randomly placed 2's.  
The game is then ready to play.
