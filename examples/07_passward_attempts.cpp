#include <iostream>

int main()
{
    int passward;
    int attempts = 0;

    while(attempts < 3)
    {
        std::cout << "Enter passward: "; std::cin >> passward;

        if(passward == 1234)
        {
            std::cout << "Access granted." << std::endl;
            break;
        }

        attempts++;

        std::cout << "Wrong passward." << std::endl;
    }

    if(passward != 1234)
    {
        std::cout << "Too many faildd attempts." << std::endl;
    }

    return 0;
}