module Core.Name

public export
data Name = UN String -- user given name
          | MN String Int -- machine generated name
          | NS (List String) Name -- a name in a hierarchical namespace 
          | HN String Int -- machine generated metavariable name
          | PV String -- implicitly bound pattern variable name

export
nameRoot : Name -> String
nameRoot (UN x) = x
nameRoot (MN x y) = x
nameRoot (NS xs x) = nameRoot x
nameRoot (HN x y) = x
nameRoot (PV x) = x

export
showSep : String -> List String -> String
showSep sep [] = ""
showSep sep [x] = x
showSep sep (x :: xs) = x ++ sep ++ showSep sep xs

export
Show Name where
  show (UN str) = str
  show (MN str int) = "{" ++ str ++ ":" ++ show int ++ "}"
  show (NS ns n) = showSep "." ns ++ "." ++ show n
  show (HN str int) = "?" ++ str ++ "_" ++ show int
  show (PV str) = "{P:" ++ str ++ "}"

export
Eq Name where
  (==) (UN x) (UN y) = x == y
  (==) (MN x y) (MN x' y') = x == x' && y == y'
  (==) (NS xs x) (NS xs' x') = xs == xs' && x == x'
  (==) (HN x y) (HN x' y') = x == x' && y == y'
  (==) (PV x) (PV y) = x == y
  (==) _ _ = False

-- There's no way I'm maintaining a DecEq instance for this without
-- deriving it automatically... this is boring enough...
-- Maybe there should be a type class for these - things which are
-- weaker than DecEq but nevertheless useful - at least until I work out
-- how to get deriving DecEq to work (and if we want to use that feature
-- here in any case... might be best to avoid extensions if there really
-- is a self hosting goal)
export
nameEq : (x : Name) -> (y : Name) -> Maybe (x = y)
nameEq (UN x) (UN y) with (decEq x y)
  nameEq (UN y) (UN y) | (Yes Refl) = Just Refl
  nameEq (UN x) (UN y) | (No contra) = Nothing
nameEq (MN x t) (MN x' t') with (decEq x x')
  nameEq (MN x t) (MN x t') | (Yes Refl) with (decEq t t')
    nameEq (MN x t) (MN x t) | (Yes Refl) | (Yes Refl) = Just Refl
    nameEq (MN x t) (MN x t') | (Yes Refl) | (No contra) = Nothing
  nameEq (MN x t) (MN x' t') | (No contra) = Nothing
nameEq (NS xs x) (NS ys y) with (decEq xs ys)
  nameEq (NS ys x) (NS ys y) | (Yes Refl) with (nameEq x y)
    nameEq (NS ys x) (NS ys y) | (Yes Refl) | Nothing = Nothing
    nameEq (NS ys y) (NS ys y) | (Yes Refl) | (Just Refl) = Just Refl
  nameEq (NS xs x) (NS ys y) | (No contra) = Nothing
nameEq (HN x t) (HN x' t') with (decEq x x')
  nameEq (HN x t) (HN x t') | (Yes Refl) with (decEq t t')
    nameEq (HN x t) (HN x t) | (Yes Refl) | (Yes Refl) = Just Refl
    nameEq (HN x t) (HN x t') | (Yes Refl) | (No contra) = Nothing
  nameEq (HN x t) (HN x' t') | (No contra) = Nothing
nameEq (PV x) (PV y) with (decEq x y)
  nameEq (PV y) (PV y) | (Yes Refl) = Just Refl
  nameEq (PV x) (PV y) | (No contra) = Nothing
nameEq _ _ = Nothing

export
Ord Name where
  compare (UN _) (MN _ _) = LT
  compare (UN _) (NS _ _) = LT
  compare (UN _) (HN _ _) = LT
  compare (UN _) (PV _) = LT

  compare (MN _ _) (NS _ _) = LT
  compare (MN _ _) (HN _ _) = LT
  compare (MN _ _) (PV _) = LT

  compare (NS _ _) (HN _ _) = LT
  compare (NS _ _) (PV _) = LT

  compare (HN _ _) (PV _) = LT

  compare (MN _ _) (UN _) = GT
  compare (NS _ _) (UN _) = GT
  compare (HN _ _) (UN _) = GT
  compare (PV _) (UN _) = GT

  compare (NS _ _) (MN _ _) = GT
  compare (HN _ _) (MN _ _) = GT
  compare (PV _) (MN _ _) = GT

  compare (HN _ _) (NS _ _) = GT
  compare (PV _) (NS _ _) = GT

  compare (PV _) (HN _ _) = GT

  compare (UN x) (UN y) = compare x y
  compare (MN x y) (MN x' y') = case compare x x' of
                                     EQ => compare y y'
                                     t => t
  compare (NS x y) (NS x' y') = case compare x x' of
                                     EQ => compare y y'
                                     t => t
  compare (HN x y) (HN x' y') = case compare x x' of
                                     EQ => compare y y'
                                     t => t
  compare (PV x) (PV y) = compare x y

