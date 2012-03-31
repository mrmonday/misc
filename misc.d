import std.traits;
import std.typecons;
import std.typetuple;

template Intersect(T...)
{
    template With(U...)
    {
        static if (T.length == 1)
        {
            static if (staticIndexOf!(T[0], U) == -1)
                alias TypeTuple!() With;
            else
                alias T[0] With;
        }
        else static if (U.length == 1)
        {
            static if (staticIndexOf!(U[0], T) == -1)
                alias TypeTuple!() With;
            else
                alias U[0] With;
        }
        else
        {
            alias NoDuplicates!(TypeTuple!(Intersect!(T[0]).With!U, Intersect!(T[1..$]).With!U,
                             Intersect!T.With!(U[0]), Intersect!T.With!(U[1..$]))) With;
        }
    }
}

static assert(is(Intersect!(int, char, byte, bool).With!(int, char, string, short) == TypeTuple!(int, char)));
