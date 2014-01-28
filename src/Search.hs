{-# LANGUAGE OverloadedStrings #-}

module Search where

import Common
import Data.List(map, elemIndex)
import qualified PB.Index.Header as Header
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uToString, uFromString, Int64, Utf8)
import Text.ProtocolBuffers (getVal)
import Text.ProtocolBuffers.WireMessage (messageGet)
import Data.Binary.Get (Get, getWord64be, getByteString, getLazyByteString, runGet, bytesRead, skip)
import Data.Foldable (toList)
import qualified Data.ByteString.Lazy as ByteString (readFile, length)
import qualified Data.ByteString as ByteString'
--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Sequence(elemIndexL,fromList)
import Data.Int
import Data.Char

search :: String -> IO ()
search s = do
	handle <- ByteString.readFile "/tmp/test.pbf"
	let header = runGet getHeader handle
	let terms = getVal (fst header) Header.term 
	let sizes = deltaDecode $ toList $ getVal (fst header) Header.size 
	case (elemIndexL (parseTerm s) terms) of
		Just i -> do
			let offset = (snd header) + (foldl1 (+) (take i sizes))
			let entrySize = sizes !! i
			let entry = runGet (getEntry offset entrySize) handle
			print entry
		Nothing -> print "Does not exist"


getHeader :: Get (Header.Header, Int64)
getHeader = do
    len <- getWord64be
    headerBytes <- getLazyByteString (fromIntegral len)
    let Right (header,_) = messageGet headerBytes ::  Either String (Header.Header, ByteString)
    offset <- bytesRead
    return (header, offset)

getEntry :: Int64 -> Int64 -> Get Entry.Entry
getEntry offset entrySize = do
    _ <- skip $ fromIntegral offset
    entryBytes <- getLazyByteString (fromIntegral entrySize)
    let Right (entry,_) = messageGet entryBytes ::  Either String (Entry.Entry, ByteString)
    return entry

parseTerm :: String -> Utf8
parseTerm = uFromString . parseTerm'

parseTerm' :: String -> String
parseTerm' = do
	let filterAlphas = map (toUpper) . filter (\x -> (isAlpha x) || (isSpace x))
	let removeSpaces = filter (isAlpha)
	let filterWords = unwords . filter ("NEAR" /=) . filter ("IN" /=) . words
	removeSpaces . filterWords . filterAlphas