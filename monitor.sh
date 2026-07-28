#!/bin/bash

#===========================================================
# Linux System Monitoring Dashboard
# Author : Your Name
# Version: 1.0
#===========================================================

#############################
# Global Variables
#############################

REPORT_DIR="reports"
LOG_FILE="monitor.log"

mkdir -p "$REPORT_DIR"
touch "$LOG_FILE"

#############################
# Colors
#############################

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
WHITE="\033[97m"
BOLD="\033[1m"
RESET="\033[0m"

#############################
# Ctrl+C Handling
#############################

trap ctrl_c INT

ctrl_c()
{
    echo
    echo -e "${RED}Program Interrupted.${RESET}"
    log_action "Program terminated using Ctrl+C"
    exit 0
}

#############################
# Logging
#############################

log_action()
{
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

#############################
# Pause Function
#############################

pause()
{
    echo
    read -p "Press Enter to continue..."
}

#############################
# Check Required Command
#############################

check_command()
{
    command -v "$1" >/dev/null 2>&1

    if [ $? -ne 0 ]
    then
        echo -e "${RED}$1 command not found.${RESET}"
        log_action "$1 command missing"
        pause
        return 1
    fi

    return 0
}

#############################
# Header
#############################

header()
{
    clear

    echo -e "${CYAN}${BOLD}"
    echo "============================================================"
    echo "          LINUX SYSTEM MONITORING DASHBOARD"
    echo "============================================================"
    echo -e "${RESET}"

    echo "User      : $(whoami)"
    echo "Hostname  : $(hostname)"
    echo "Date      : $(date)"
    echo
}

#############################
# System Information
#############################

system_information()
{
    header

    echo -e "${GREEN}System Information${RESET}"
    echo "--------------------------------------------"

    echo "Operating System : $(uname -o)"
    echo "Kernel Version   : $(uname -r)"
    echo "Architecture     : $(uname -m)"
    echo "Hostname         : $(hostname)"
    echo "Current User     : $(whoami)"
    echo "Shell            : $SHELL"
    echo "Current Directory: $(pwd)"

    log_action "Viewed System Information"

    pause
}

#############################
# CPU Usage
#############################

cpu_usage()
{
    header

    check_command top || return

    echo -e "${GREEN}CPU Usage${RESET}"
    echo "--------------------------------------------"

    top -bn1 | head -5

    log_action "Viewed CPU Usage"

    pause
}

#############################
# Memory Usage
#############################

memory_usage()
{
    header

    check_command free || return

    echo -e "${GREEN}Memory Usage${RESET}"
    echo "--------------------------------------------"

    free -h

    log_action "Viewed Memory Usage"

    pause
}

#############################
# Disk Usage
#############################

disk_usage()
{
    header

    check_command df || return

    echo -e "${GREEN}Disk Usage${RESET}"
    echo "--------------------------------------------"

    df -h

    log_action "Viewed Disk Usage"

    pause
}

#############################
# Logged-in Users
#############################

logged_in_users()
{
    header

    check_command who || return

    echo -e "${GREEN}Logged-in Users${RESET}"
    echo "--------------------------------------------"

    who

    log_action "Viewed Logged-in Users"

    pause
}

#############################
# System Uptime
#############################

system_uptime()
{
    header

    check_command uptime || return

    echo -e "${GREEN}System Uptime${RESET}"
    echo "--------------------------------------------"

    uptime

    log_action "Viewed System Uptime"

    pause
}

#############################
# Network Information
#############################

network_information()
{
    header

    echo -e "${GREEN}Network Information${RESET}"
    echo "--------------------------------------------"

    if command -v ip >/dev/null 2>&1
    then
        ip addr show
    elif command -v ifconfig >/dev/null 2>&1
    then
        ifconfig
    else
        echo "Neither 'ip' nor 'ifconfig' is available."
    fi

    log_action "Viewed Network Information"

    pause
}

#############################
# Top CPU Processes
#############################

top_cpu_processes()
{
    header

    check_command ps || return

    echo -e "${GREEN}Top 5 CPU Consuming Processes${RESET}"
    echo "--------------------------------------------"

    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6

    log_action "Viewed Top CPU Processes"

    pause
}

#############################
# Top Memory Processes
#############################

top_memory_processes()
{
    header

    check_command ps || return

    echo -e "${GREEN}Top 5 Memory Consuming Processes${RESET}"
    echo "--------------------------------------------"

    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -6

    log_action "Viewed Top Memory Processes"

    pause
}

#############################
# Search Process
#############################

search_process()
{
    header

    check_command ps || return

    read -p "Enter Process Name: " pname

    pname=$(echo "$pname" | xargs)

    if [ -z "$pname" ]
    then
        echo
        echo -e "${RED}Process name cannot be empty.${RESET}"
        pause
        return
    fi

    echo
    result=$(ps -ef | grep -i "$pname" | grep -v grep)

    if [ -z "$result" ]
    then
        echo -e "${RED}No running process found with name '$pname'.${RESET}"
    else
        echo "$result"
    fi

    log_action "Searched Process: $pname"

    pause
}

#############################
# Generate Report
#############################

generate_report()
{
    header

    report="$REPORT_DIR/SystemReport_$(date +%Y%m%d_%H%M%S).txt"

    {
        echo "==========================================="
        echo "      Linux System Monitoring Report"
        echo "==========================================="
        echo
        echo "Generated On : $(date)"
        echo "Hostname     : $(hostname)"
        echo "User         : $(whoami)"
        echo

        echo "------------ CPU ------------"
        top -bn1 | head -5
        echo

        echo "------------ Memory ------------"
        free -h
        echo

        echo "------------ Disk ------------"
        df -h
        echo

        echo "------------ Uptime ------------"
        uptime
        echo

        echo "------------ Logged-in Users ------------"
        who
        echo

        echo "------------ Top CPU Processes ------------"
        ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6
        echo

        echo "------------ Top Memory Processes ------------"
        ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -6

    } > "$report"

    echo
    echo -e "${GREEN}Report generated successfully.${RESET}"
    echo "$report"

    log_action "Generated Report: $report"

    pause
}

#############################
# Menu
#############################

show_menu()
{
    header

    echo "1.  System Information"
    echo "2.  CPU Usage"
    echo "3.  Memory Usage"
    echo "4.  Disk Usage"
    echo "5.  Logged-in Users"
    echo "6.  System Uptime"
    echo "7.  Network Information"
    echo "8.  Top CPU Processes"
    echo "9.  Top Memory Processes"
    echo "10. Search Process"
    echo "11. Generate System Report"
    echo "12. Exit"
    echo
}

#############################
# Main Program
#############################

while true
do
    show_menu

    read -p "Enter your choice (1-12): " choice

    case "$choice" in
        1) system_information ;;
        2) cpu_usage ;;
        3) memory_usage ;;
        4) disk_usage ;;
        5) logged_in_users ;;
        6) system_uptime ;;
        7) network_information ;;
        8) top_cpu_processes ;;
        9) top_memory_processes ;;
        10) search_process ;;
        11) generate_report ;;
        12)
            echo
            echo -e "${GREEN}Thank you for using Linux System Monitoring Dashboard.${RESET}"
            log_action "Program exited normally"
            exit 0
            ;;
        *)
            echo
            echo -e "${RED}Invalid choice. Please enter a number between 1 and 12.${RESET}"
            sleep 2
            ;;
    esac
done