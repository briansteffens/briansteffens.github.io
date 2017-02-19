module Main where

import System.Exit

factorial :: Int -> Int
factorial n = product [1..n]

main :: IO ()
main = do
    exitWith $ ExitFailure $ factorial 5
