{-# LANGUAGE OverloadedStrings #-}

module Search where

import Common
import Data.List(map)
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uToString, uFromString, Int64, Utf8)
import Text.ProtocolBuffers (getVal)
import Text.ProtocolBuffers.WireMessage (messageGet)
import Data.Binary (decode)
import Data.Binary.Get (Get, getWord64be, getByteString, getLazyByteString, runGet, bytesRead, skip)
import Data.Foldable (toList)
import qualified Data.ByteString.Lazy as ByteString (readFile, length, drop)
--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Sequence(elemIndexL,fromList)
import Data.Int
import qualified Data.Map as M

search :: String -> String -> IO ()
search f s = do
  handle <- ByteString.readFile f
  let (header, hoffset, soffset) = runGet getHeader handle
  let eoffset = hoffset + soffset
  let rootTerm = parseRootTerm s
  let term = parseTerm' s
  case (M.lookup rootTerm header) of
    Just (o,s) -> do
      let subIndexData = ByteString.drop (fromIntegral (hoffset + o)) handle
      let subIndex = runGet (getSubIndex s) subIndexData
      case (M.lookup term subIndex) of
        Just el -> mapM_ (
                    \(eo,es) -> do
                      let entryData = ByteString.drop (fromIntegral (eoffset + eo)) handle
                      let entry = runGet (getEntry es) entryData
                      print entry
                   ) el
        Nothing -> print "Sub Entry does not exist"
    Nothing -> print "Does not exist"
	

getEntry :: Int64 -> Get Entry.Entry
getEntry entrySize = do
    entryBytes <- getLazyByteString (fromIntegral entrySize)
    let Right (entry,_) = messageGet entryBytes ::  Either String (Entry.Entry, ByteString)
    return entry
 
getSubIndex :: Int64 -> Get (M.Map String [(Int64, Int64)])
getSubIndex subIndexSize = do
    subIndexBytes <- getLazyByteString (fromIntegral subIndexSize)
    let subIndex = decode subIndexBytes :: M.Map String [(Int64, Int64)]
    return subIndex

getHeader :: Get ((M.Map String (Int64, Int64)), Int64, Int64)
getHeader = do
    hlen <- getWord64be
    headerBytes <- getLazyByteString (fromIntegral hlen)
    let header = decode headerBytes :: (M.Map String (Int64, Int64))
    slen <- getWord64be
    offset <- bytesRead
    return (header, offset, (fromIntegral slen))

