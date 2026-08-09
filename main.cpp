#include <iostream>

int main()
{
    int a = 5;
    int b = 2;

    std::cout << "1:" << a/b << std::endl;
    std::cout << "2:" << 5.0/2 << std::endl;
    std::cout << "3:" << static_cast<double>(a)/b << std::endl;

    return 0;
}