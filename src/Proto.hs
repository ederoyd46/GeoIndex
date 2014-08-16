{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Proto where
  import Data.ProtocolBuffers
  import Data.Text as T
  import Data.ByteString hiding (putStrLn)
  import GHC.Generics (Generic)
  import Data.Serialize (runGet, runPut)
  
  testOut :: ByteString
  testOut = do
    let putStrField s = putField (T.pack s)
    let toBuffer a = runPut $ encodeMessage a
    let tag = Tag { key = putStrField "KEY", value = putStrField "VALUE" }
    let entry = Entry { term = putStrField "LEEDS"
                      , latitude = putStrField "123456"
                      , longitude = putStrField "654321"
                      , src = putStrField "TEST"
                      , rank = putStrField "1"
                      , type' = putStrField "TEST"
                      , tags = putField [tag]
                      }
    toBuffer entry
  
  testIn :: ByteString -> IO ()
  testIn msg = do
    let Right result = runGet decodeMessage =<< Right msg :: Either String Entry
    putStrLn $ show result


  data Tag = Tag
    { key :: Required 1 (Value Text)
    , value :: Required 2 (Value Text)
    } deriving (Generic, Show)

  instance Encode Tag
  instance Decode Tag

  data Entry = Entry
    { term :: Required 1 (Value Text)
    , latitude :: Required 2 (Value Text)
    , longitude :: Required 3 (Value Text)
    , src :: Required 4 (Value Text)
    , rank :: Required 5 (Value Text)
    , type' :: Required 6 (Value Text)
    , tags :: Repeated 7 (Message Tag)
    } deriving (Generic, Show)

  instance Encode Entry
  instance Decode Entry

