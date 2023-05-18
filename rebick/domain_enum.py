import requests 
import sys 

sub_list = open("/usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt").read() 
subdoms = sub_list.splitlines()

for sub in subdoms:
    sub_domains = f"http://{sub}.{sys.argv[1]}" 

    try:
        requests.get(sub_domains)
    
    except requests.ConnectionError: 
        pass
    
    else:
        print("Valid domain: ",sub_domains)   

dir_list = open("/usr/share/wordlists/SecLists/Discovery/Web-Content/directory-list-1.0.txt").read() 
directories = dir_list.splitlines()

for dir in directories:
    dir_enum = f"http://{sys.argv[1]}/{dir}.html" 
    r = requests.get(dir_enum)
    if r.status_code==404: 
        pass
    else:
        print("Valid directory:" ,dir_enum)
