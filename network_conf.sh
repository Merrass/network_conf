#!/bin/bash

# Copyright (C) 2024 Merras
# Made by Merras.

check_existing_configuration() {
    echo "Checking for existing configuration..."
    echo
    if grep -q "enp0s3\|enp0s8\|address" /etc/network/interfaces; then
        echo "Existing configuration detected for enp0s3 or enp0s8 in /etc/network/interfaces."
        echo "Do you want to remove the existing configuration and reconfigure? (y/n)"
        read remove_config
        if [ "$remove_config" == "y" -o "$remove_config" == "Y" ]; then
            echo "Removing existing configuration..."
            sed -i '/enp0s3\|enp0s8\|address/d' /etc/network/interfaces
	    echo
        else
            echo "Keeping existing configuration. Exiting."
	    echo
            exit 0
        fi
    else
        echo "No existing configuration found."
	echo
    fi
}

check_existing_configuration

echo "Welcome to Network Configuration."
echo
echo "Would you like to configure Static (s) or Public (p) Network?"
echo
read spn

exit=true
apt install pv -y >/dev/null 2>&1
while $exit; do
    if [ "$spn" == "s" -o "$spn" == "S" ]; then
                echo "Put the IP address for your static network:"
                read ip
                echo
                echo "Put the MASK for your IP address with slash:"
                read mask
                echo ""
                echo "auto enp0s8" >> /etc/network/interfaces
                echo "iface enp0s8 inet static" >> /etc/network/interfaces
                echo "    address $ip$mask" >> /etc/network/interfaces
                yes | pv -SpeL1 -s 15 > /dev/null
                systemctl restart networking >/dev/null 2>&1
                echo "Almost done..."
                sleep 5
                echo "IP: $ip$mask succesfully configured."
                echo ""
                echo "Do you want to exit (e) or configure a public address (p)?"
                read response
                if [ $response == "p" -o $response == "P" ]; then
                        echo "Configuring public IP"
                        echo ""
                        echo "" >> /etc/network/interfaces
                        echo "auto enp0s3" >> /etc/network/interfaces
                        echo "iface enp0s3 inet dhcp" >> /etc/network/interfaces
                        yes | pv -SpeL1 -s 15 > /dev/null
                        systemctl restart networking >/dev/null 2>&1
                        echo "Almost done..."
                        sleep 5
                        echo "Public IP succesfully configured."
                        exit=false
                else
                        if [ $response == "e" -o $response == "E" ]; then
                                echo "exiting..."
                                exit=false
                        fi
                fi
    elif [ "$spn" == "p" -o "$spn" == "P" ]; then
                if [ $spn == "p" -o $spn == "P" ]; then
                        echo "Configuring public IP"
                        echo ""
                        echo "auto enp0s3" >> /etc/network/interfaces
                        echo "iface enp0s3 inet dhcp" >> /etc/network/interfaces
                        yes | pv -SpeL1 -s 15 > /dev/null
                        systemctl restart networking >/dev/null 2>&1
                        echo "Almost done..."
                        sleep 5
                        echo "Public IP succesfully configured."
                        echo ""
                        echo "Do you want to exit (e) or configure a private address (p)?"
                        read response
                        if [ $response == "p" -o $response == "P" ]; then
                                echo "Put the IP address for your static network:"
                                read ip
                                echo
                                echo "Put the MASK for your IP address with slash:"
                                read mask
                                echo ""
                                echo "auto enp0s8" >> /etc/network/interfaces
                                echo "iface enp0s8 inet static" >> /etc/network/interfaces
                                echo "    address $ip$mask" >> /etc/network/interfaces
                                yes | pv -SpeL1 -s 15 > /dev/null
                                systemctl restart networking >/dev/null 2>&1
                                echo "Almost done..."
                                sleep 5
                                echo "IP: $ip$mask succesfully configured."
                                exit=false
                        else
                                if [ $response == "e" -o $response == "E" ]; then
                                        echo "exiting..."
                                        exit=false
                                fi
                        fi
                fi
    else
        echo "Invalid choice. Please select 's' for Static or 'p' for Public."
    fi
done
