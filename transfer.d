import std.traits;
import std.typecons;
import std.typetuple;

template ExpandTypes(T...)
{
    static if (T.length == 1)
    {
        alias typeof(T[0].tupleof) ExpandTypes;
    }
    else
    {
        alias TypeTuple!(ExpandTypes!(T[0]), ExpandTypes!(T[1..$])) ExpandTypes;
    }
}

template NumberOfFields(T...)
{
    static if (T.length == 1)
        enum NumberOfFields = T[0].tupleof.length;
    else
        enum NumberOfFields = NumberOfFields!(T[0]) + NumberOfFields!(T[1..$]);
}

auto prepare(T)(T t) if (is(T == class))
{
    Tuple!(typeof(T.tupleof), ExpandTypes!(BaseClassesTuple!T)) ret;
    foreach (i, field; t.tupleof)
    {
        ret[i] = field;
    }
    foreach (n, baseClass; BaseClassesTuple!T)
    {
        foreach (i, field; (cast(baseClass)t).tupleof)
        {
            static if (n == 0)
            {
                ret.field[T.tupleof.length + i] = field;
            }
            else
            {
                ret.field[T.tupleof.length + NumberOfFields!(BaseClassesTuple!T[0..n]) + i] = field;
            }
        }
    }
    return ret;
}

auto transfer(T, U...)(Tuple!U values)
{
    T t = new T;
    foreach (i, field; t.tupleof)
    {
        t.tupleof[i] = values[i];
    }
    foreach (n, baseClass; BaseClassesTuple!T)
    {
        foreach (i, field; (cast(baseClass)t).tupleof)
        {
            static if (n == 0)
                (cast(baseClass)t).tupleof[i] = values[T.tupleof.length + i];
            else
                (cast(baseClass)t).tupleof[i] = values[T.tupleof.length + NumberOfFields!(BaseClassesTuple!T[0..n]) + i];
        }
    }
    return t;
}

version(unittest)
{
    class A
    {
        int a;
        string b;

        this()
        {
        }

        this(int a, string b)
        {
            this.a = a;
            this.b = b;
        }
    }

    class B : A
    {
        char c;

        this()
        {
            super();
        }

        this(char c)
        {
            super(14, "B");
            this.c = c;
        }
    }

    class C : B
    {
        bool d;

        this()
        {
            super();
        }

        this(bool d)
        {
            super('e');
            this.d = d;
        }
    }

    unittest
    {
        enum preparedA = prepare(new A(4, "a"));
        enum preparedB = prepare(new B('d'));
        enum preparedC = prepare(new C(true));

        auto transferredA = transfer!A(preparedA);
        assert(transferredA.a == 4);
        assert(transferredA.b == "a");

        auto transferredB = transfer!B(preparedB);
        assert(transferredB.a == 14);
        assert(transferredB.b == "B");
        assert(transferredB.c == 'd');

        auto transferredC = transfer!C(preparedC);
        assert(transferredC.a == 14);
        assert(transferredC.b == "B");
        assert(transferredC.c == 'e');
        assert(transferredC.d == true);
    }
}
