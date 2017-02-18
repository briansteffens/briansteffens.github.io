module Main where

import System.Exit

factorial :: Int -> Int
factorial 0 = 1
factorial n = n * factorial (n - 1)

main :: IO ()
main = do
    exitWith $ ExitFailure $ factorial 5
