#include <iostream>

int main()
{
    int age;
    bool hasTicket;

    std::cout << "Enter your age: "; std::cin >> age;
    
    std::cout << "Do you have a ticket? (1 = yes, 0 = no): "; std::cin >> hasTicket;

    if(age >= 18)
    {
        std::cout << "You are an adult." << std::endl;

        if(hasTicket)
        {
            std::cout << "Entry allowed." << std::endl; 
        }
        else
        {
            std::cout << "You need a ticket." << std::endl;
        }
    }
    else
    {
        std::cout << "You are too young." << std::endl;
    }


    return 0;
}