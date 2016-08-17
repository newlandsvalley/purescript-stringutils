module Test.Data.Char.Utils
  ( testCharUtils )
where

import Control.Monad.Eff.Console  (log)
import Data.Char.Utils            ( fromCodePoint, isSurrogate, toCodePoint
                                  , unsafeFromCodePoint
                                  )
import Data.Maybe                 (Maybe(Just, Nothing), fromJust, isJust)
import Partial.Unsafe             (unsafePartial)
import Prelude
import Test.Input                 ( CodePoint(CodePoint)
                                  , SurrogateCodePoint(SurrogateCodePoint)
                                  )
import Test.StrongCheck           (Result, SC, (===), assert, quickCheck)
import Test.StrongCheck.Arbitrary (class Arbitrary, arbitrary)
import Test.StrongCheck.Gen       (chooseInt)

testCharUtils :: SC () Unit
testCharUtils = do
  log "fromCodePoint"
  let
    fromCodePointRangeProp :: CodePoint -> Result
    fromCodePointRangeProp (CodePoint n) = isJust (fromCodePoint n) === true

  assert $ fromCodePoint   97     === Just 'a'
  assert $ fromCodePoint 8704     === Just '∀'
  assert $ fromCodePoint (-1)     === Nothing
  assert $ fromCodePoint 0x110000 === Nothing
  quickCheck fromCodePointRangeProp

  log "isSurrogate"
  let
    surrogateRangeProp :: SurrogateCodePoint -> Result
    surrogateRangeProp (SurrogateCodePoint n) =
      isSurrogate(unsafePartial (fromJust (fromCodePoint n))) === true

  quickCheck surrogateRangeProp

  log "toCodePoint"
  assert $ toCodePoint 'a' === 97
  assert $ toCodePoint '∀' === 8704

  log "fromCodePoint <<< toCodePoint == Just"
  let
    codePointIdentityProp :: Char -> Result
    codePointIdentityProp = (===) <$> fromCodePoint <<< toCodePoint <*> Just

  quickCheck codePointIdentityProp

  log "unsafeFromCodePoint"
  assert $ unsafeFromCodePoint   97 === 'a'
  assert $ unsafeFromCodePoint 8704 === '∀'

  log "unsafeFromCodePoint & fromCodePoint"
  let
    fromCodePointIdentityProp :: CodePoint -> Result
    fromCodePointIdentityProp (CodePoint n) =
      (===) <$> fromCodePoint <*> Just <<< unsafeFromCodePoint $ n

  quickCheck fromCodePointIdentityProp
