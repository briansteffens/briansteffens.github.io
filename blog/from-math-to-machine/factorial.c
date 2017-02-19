#include <stdio.h>

int factorial(int n)
{
    int ret = 1;

    while (n > 1)
    {
        ret *= n;
        n--;
    }

    return ret;
}

int main()
{
    return factorial(5);
}
