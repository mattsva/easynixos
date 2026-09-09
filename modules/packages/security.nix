# modules/packages/security.nix
# ------------------------------------------------------------------------------------------------------------------------
# Cybersecurity and network analysis tools.
#
# These tools are provided strictly for legitimate purposes such as security research,
# Capture The Flag (CTF) challenges, educational use, and penetration testing.
#
# You must only use these tools on systems you own or have explicit, written permission to test.
# Unauthorized use against third-party systems may be illegal and is strictly prohibited.
#
# The creator (mattsva) assumes no liability for misuse, damage, or legal consequences
# resulting from the use of these tools.
# ------------------------------------------------------------------------------------------------------------------------
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # Network scanning & discovery ---------------------------------------------------------------------------------------
    nmap           # port scanner and host discovery (+ NSE scripting)
    masscan        # ultra-fast port scanner
    netcat-gnu     # TCP/UDP swiss army knife
    hping          # TCP/IP packet crafter
    arp-scan       # ARP-level host discovery

    # Traffic analysis ---------------------------------------------------------------------------------------------------
    # Wireshark GUI is enabled via programs.wireshark in user.nix (non-root capture)
    tcpdump

    # Exploitation frameworks --------------------------------------------------------------------------------------------
    metasploit     # MSF console - `msfconsole` to launch

    # Web application testing --------------------------------------------------------------------------------------------
    sqlmap         # automated SQL injection detection & exploitation
    nikto          # web server vulnerability scanner
    gobuster       # directory / DNS brute-forcer
    ffuf           # fast web fuzzer

    # Password & hash cracking -------------------------------------------------------------------------------------------
    hashcat        # GPU-accelerated hash cracker
#    john           # John the Ripper (CPU hash cracker)
    hydra          # network login brute-forcer

    # Wireless -----------------------------------------------------------------------------------------------------------
    aircrack-ng    # WEP/WPA cracking suite
    kismet         # wireless network detector / sniffer

    # Reverse engineering / binary analysis ------------------------------------------------------------------------------
    ghidra         # NSA reverse engineering framework
    radare2        # CLI disassembler / debugger
    #binwalk        # firmware analysis and extraction

    # Forensics ----------------------------------------------------------------------------------------------------------
    volatility3    # memory forensics framework
    sleuthkit      # disk forensics tools (icat, fls, etc.)
    foremost       # file carving

    # Tunneling / pivoting -----------------------------------------------------------------------------------------------
    proxychains-ng  # route traffic through proxy chains
    sshuttle        # transparent proxy over SSH

    # General utilities --------------------------------------------------------------------------------------------------
    openssl        # CLI for certificates, hashing, encryption
    gnupg          # PGP encryption / signing
    steghide       # steganography tool
    exiftool       # read/write metadata from files

    # Burp Suite (via Flatpak - declared in services.nix) ----------------------------------------------------------------
    # Burp Suite Community is installed as a Flatpak for easy updates.
    # Launch with: flatpak run net.portswigger.BurpSuite-Community
  ];
}
