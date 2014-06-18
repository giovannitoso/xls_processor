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

# @name_file:   xls_processor.sh
# @author:      Giovanni Toso
# @last_update: 2014.06.17
# --
# @brief_description: Shell script used to run the xls_processor

# Note: the ASSOCIATION.xls file must have the following struncture
# COLUMN1 = IDs | COLUMN2 = STRINGS

# Variables
SCRIPT_BASENAME="xls_processor"
LOG_FILE="${SCRIPT_BASENAME}.log"
OUTPUT_FILENAME="output.csv"
PROCESSOR_FILENAME="processor.tcl"

# Functions
log_with_date() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] ${1}" >> ${LOG_FILE}
}

# Check the required scripts
if [ -f ${PROCESSOR_FILENAME} ]; then
    log_with_date "chmod +x ${PROCESSOR_FILENAME}"
    chmod +x ${PROCESSOR_FILENAME}
else
    log_with_date "Processor file ${PROCESSOR_FILENAME} not available. Exiting ..."
    exit 1
fi

# Check the input parameters
if [ "$#" -ne 2 ]; then
    log_with_date "Error wrong number of params: $@. Exiting ..."
    exit 1
fi
ASSOCIATIONS_FILENAME=${1}
EXCEL_FILENAME=${2}

# cd to the working folder
WORKING_FOLDER_PATH=`pwd`
cd ${WORKING_FOLDER_PATH}

# Convert from xls to csv the file with the associations ID - STRING
if [ -f ${ASSOCIATIONS_FILENAME} ]; then
    log_with_date "Converting ${ASSOCIATIONS_FILENAME} in csv"
    libreoffice --headless --convert-to csv ${ASSOCIATIONS_FILENAME} --outdir . 2>/dev/null 1>/dev/null
else
    log_with_date "${ASSOCIATIONS_FILENAME} does not exist. Exiting ..."
    exit 1
fi

# Remove duplicated lines
ASSOCIATIONS_CSV_FILENAME="`basename ${ASSOCIATIONS_FILENAME} .xls`.csv"
ASSOCIATIONS_CSV_UNIQ_FILENAME="${ASSOCIATIONS_CSV_FILENAME}.uniq"
log_with_date "Removing duplicated lines in ${ASSOCIATIONS_CSV_FILENAME}"
cat ${ASSOCIATIONS_CSV_FILENAME} | sort | uniq > ${ASSOCIATIONS_CSV_UNIQ_FILENAME}

# Convert from xls to csv the excel file to be processed
if [ -f ${EXCEL_FILENAME} ]; then
    log_with_date "Converting ${EXCEL_FILENAME} in csv"
    libreoffice --headless --convert-to csv ${EXCEL_FILENAME} --outdir . 2>/dev/null 1>/dev/null
else
    log_with_date "${EXCEL_FILENAME} does not exist. Exiting ..."
    exit 1
fi
EXCEL_CSV_FILENAME="`basename ${EXCEL_FILENAME} .xls`.csv"

if [ -f ${OUTPUT_FILENAME} ]; then
    rm ${OUTPUT_FILENAME}
fi

./processor.tcl ${ASSOCIATIONS_CSV_UNIQ_FILENAME} ${EXCEL_CSV_FILENAME} ${OUTPUT_FILENAME}

# Clean the folder
log_with_date "Cleaning temporary files."
if [ -f ${ASSOCIATIONS_CSV_FILENAME} ]; then
    rm ${ASSOCIATIONS_CSV_FILENAME}
fi

if [ -f ${ASSOCIATIONS_CSV_UNIQ_FILENAME} ]; then
    rm ${ASSOCIATIONS_CSV_UNIQ_FILENAME}
fi

if [ -f ${EXCEL_CSV_FILENAME} ]; then
    rm ${EXCEL_CSV_FILENAME}
fi

cd - > /dev/null
