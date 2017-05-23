module Parser.Raw

import Core.TT
import Parser.Lexer
import Parser.Grammar
import Data.Vect

term : Grammar Token True Integer
term = do tok <- Terminal isLiteral
          Empty (getLit tok)
  where
    isLiteral : Token -> Bool
    isLiteral (Literal _) = True
    isLiteral _ = False

    getLit : Token -> Integer
    getLit (Literal i) = i
    getLit _ = 0

terms : Grammar Token True Integer
terms = do t <- term
           dbl <- Empty (t * 2) -- gratuitous empty rule
           (do ts <- terms
               Empty (t + ts)) <|> Empty dbl


