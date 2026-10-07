#!/usr/bin/env python3
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either the GNU Lesser General Public License Version 3
# or the Perl Artistic License Version 2.0.
# SPDX-FileCopyrightText: 2026 Wilson Snyder
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

import vltest_bootstrap

test.scenarios('vlt')

for padding, limit, count in [(7, 1, 5), (1023, 1, 5), (7, 300, 5), (7, 500, 5), (7, 1000, 7),
                              (7, 0, 7)]:
    test.compile(
        verilator_flags2=['-O3', '--inline-mult',
                          str(limit), f'-GPADDING={padding}', '--stats'])
    test.execute()
    stats = f'{test.stats}.{padding}.{limit}'
    test.file_sed(test.stats, stats, lambda contents: contents)
    test.file_grep(stats, r'Optimizations, Inlined instances\s+(\d+)', count)

test.compile(verilator_flags2=['--stats'])
test.execute()
test.file_grep(test.stats, r'Optimizations, Inlined instances\s+(\d+)', 7)

for index, (flags, count) in enumerate([(['-O3'], 5), (['--inline-mult', '1', '-O3'], 5),
                                        (['--inline-mult', '0', '-O3'], 7),
                                        (['-O3', '--inline-mult', '0'], 7)]):
    test.compile(verilator_flags2=['-GGROUP_WORDS=4095', '--stats'] + flags)
    test.execute()
    stats = f'{test.stats}.optimization.{index}'
    test.file_sed(test.stats, stats, lambda contents: contents)
    test.file_grep(stats, r'Optimizations, Inlined instances\s+(\d+)', count)

for index, (flags, limit, count) in enumerate([(['+define+KEEP_GROUP'], 20000, 5),
                                               (['+define+FORCE_INLINE'], 1, 7),
                                               (['+define+KEEP_GROUP', '--flatten'], 1, 7)]):
    test.compile(verilator_flags2=['--inline-mult', str(limit), '--stats'] + flags)
    test.execute()
    stats = f'{test.stats}.explicit.{index}'
    test.file_sed(test.stats, stats, lambda contents: contents)
    test.file_grep(stats, r'Optimizations, Inlined instances\s+(\d+)', count)

test.passes()
