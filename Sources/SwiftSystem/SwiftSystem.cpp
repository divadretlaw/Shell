//
//  SwiftSystem.cpp
//  SwiftSystem
//
//  Created by David Walter on 20.03.21.
//

#include "include/SwiftSystem.h"
#include <iostream>

using namespace std;

__API_AVAILABLE(macos(10.0)) __IOS_PROHIBITED __WATCHOS_PROHIBITED __TVOS_PROHIBITED
int swiftSystem(const char *cmd) {
    int out = system(cmd);
    return WEXITSTATUS(out);
}
