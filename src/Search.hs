{-# LANGUAGE OverloadedStrings #-}

module Search where

import Common
import Data.List(map, elemIndex)
import qualified PB.Index.Header as Header
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uToString, Int64)
import Text.ProtocolBuffers (getVal)
import Text.ProtocolBuffers.WireMessage (messageGet)
import Data.Binary.Get (Get, getWord64be, getLazyByteString, runGet, bytesRead, skip)
import Data.Foldable (toList)
import qualified Data.ByteString.Lazy as ByteString (readFile, length)

--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Int

search :: String -> IO ()
search s = do
	handle <- ByteString.readFile "/tmp/test.pbf"
	let header = runGet getHeader handle
	let terms = map (uToString) $ toList $ getVal (fst header) Header.term 
	let sizes = deltaDecode $ toList $ getVal (fst header) Header.size 
	case (elemIndex s terms) of
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

