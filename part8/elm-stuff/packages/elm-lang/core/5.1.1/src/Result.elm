module Result
    exposing
        ( Result(..)
        , andThen
        , fromMaybe
        , map
        , map2
        , map3
        , map4
        , map5
        , mapError
        , toMaybe
        , withDefault
        )

{-| A `Result` is the result of a computation that may fail. This is a great
way to manage errors in Elm.


# Type and Constructors

@docs Result


# Mapping

@docs map, map2, map3, map4, map5


# Chaining

@docs andThen


# Handling Errors

@docs withDefault, toMaybe, fromMaybe, mapError

-}

import Maybe exposing (Maybe(Just, Nothing))


{-| A `Result` is either `Ok` meaning the computation succeeded, or it is an
`Err` meaning that there was some failure.
-}
type Result error value
    = Ok value
    | Err error


{-| If the result is `Ok` return the value, but if the result is an `Err` then
return a given default value. The following examples try to parse integers.

    Result.withDefault 0 (String.toInt "123") == 123
    Result.withDefault 0 (String.toInt "abc") == 0

-}
withDefault : a -> Result x a -> a
withDefault def result =
    case result of
        Ok a ->
            a

        Err _ ->
            def


{-| Apply a function to a result. If the result is `Ok`, it will be converted.
If the result is an `Err`, the same error value will propagate through.

    map sqrt (Ok 4.0)          == Ok 2.0
    map sqrt (Err "bad input") == Err "bad input"

-}
map : (a -> value) -> Result x a -> Result x value
map func ra =
    case ra of
        Ok a ->
            Ok (func a)

        Err e ->
            Err e


{-| Apply a function to two results, if both results are `Ok`. If not,
the first argument which is an `Err` will propagate through.

    map2 (+) (String.toInt "1") (String.toInt "2") == Ok 3
    map2 (+) (String.toInt "1") (String.toInt "y") == Err "could not convert string 'y' to an Int"
    map2 (+) (String.toInt "x") (String.toInt "y") == Err "could not convert string 'x' to an Int"

-}
map2 : (a -> b -> value) -> Result x a -> Result x b -> Result x value
map2 func ra rb =
    case ( ra, rb ) of
        ( Ok a, Ok b ) ->
            Ok (func a b)

        ( Err x, _ ) ->
            Err x

        ( _, Err x ) ->
            Err x


{-| -}
map3 : (a -> b -> c -> value) -> Result x a -> Result x b -> Result x c -> Result x value
map3 func ra rb rc =
    case ( ra, rb, rc ) of
        ( Ok a, Ok b, Ok c ) ->
            Ok (func a b c)

        ( Err x, _, _ ) ->
            Err x

        ( _, Err x, _ ) ->
            Err x

        ( _, _, Err x ) ->
            Err x


{-| -}
map4 : (a -> b -> c -> d -> value) -> Result x a -> Result x b -> Result x c -> Result x d -> Result x value
map4 func ra rb rc rd =
    case ( ra, rb, rc, rd ) of
        ( Ok a, Ok b, Ok c, Ok d ) ->
            Ok (func a b c d)

        ( Err x, _, _, _ ) ->
            Err x

        ( _, Err x, _, _ ) ->
            Err x

        ( _, _, Err x, _ ) ->
            Err x

        ( _, _, _, Err x ) ->
            Err x


{-| -}
map5 : (a -> b -> c -> d -> e -> value) -> Result x a -> Result x b -> Result x c -> Result x d -> Result x e -> Result x value
map5 func ra rb rc rd re =
    case ( ra, rb, rc, rd, re ) of
        ( Ok a, Ok b, Ok c, Ok d, Ok e ) ->
            Ok (func a b c d e)

        ( Err x, _, _, _, _ ) ->
            Err x

        ( _, Err x, _, _, _ ) ->
            Err x

        ( _, _, Err x, _, _ ) ->
            Err x

        ( _, _, _, Err x, _ ) ->
            Err x

        ( _, _, _, _, Err x ) ->
            Err x


{-| Chain together a sequence of computations that may fail. It is helpful
to see its definition:

    andThen : (a -> Result e b) -> Result e a -> Result e b
    andThen callback result =
        case result of
            Ok value ->
                callback value

            Err msg ->
                Err msg

This means we only continue with the callback if things are going well. For
example, say you need to use (`toInt : String -> Result String Int`) to parse
a month and make sure it is between 1 and 12:

    toValidMonth : Int -> Result String Int
    toValidMonth month =
        if month >= 1 && month <= 12 then
            Ok month
        else
            Err "months must be between 1 and 12"

    toMonth : String -> Result String Int
    toMonth rawString =
        toInt rawString
            |> andThen toValidMonth


    -- toMonth "4" == Ok 4
    -- toMonth "9" == Ok 9
    -- toMonth "a" == Err "cannot parse to an Int"
    -- toMonth "0" == Err "months must be between 1 and 12"

This allows us to come out of a chain of operations with quite a specific error
message. It is often best to create a custom type that explicitly represents
the exact ways your computation may fail. This way it is easy to handle in your
code.

-}
andThen : (a -> Result x b) -> Result x a -> Result x b
andThen callback result =
    case result of
        Ok value ->
            callback value

        Err msg ->
            Err msg


{-| Transform an `Err` value. For example, say the errors we get have too much
information:

    parseInt : String -> Result ParseError Int

    type alias ParseError =
        { message : String
        , code : Int
        , position : (Int,Int)
        }

    mapError .message (parseInt "123") == Ok 123
    mapError .message (parseInt "abc") == Err "char 'a' is not a number"

-}
mapError : (x -> y) -> Result x a -> Result y a
mapError f result =
    case result of
        Ok v ->
            Ok v

        Err e ->
            Err (f e)


{-| Convert to a simpler `Maybe` if the actual error message is not needed or
you need to interact with some code that primarily uses maybes.

    parseInt : String -> Result ParseError Int

    maybeParseInt : String -> Maybe Int
    maybeParseInt string =
        toMaybe (parseInt string)

-}
toMaybe : Result x a -> Maybe a
toMaybe result =
    case result of
        Ok v ->
            Just v

        Err _ ->
            Nothing


{-| Convert from a simple `Maybe` to interact with some code that primarily
uses `Results`.

    parseInt : String -> Maybe Int

    resultParseInt : String -> Result String Int
    resultParseInt string =
        fromMaybe ("error parsing string: " ++ toString string) (parseInt string)

-}
fromMaybe : x -> Maybe a -> Result x a
fromMaybe err maybe =
    case maybe of
        Just v ->
            Ok v

        Nothing ->
            Err err
