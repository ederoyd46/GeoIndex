{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Proto where
  import Data.ProtocolBuffers
  import Data.Text as T
  import GHC.Generics (Generic)
  
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

