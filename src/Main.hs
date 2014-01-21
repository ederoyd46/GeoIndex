{-# LANGUAGE OverloadedStrings #-}

import Text.CSV
import Data.List(map)
import Control.Monad(mapM_)
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers
import Text.ProtocolBuffers.Header (defaultValue, uFromString)
import Text.ProtocolBuffers.WireMessage (messageGet, messagePut)
import qualified Data.ByteString.Lazy as ByteString (readFile, writeFile, length, appendFile)
import Codec.Compression.Zlib as Zlib (compress, decompress)

main :: IO ()
main = do
	csv <- parseCSVFromFile "/var/development/geodata.csv"
	case csv of
		Right d -> decodeFile d
		Left err -> print "File has no data"

decodeFile csv = do
	print $ "File has " ++ (show $ length csv) ++ " entries"
	let parseRows = map (decodeRow) csv
	mapM_ (\v -> ByteString.appendFile "/tmp/test.pbf" $ messagePut v) parseRows


decodeRow (st:lat:lon:src:_) = Entry.Entry (uFromString st) (uFromString lat) (uFromString lon) (uFromString src)
decodeRow [x] = Entry.Entry (uFromString "test") (uFromString "test") (uFromString "test") (uFromString "test")


--ByteString.writeFile filename $ messagePut new_address_book