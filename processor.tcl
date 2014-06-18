#!/bin/sh
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the University of Padova (SIGNET lab) nor the
#    names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# @name_file:   processor.tcl
# @author:      Giovanni Toso
# @last_update: 2014.06.17
# --
# @brief_description: script to process the cvs files
#
# the next line restarts using tclsh \
exec expect -f "$0" -- "$@"

set opt(debug) "0"

if { ${argc} != 3 } {
    return "Error wrong number of params."
}

set associations_file_name [lindex ${argv} 0]
set excel_file_name [lindex ${argv} 1]
set output_file_name [lindex ${argv} 2]

set fp [open ${associations_file_name} r]
array set associations {}
while { [gets $fp data] >= 0 } {
    array set associations [split ${data} {,}]
}
close $fp

if { ${opt(debug)} == 1 } {
    parray associations
}

set fp [open ${excel_file_name} r]
if { [file exists ${output_file_name}] } {
    file delete ${output_file_name}
}
set fp_output [open ${output_file_name} w+]
set flag_first_line 0
while { [gets $fp data] >= 0 } {
    if { ${flag_first_line} == 0} {
        set column_index [lsearch "[split ${data} {,}]" "CDCLEX"]
        set tmp_row [linsert [split ${data} {,}] [expr ${column_index} + 1] "CLIENTE"]
        puts -nonewline ${fp_output} "[join ${tmp_row} ","]\n"
        set flag_first_line 1
    } else {
        set tmp_row_original "[split ${data} {,}]"
        set tmp_array_index [string trimleft [lindex ${tmp_row_original} ${column_index}] "0"]
        if { [info exists associations(${tmp_array_index})] } {
            set tmp_row_new [linsert ${tmp_row_original} [expr ${column_index} + 1] $associations(${tmp_array_index})]
        } else {
            set tmp_row_new [linsert ${tmp_row_original} [expr ${column_index} + 1] "----"]
        }
        if { ${opt(debug)} == 1 } {
            puts ${tmp_row_original}
            puts ${tmp_row_new}
        }
        puts -nonewline ${fp_output} "[join ${tmp_row_new} ","]\n"
    }
}
close $fp
close $fp_output
