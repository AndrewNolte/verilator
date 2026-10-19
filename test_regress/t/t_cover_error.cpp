// -*- mode: C++; c-file-style: "cc-mode" -*-
//*************************************************************************
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of either the GNU Lesser General Public License Version 3
// or the Perl Artistic License Version 2.0.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0
//
//*************************************************************************

#include "verilated_cov.h"

int main(int argc, char** argv) {
    VerilatedContext context;
    context.commandArgs(argc, argv);
    const char* const keyp = context.commandArgsPlusMatch("key=");
    if (keyp[0]) {
        Verilated::addExitCb(
            [](void* datap) {
                VerilatedCovContext* const covp = static_cast<VerilatedCovContext*>(datap);
                static uint32_t count = 0;
                VL_COVER_INSERT(covp, "top", &count, "comment", "exit callback");
                covp->zero();
                VL_PRINTF("Coverage exit callback completed\n");
            },
            context.coveragep());
        uint32_t count = 0;
        VL_COVER_INSERT(context.coveragep(), "top", &count, keyp + 5, "value");
        return 0;
    }

    // Opening a directory as a file fails without relying on permissions or name limits.
    context.coverageFilename(".");
    Verilated::addExitCb([](void* datap) { static_cast<VerilatedCovContext*>(datap)->write(); },
                         context.coveragep());
    context.coveragep()->write();
    return 0;
}
