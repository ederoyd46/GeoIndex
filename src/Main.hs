{-# LANGUAGE OverloadedStrings #-}

import Text.CSV(parseCSVFromFile, Field, CSV)
import Data.List(map)
import Control.Monad(mapM_)
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Header (uFromString)
import Text.ProtocolBuffers.WireMessage (messageGet, messagePut)
import qualified Data.ByteString.Lazy as ByteString (readFile, writeFile, length, appendFile)
--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Maybe(isJust, fromJust)
import Data.Int

main :: IO ()
main = do
	csv <- parseCSVFromFile "/var/development/geodata-small.csv"
	case csv of
		Right d -> decodeFile d
		Left err -> putStrLn "File has no data"

decodeFile :: CSV -> IO ()
decodeFile csv = do
	putStrLn $ "File has " ++ (show $ length csv) ++ " entries"
	let rows = filter (isJust) $ map (decodeRow) csv
	let bin = map (messagePut . fromJust) rows
	let size = deltaEncode $ map (ByteString.length) bin
	print size
	mapM_ (ByteString.appendFile "/tmp/test.pbf") bin

decodeRow :: [Field] -> Maybe Entry.Entry
decodeRow (st:lat:lon:src:_) = Just $ Entry.Entry (uFromString st) (uFromString lat) (uFromString lon) (uFromString src)
decodeRow [x] = Nothing
decodeRow [] = Nothing

deltaEncode :: [Int64] -> [Int64]
deltaEncode a = head a : (zipWith (-) (tail a) a)

deltaDecode :: [Int64] -> [Int64]
deltaDecode a = scanl1 (+) a
